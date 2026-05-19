import * as core from '@actions/core';
import * as exec from '@actions/exec';
import * as fs from 'node:fs/promises';
import * as path from 'node:path';
import type { ChangedFile, ChangeStatus } from './types.ts';

const FETCH_BASE = [
  '-c',
  'protocol.version=2',
  'fetch',
  '--no-tags',
  '--prune',
  '--no-recurse-submodules',
  '--filter=blob:none',
];

const git = (args: string[], opts?: exec.ExecOptions) =>
  exec.getExecOutput('git', args, { ...opts, ignoreReturnCode: true, silent: true });

async function mustGit(label: string, args: string[], opts?: exec.ExecOptions) {
  const r = await git(args, opts);
  if (r.exitCode !== 0) {
    throw new Error(`${label} failed (exit ${r.exitCode}): ${r.stderr.trim() || r.stdout.trim()}`);
  }
  return r;
}

export function resolveRefs(context: {
  eventName: string;
  sha: string;
  payload: {
    pull_request?: { base?: { sha?: string }; head?: { sha?: string } };
    before?: string;
    after?: string;
    repository?: { default_branch?: string };
  };
}): { base: string; head: string } {
  const pr = context.payload.pull_request;
  if (pr?.base?.sha && pr.head?.sha) {
    return { base: pr.base.sha, head: pr.head.sha };
  }
  const before = context.payload.before;
  if (context.eventName === 'push' && before && before !== '0'.repeat(40)) {
    return { base: before, head: context.payload.after ?? context.sha };
  }
  const defaultBranch = context.payload.repository?.default_branch;
  if (defaultBranch) {
    return { base: `origin/${defaultBranch}`, head: context.sha };
  }
  throw new Error(`Unable to determine base ref for event ${context.eventName}`);
}

function buildAuthMaterial(serverUrl: string, token: string) {
  const origin = new URL(serverUrl).origin;
  const credential = Buffer.from(`x-access-token:${token}`, 'utf8').toString('base64');
  return {
    configKey: `http.${origin}/.extraheader`,
    configValue: `AUTHORIZATION: basic ${credential}`,
    credential,
  };
}

function buildFetchUrl(serverUrl: string, repository: string): string {
  const [owner, name] = repository.split('/');
  return `${new URL(serverUrl).origin}/${encodeURIComponent(owner!)}/${encodeURIComponent(name!)}`;
}

export async function getChangedFiles(
  refs: { base: string; head: string },
  setup: { workspace: string; repository: string; serverUrl?: string; token?: string },
): Promise<ChangedFile[]> {
  const authKey = await ensureRepoForFetch(setup);
  try {
    await mustGit(
      `git fetch ${refs.base} ${refs.head}`,
      [...FETCH_BASE, 'origin', stripOrigin(refs.base), stripOrigin(refs.head)],
      { cwd: setup.workspace },
    );
    const result = await mustGit(
      `git diff ${refs.base}...${refs.head}`,
      ['diff', '--name-status', '-z', '--no-renames', `${refs.base}...${refs.head}`],
      { cwd: setup.workspace },
    );
    return parseDiffOutput(result.stdout);
  } finally {
    if (authKey) {
      await git(['config', '--local', '--unset-all', authKey], { cwd: setup.workspace });
    }
  }
}

async function ensureRepoForFetch(setup: {
  workspace: string;
  repository: string;
  serverUrl?: string;
  token?: string;
}): Promise<string | undefined> {
  const serverUrl = setup.serverUrl ?? process.env.GITHUB_SERVER_URL ?? 'https://github.com';
  const hasGit = await fs
    .stat(path.join(setup.workspace, '.git'))
    .then((s) => s.isDirectory())
    .catch(() => false);

  if (!hasGit) {
    await mustGit('git init', ['init', setup.workspace]);
    await mustGit('git remote add', ['remote', 'add', 'origin', buildFetchUrl(serverUrl, setup.repository)], {
      cwd: setup.workspace,
    });
    await git(['config', '--local', 'gc.auto', '0'], { cwd: setup.workspace });
  }

  if (!setup.token) {
    return undefined;
  }
  const auth = buildAuthMaterial(serverUrl, setup.token);
  core.setSecret(auth.credential);
  await mustGit('git config <auth>', ['config', '--local', auth.configKey, auth.configValue], {
    cwd: setup.workspace,
  });
  return auth.configKey;
}

const stripOrigin = (ref: string) => (ref.startsWith('origin/') ? ref.slice('origin/'.length) : ref);

function parseDiffOutput(output: string): ChangedFile[] {
  const tokens = output.split('\0').filter((t) => t.length > 0);
  const files: ChangedFile[] = [];
  for (let i = 0; i + 1 < tokens.length; i += 2) {
    files.push({ status: mapDiffStatus(tokens[i]!), path: tokens[i + 1]! });
  }
  return files;
}

function mapDiffStatus(code: string): ChangeStatus {
  switch (code[0]) {
    case 'A':
      return 'added';
    case 'D':
      return 'deleted';
    case 'R':
      return 'renamed';
    default:
      return 'modified';
  }
}
