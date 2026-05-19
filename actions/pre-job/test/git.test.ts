import assert from 'node:assert/strict';
import { describe, it } from 'node:test';
import { resolveRefs } from '../src/git.ts';

describe('resolveRefs', () => {
  it('uses pull_request base.sha and head.sha for PRs', () => {
    assert.deepEqual(
      resolveRefs({
        eventName: 'pull_request',
        sha: 'head-sha',
        payload: { pull_request: { base: { sha: 'base' }, head: { sha: 'head' } } },
      }),
      { base: 'base', head: 'head' },
    );
  });

  it('uses payload.before for push events', () => {
    assert.deepEqual(
      resolveRefs({
        eventName: 'push',
        sha: 'head-sha',
        payload: { before: 'before-sha', after: 'after-sha' },
      }),
      { base: 'before-sha', head: 'after-sha' },
    );
  });

  it('falls back to default branch when push.before is the zero sha (new branch)', () => {
    assert.deepEqual(
      resolveRefs({
        eventName: 'push',
        sha: 'head-sha',
        payload: {
          before: '0000000000000000000000000000000000000000',
          after: 'head-sha',
          repository: { default_branch: 'main' },
        },
      }),
      { base: 'origin/main', head: 'head-sha' },
    );
  });

  it('falls back to default branch for workflow_dispatch', () => {
    assert.deepEqual(
      resolveRefs({
        eventName: 'workflow_dispatch',
        sha: 'head-sha',
        payload: { repository: { default_branch: 'main' } },
      }),
      { base: 'origin/main', head: 'head-sha' },
    );
  });

  it('throws when there is no usable base ref source', () => {
    assert.throws(
      () => resolveRefs({ eventName: 'workflow_dispatch', sha: 'sha', payload: {} }),
      /Unable to determine base ref/,
    );
  });
});
