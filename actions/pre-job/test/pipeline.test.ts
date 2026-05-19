import assert from 'node:assert/strict';
import { describe, it } from 'node:test';
import { evaluatePaths, evaluateUpfront, type PipelineInputs, type RuntimeContext } from '../src/pipeline.ts';
import { ALL_STATUSES, type ChangedFile, type FilterRule } from '../src/types.ts';

const rule = (name: string, paths: string[]): FilterRule => ({ name, paths, pathsIgnore: [], status: ALL_STATUSES });

const baseInputs = (overrides: Partial<PipelineInputs> = {}): PipelineInputs => ({
  filters: [rule('a', ['a/**']), rule('b', ['b/**'])],
  forceFilters: [],
  forceEvents: [],
  forceBranches: [],
  skipForceLogic: false,
  force: false,
  ...overrides,
});

const ctx = (overrides: Partial<RuntimeContext> = {}): RuntimeContext => ({
  eventName: 'pull_request',
  branch: 'pr-branch',
  ...overrides,
});

describe('evaluateUpfront - force priority order', () => {
  it('custom force input wins over events/branches', () => {
    const out = evaluateUpfront(
      baseInputs({ force: true, forceEvents: ['release'], forceBranches: ['main'] }),
      ctx({ eventName: 'pull_request', branch: 'feature' }),
    );
    assert.match(out!.reason, /custom force input/);
    assert.deepEqual(out!.results, { a: true, b: true });
  });

  it('force-events triggers when current event is in the list', () => {
    const out = evaluateUpfront(
      baseInputs({ forceEvents: ['workflow_dispatch'] }),
      ctx({ eventName: 'workflow_dispatch' }),
    );
    assert.match(out!.reason, /force-events/);
    assert.deepEqual(out!.results, { a: true, b: true });
  });

  it('force-branches triggers when current branch is in the list', () => {
    const out = evaluateUpfront(baseInputs({ forceBranches: ['main'] }), ctx({ branch: 'main' }));
    assert.match(out!.reason, /force-branches/);
  });

  it('skip-force-logic disables all upfront force triggers (returns null → fetch needed)', () => {
    const out = evaluateUpfront(
      baseInputs({ force: true, forceEvents: ['workflow_dispatch'], forceBranches: ['main'], skipForceLogic: true }),
      ctx({ eventName: 'workflow_dispatch', branch: 'main' }),
    );
    assert.equal(out, null);
  });

  it('returns null when no force condition matches', () => {
    assert.equal(evaluateUpfront(baseInputs(), ctx()), null);
  });
});

describe('evaluatePaths - per-rule matching', () => {
  it('marks each rule independently based on changed files', () => {
    const decision = evaluatePaths(baseInputs(), [{ path: 'a/foo.ts', status: 'modified' }]);
    assert.deepEqual(decision.results, { a: true, b: false });
    assert.match(decision.reason, /PATH FILTERING/);
  });

  it('reports false for all rules when no files changed', () => {
    assert.deepEqual(evaluatePaths(baseInputs(), []).results, { a: false, b: false });
  });
});

describe('evaluatePaths - force-filters', () => {
  it('flips all results to true when force-filters match', () => {
    const decision = evaluatePaths(baseInputs({ forceFilters: ['.github/workflows/test.yml'] }), [
      { path: '.github/workflows/test.yml', status: 'modified' },
    ]);
    assert.deepEqual(decision.results, { a: true, b: true });
    assert.match(decision.reason, /force-filters/);
  });

  it('does not trigger force when only unrelated paths match', () => {
    const decision = evaluatePaths(baseInputs({ forceFilters: ['.github/workflows/test.yml'] }), [
      { path: 'a/file.ts', status: 'modified' },
    ]);
    assert.deepEqual(decision.results, { a: true, b: false });
    assert.match(decision.reason, /PATH FILTERING/);
  });

  it('skip-force-logic suppresses force-filters too', () => {
    const decision = evaluatePaths(baseInputs({ forceFilters: ['.github/workflows/test.yml'], skipForceLogic: true }), [
      { path: '.github/workflows/test.yml', status: 'modified' },
    ]);
    assert.deepEqual(decision.results, { a: false, b: false });
    assert.match(decision.reason, /PATH FILTERING/);
  });
});

describe('evaluatePaths - realistic immich docker.yml caller', () => {
  const inputs: PipelineInputs = {
    filters: [
      {
        name: 'server',
        paths: ['server/**', 'openapi/**', 'web/**', 'i18n/**'],
        pathsIgnore: [],
        status: ALL_STATUSES,
      },
      { name: 'machine-learning', paths: ['machine-learning/**'], pathsIgnore: [], status: ALL_STATUSES },
    ],
    forceFilters: [
      '.github/workflows/docker.yml',
      '.github/workflows/multi-runner-build.yml',
      '.github/actions/image-build',
    ],
    forceEvents: ['workflow_dispatch', 'release'],
    forceBranches: [],
    skipForceLogic: false,
    force: false,
  };

  it('per-rule on a server-only change', () => {
    const decision = evaluatePaths(inputs, [{ path: 'server/main.go', status: 'modified' }]);
    assert.deepEqual(decision.results, { server: true, 'machine-learning': false });
  });

  it('force-filter on a workflow file edit', () => {
    const files: ChangedFile[] = [{ path: '.github/workflows/docker.yml', status: 'modified' }];
    assert.deepEqual(evaluatePaths(inputs, files).results, { server: true, 'machine-learning': true });
  });

  it('workflow_dispatch short-circuits to all-true upfront', () => {
    const upfront = evaluateUpfront(inputs, ctx({ eventName: 'workflow_dispatch' }));
    assert.match(upfront!.reason, /force-events/);
    assert.deepEqual(upfront!.results, { server: true, 'machine-learning': true });
  });
});
