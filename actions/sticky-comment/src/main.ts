import * as core from '@actions/core';
import * as github from '@actions/github';

type Octokit = ReturnType<typeof github.getOctokit>;

async function run(): Promise<void> {
  try {
    const id = core.getInput('id', { required: true });
    const body = core.getInput('body');
    const doDelete = core.getBooleanInput('delete');
    const token = core.getInput('token', { required: true });

    if (!doDelete && !body) {
      core.setFailed('`body` is required unless `delete` is true');
      return;
    }

    const number = resolveNumber(core.getInput('number'));
    if (number === undefined) {
      core.setFailed(
        `Could not determine issue/PR number from event '${github.context.eventName}'. Pass the \`number\` input.`,
      );
      return;
    }

    const octokit = github.getOctokit(token);
    const { owner, repo } = github.context.repo;
    const marker = `<!-- sticky-comment:${id} -->`;

    const author = await getViewerLogin(octokit);
    const match = await findMatch(octokit, owner, repo, number, author, marker);

    if (doDelete) {
      if (match) {
        await octokit.rest.issues.deleteComment({ owner, repo, comment_id: match.id });
        core.info(`Deleted comment ${match.id}`);
      } else {
        core.info('No matching comment to delete');
      }
      return;
    }

    const fullBody = `${body}\n${marker}`;

    if (!match) {
      const { data } = await octokit.rest.issues.createComment({
        owner,
        repo,
        issue_number: number,
        body: fullBody,
      });
      core.info(`Created comment ${data.id}`);
      return;
    }

    if (match.body === fullBody) {
      core.info(`Comment ${match.id} unchanged; skipping update`);
      return;
    }

    await octokit.rest.issues.updateComment({
      owner,
      repo,
      comment_id: match.id,
      body: fullBody,
    });
    core.info(`Updated comment ${match.id}`);
  } catch (err) {
    core.setFailed(err instanceof Error ? err.message : String(err));
  }
}

function resolveNumber(input: string): number | undefined {
  if (input) {
    const n = Number.parseInt(input, 10);
    return Number.isInteger(n) && n > 0 ? n : undefined;
  }
  const ctx = github.context;
  return (
    ctx.payload.pull_request?.number ??
    ctx.payload.issue?.number ??
    ctx.payload.workflow_run?.pull_requests?.[0]?.number
  );
}

async function getViewerLogin(octokit: Octokit): Promise<string> {
  const data = await octokit.graphql<{ viewer: { login: string } }>(
    'query { viewer { login } }',
  );
  return data.viewer.login;
}

function stripBotSuffix(login: string | null | undefined): string {
  return (login ?? '').replace(/\[bot\]$/, '');
}

async function findMatch(
  octokit: Octokit,
  owner: string,
  repo: string,
  issue_number: number,
  author: string,
  marker: string,
): Promise<{ id: number; body: string } | undefined> {
  const normalizedAuthor = stripBotSuffix(author);
  for await (const { data } of octokit.paginate.iterator(
    octokit.rest.issues.listComments,
    { owner, repo, issue_number, per_page: 100 },
  )) {
    for (const c of data) {
      if (stripBotSuffix(c.user?.login) === normalizedAuthor && c.body?.includes(marker)) {
        return { id: c.id, body: c.body };
      }
    }
  }
  return undefined;
}

run();
