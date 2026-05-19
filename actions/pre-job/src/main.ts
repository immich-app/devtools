import * as core from '@actions/core';
import * as github from '@actions/github';
import { parseFilters, parseForceFilters } from './filters.ts';
import { getChangedFiles, resolveRefs } from './git.ts';
import { evaluatePaths, evaluateUpfront, type PipelineInputs, type RuntimeContext } from './pipeline.ts';

const csv = (v: string) =>
  v
    .split(',')
    .map((s) => s.trim())
    .filter(Boolean);

async function run(): Promise<void> {
  const inputs: PipelineInputs = {
    filters: parseFilters(core.getInput('filters', { required: true })),
    forceFilters: parseForceFilters(core.getInput('force-filters')),
    forceEvents: csv(core.getInput('force-events')),
    forceBranches: csv(core.getInput('force-branches')),
    skipForceLogic: core.getBooleanInput('skip-force-logic'),
    force: core.getBooleanInput('force'),
  };
  const ref = github.context.ref ?? '';
  const runtime: RuntimeContext = {
    eventName: github.context.eventName,
    branch: ref.startsWith('refs/heads/') ? ref.slice('refs/heads/'.length) : ref,
  };

  core.info(`event=${runtime.eventName} branch=${runtime.branch} filters=${inputs.filters.length}`);

  let final = evaluateUpfront(inputs, runtime);
  if (!final) {
    const refs = resolveRefs({
      eventName: github.context.eventName,
      sha: github.context.sha,
      payload: github.context.payload as Parameters<typeof resolveRefs>[0]['payload'],
    });
    core.info(`Resolving changes between ${refs.base}...${refs.head}`);
    const changes = await getChangedFiles(refs, {
      workspace: process.env.GITHUB_WORKSPACE ?? process.cwd(),
      repository: process.env.GITHUB_REPOSITORY!,
      token: core.getInput('github-token'),
    });
    core.info(`Detected ${changes.length} changed files`);
    final = evaluatePaths(inputs, changes);
  }

  core.info(final.reason);
  for (const [name, value] of Object.entries(final.results)) {
    core.info(`  ${name}: ${value}`);
  }
  core.setOutput('should_run', JSON.stringify(final.results));
}

run().catch((error: unknown) => {
  core.setFailed(error instanceof Error ? error.message : String(error));
});
