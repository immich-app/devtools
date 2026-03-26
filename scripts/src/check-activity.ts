import { REST } from '@discordjs/rest';
import { graphql } from '@octokit/graphql';
import JSONbig from 'json-bigint';
import { readFileSync, writeFileSync } from 'node:fs';
import { dirname, resolve } from 'node:path';
import { setTimeout as sleep } from 'node:timers/promises';
import { fileURLToPath } from 'node:url';

const __dirname = dirname(fileURLToPath(import.meta.url));

// --- Configuration ---

const discordToken = process.env.DISCORD_TOKEN;
const discordGuildId = process.env.DISCORD_GUILD_ID;
const githubToken = process.env.GITHUB_TOKEN;
const githubOrg = process.env.GITHUB_ORG ?? 'immich-app';
const activityCutoffDays = Number.parseInt(process.env.ACTIVITY_CUTOFF_DAYS ?? '90', 10);

const missing: string[] = [];
if (!discordToken) {
  missing.push(
    '  DISCORD_TOKEN    — your Discord user token (open discord.com, DevTools → Network, filter for /api/, pick any request, copy the Authorization header value)',
  );
}
if (!discordGuildId) {
  missing.push(
    '  DISCORD_GUILD_ID — the Immich server ID; retrieve with: op read "op://tf_prod/IMMICH_DISCORD_SERVER_ID/password"',
  );
}
if (!githubToken) {
  missing.push('  GITHUB_TOKEN     — a GitHub PAT with read:org scope');
}
if (missing.length > 0) {
  console.error('Missing required env vars:\n' + missing.join('\n'));
  process.exit(1);
}

if (Number.isNaN(activityCutoffDays)) {
  console.error('ACTIVITY_CUTOFF_DAYS must be a valid integer');
  process.exit(1);
}

const cutoffDate = new Date(Date.now() - activityCutoffDays * 24 * 60 * 60 * 1000);
const cutoffDateStr = cutoffDate.toISOString().slice(0, 10);

// --- Types ---

type UserEntry = {
  github: { username: string; id: number };
  // Discord snowflakes exceed MAX_SAFE_INTEGER; json-bigint parses them as bigint
  discord: { username: string; id: number | bigint };
  roles: string[];
  dev?: boolean;
  active?: boolean;
};

type DiscordResult = {
  timestamp: string | null;
  link: string | null;
};

type GithubResult = {
  active: boolean;
  date: string | null;
  link: string | null;
};

type UserResult = {
  user: UserEntry;
  discordTimestamp: string | null;
  discordLink: string | null;
  discordSkipped: boolean;
  githubActive: boolean;
  githubDate: string | null;
  githubLink: string | null;
  githubSkipped: boolean;
  active: boolean;
};

const TARGET_ROLES = new Set(['contributor', 'support']);

// --- Load data ---

const usersJsonPath = resolve(__dirname, '../../tf/deployment/data/users.json');
// json-bigint preserves Discord snowflakes (64-bit integers) that exceed MAX_SAFE_INTEGER
const JSON64 = JSONbig({ useNativeBigInt: true });
const users = JSON64.parse(readFileSync(usersJsonPath, 'utf8')) as UserEntry[];

// --- API clients ---

// User tokens require no auth prefix; pass auth: false per-request and supply the header manually.
const discordRest = new REST({ version: '10' });

const githubGraphQL = graphql.defaults({
  headers: { authorization: `token ${githubToken}` },
});

// --- Helpers ---

async function getGithubOrgId(org: string): Promise<string> {
  const result = await githubGraphQL<{ organization: { id: string } }>(
    `query($login: String!) {
      organization(login: $login) { id }
    }`,
    { login: org },
  );
  return result.organization.id;
}

async function checkDiscordActivity(userId: number | bigint): Promise<DiscordResult> {
  try {
    const result = (await discordRest.get(`/guilds/${discordGuildId}/messages/search`, {
      query: new URLSearchParams({
        author_id: String(userId),
        sort_by: 'timestamp',
        sort_order: 'desc',
        limit: '1',
      }),
      auth: false,
      headers: { Authorization: discordToken! },
    })) as { messages?: Array<Array<{ id: string; channel_id: string; timestamp: string }>> };
    const msg = result.messages?.[0]?.[0];
    if (!msg) {
      return { timestamp: null, link: null };
    }
    return {
      timestamp: msg.timestamp,
      link: `https://discord.com/channels/${discordGuildId}/${msg.channel_id}/${msg.id}`,
    };
  } catch (error) {
    process.stderr.write(`  ⚠ Discord API error: ${error}\n`);
    return { timestamp: null, link: null };
  }
}

async function checkGithubActivity(username: string, orgId: string): Promise<GithubResult> {
  try {
    const contribResult = await githubGraphQL<{
      user: {
        contributionsCollection: {
          hasAnyContributions: boolean;
          pullRequestContributions: { nodes: Array<{ occurredAt: string; pullRequest: { url: string } }> };
          issueContributions: { nodes: Array<{ occurredAt: string; issue: { url: string } }> };
          pullRequestReviewContributions: { nodes: Array<{ occurredAt: string; pullRequest: { url: string } }> };
          commitContributionsByRepository: Array<{ repository: { nameWithOwner: string } }>;
        };
      } | null;
    }>(
      `query($login: String!, $from: DateTime!, $organizationID: ID!) {
        user(login: $login) {
          contributionsCollection(from: $from, organizationID: $organizationID) {
            hasAnyContributions
            pullRequestContributions(first: 1) {
              nodes { occurredAt pullRequest { url } }
            }
            issueContributions(first: 1) {
              nodes { occurredAt issue { url } }
            }
            pullRequestReviewContributions(first: 1) {
              nodes { occurredAt pullRequest { url } }
            }
            commitContributionsByRepository(maxRepositories: 1) {
              repository { nameWithOwner }
            }
          }
        }
      }`,
      { login: username, from: cutoffDate.toISOString(), organizationID: orgId },
    );

    const cc = contribResult.user?.contributionsCollection;
    if (cc?.hasAnyContributions) {
      const prNode = cc.pullRequestContributions.nodes[0];
      const issueNode = cc.issueContributions.nodes[0];
      const reviewNode = cc.pullRequestReviewContributions.nodes[0];
      const repoWithOwner = cc.commitContributionsByRepository[0]?.repository.nameWithOwner;
      const date = (prNode ?? issueNode ?? reviewNode)?.occurredAt ?? null;
      const link =
        prNode?.pullRequest.url ??
        issueNode?.issue.url ??
        reviewNode?.pullRequest.url ??
        (repoWithOwner ? `https://github.com/${repoWithOwner}/commits?author=${username}` : null);
      return { active: true, date, link };
    }

    // contributionsCollection doesn't include issue/PR comments or discussion comments.
    // Paginate the user's own comments sorted by updatedAt DESC; stop as soon as a comment's
    // updatedAt falls before the cutoff (guaranteed safe due to ordering).
    {
      type IssueCommentNode = {
        createdAt: string;
        updatedAt: string;
        url: string;
        repository: { owner: { login: string } };
      };
      let cursor: string | undefined;
      let page = 0;
      issueCommentLoop: while (true) {
        page++;
        if (page > 1) {
          process.stderr.write(
            `  [github] ↻ ${username}: scanning issue comments (page ${page}, ${(page - 1) * 100} scanned)...\n`,
          );
        }
        const result = await githubGraphQL<{
          user: {
            issueComments: { pageInfo: { hasNextPage: boolean; endCursor: string }; nodes: IssueCommentNode[] };
          } | null;
        }>(
          `query($login: String!, $after: String) {
            user(login: $login) {
              issueComments(first: 100, orderBy: {field: UPDATED_AT, direction: DESC}, after: $after) {
                pageInfo { hasNextPage endCursor }
                nodes { createdAt updatedAt url repository { owner { login } } }
              }
            }
          }`,
          { login: username, after: cursor },
        );
        const conn = result.user?.issueComments;
        if (!conn?.nodes.length) {
          break;
        }
        for (const c of conn.nodes) {
          if (new Date(c.updatedAt) < cutoffDate) {
            break issueCommentLoop;
          }
          if (c.repository.owner.login === githubOrg && new Date(c.createdAt) > cutoffDate) {
            return { active: true, date: c.createdAt, link: c.url };
          }
        }
        if (!conn.pageInfo.hasNextPage) {
          break;
        }
        cursor = conn.pageInfo.endCursor;
      }
    }

    // Discussion comments have no orderBy, so fetch the most recent 100 (last: 100) and check.
    {
      type DiscussionCommentNode = {
        createdAt: string;
        url: string;
        discussion: { repository: { owner: { login: string } } };
      };
      const result = await githubGraphQL<{
        user: { repositoryDiscussionComments: { nodes: DiscussionCommentNode[] } } | null;
      }>(
        `query($login: String!) {
          user(login: $login) {
            repositoryDiscussionComments(last: 100) {
              nodes { createdAt url discussion { repository { owner { login } } } }
            }
          }
        }`,
        { login: username },
      );
      for (const c of result.user?.repositoryDiscussionComments.nodes ?? []) {
        if (c.discussion.repository.owner.login === githubOrg && new Date(c.createdAt) > cutoffDate) {
          return { active: true, date: c.createdAt, link: c.url };
        }
      }
    }

    return { active: false, date: null, link: null };
  } catch (error) {
    process.stderr.write(`  ⚠ GitHub API error for ${username}: ${error}\n`);
    return { active: false, date: null, link: null };
  }
}

async function main() {
  console.log(`Checking activity since ${cutoffDateStr} (${activityCutoffDays} days) in org ${githubOrg}\n`);

  const orgId = await getGithubOrgId(githubOrg);
  const targetUsers = users.filter((u) => u.roles.some((r) => TARGET_ROLES.has(r)));
  const githubCount = targetUsers.filter((u) => u.github.username).length;
  const discordCount = targetUsers.filter((u) => u.discord.id).length;

  // GitHub: all checks in parallel
  process.stderr.write(
    `Querying GitHub (${githubCount} users, parallel) and Discord (${discordCount} users, 1s delay)...\n`,
  );
  const githubPromises = targetUsers.map(async (user) => {
    if (!user.github.username) {
      return { active: false, date: null, link: null, skipped: true };
    }
    const { active, date, link } = await checkGithubActivity(user.github.username, orgId);
    return { active, date, link, skipped: false };
  });

  // Discord: sequential with ~1s delay to respect rate limits
  const discordData: Array<DiscordResult & { skipped: boolean }> = [];
  for (const [i, user] of targetUsers.entries()) {
    if (i > 0) {
      await sleep(1000);
    }
    const name = user.github.username || user.discord.username;
    process.stderr.write(`  [${String(i + 1).padStart(2)}/${targetUsers.length}] ${name}\n`);
    if (!user.discord.id) {
      discordData.push({ timestamp: null, link: null, skipped: true });
    } else {
      const result = await checkDiscordActivity(user.discord.id);
      discordData.push({ ...result, skipped: false });
    }
  }

  const githubData = await Promise.all(githubPromises);
  process.stderr.write('\n');

  const results: UserResult[] = targetUsers.map((user, i) => {
    const discord = discordData[i];
    const github = githubData[i];
    const discordActive = !discord.skipped && discord.timestamp !== null && new Date(discord.timestamp) > cutoffDate;
    const active = discordActive || (!github.skipped && github.active);
    return {
      user,
      discordTimestamp: discord.timestamp,
      discordLink: discord.link,
      discordSkipped: discord.skipped,
      githubActive: github.active,
      githubDate: github.date,
      githubLink: github.link,
      githubSkipped: github.skipped,
      active,
    };
  });

  for (const result of results) {
    result.user.active = result.active;
  }

  const formatDiscord = (r: UserResult): string => {
    if (r.discordSkipped) {
      return '—';
    }
    if (r.discordTimestamp === null) {
      return 'inactive (not found in window)';
    }
    const date = r.discordTimestamp.slice(0, 10);
    const details = [date, r.discordLink].filter(Boolean).join(', ');
    const status = new Date(r.discordTimestamp) > cutoffDate ? 'active' : 'inactive';
    return `${status} (${details})`;
  };

  const formatGithub = (r: UserResult): string => {
    if (r.githubSkipped) {
      return '—';
    }
    if (r.githubActive) {
      const details = [r.githubDate?.slice(0, 10), r.githubLink].filter(Boolean).join(', ');
      return details ? `active (${details})` : 'active';
    }
    return 'inactive (not found in window)';
  };

  const printRow = (r: UserResult) => {
    const name = r.user.github.username || r.user.discord.username;
    const role = r.user.roles.find((rl) => TARGET_ROLES.has(rl)) ?? r.user.roles[0];
    console.log(`  ${role.padEnd(12)} ${name}`);
    console.log(`    Discord: ${formatDiscord(r)}`);
    console.log(`    GitHub:  ${formatGithub(r)}`);
  };

  const activeResults = results.filter((r) => r.active);
  const inactiveResults = results.filter((r) => !r.active);

  console.log(`ACTIVE (${activeResults.length}):`);
  for (const r of activeResults) {
    printRow(r);
  }

  console.log(`\nINACTIVE (${inactiveResults.length}):`);
  for (const r of inactiveResults) {
    printRow(r);
  }

  writeFileSync(usersJsonPath, JSON64.stringify(users, null, 2) + '\n');
  console.log('\nUpdated users.json written.');
}

main().catch((error: unknown) => {
  console.error(error);
  process.exit(1);
});
