import assert from 'node:assert/strict';
import { describe, it } from 'node:test';
import { compileForceFilters, compileRule } from '../src/matcher.ts';
import { parseFilters } from '../src/filters.ts';
import { ALL_STATUSES, type ChangedFile, type FilterRule } from '../src/types.ts';

const rule = (partial: Partial<FilterRule> & { name: string; paths: string[] }): FilterRule => ({
  pathsIgnore: [],
  status: ALL_STATUSES,
  ...partial,
});

const file = (path: string, status: ChangedFile['status'] = 'modified'): ChangedFile => ({ path, status });

describe('matcher - dot:true config', () => {
  it('matches dotfiles (regression catcher: dot:true must stay set)', () => {
    const r = rule({ name: 'gh', paths: ['.github/**'] });
    assert.equal(compileRule(r)(file('.github/workflows/test.yml')), true);
  });
});

describe('matcher - extglob (regression catcher: must stay enabled)', () => {
  it('matches the i18n weblate pattern', () => {
    const r = rule({ name: 'i18n', paths: ['i18n/!(en|package)**.json'] });
    const m = compileRule(r);
    assert.equal(m(file('i18n/de.json')), true);
    assert.equal(m(file('i18n/de_DE.json')), true);
    assert.equal(m(file('i18n/en.json')), false);
    assert.equal(m(file('i18n/package.json')), false);
  });

  it('matches with backslash-escaped dot like the original weblate filter', () => {
    const r = rule({ name: 'i18n', paths: ['i18n/!(en|package)**\\.json'] });
    const m = compileRule(r);
    assert.equal(m(file('i18n/de.json')), true);
    assert.equal(m(file('i18n/en.json')), false);
    assert.equal(m(file('i18n/package.json')), false);
  });
});

describe('matcher - paths-ignore precedence', () => {
  it('rejects files matched by paths-ignore even if paths matches', () => {
    const r = rule({
      name: 'i18n',
      paths: ['i18n/**.json'],
      pathsIgnore: ['i18n/en.json', 'i18n/package.json'],
    });
    const compiled = compileRule(r);
    assert.equal(compiled(file('i18n/de.json')), true);
    assert.equal(compiled(file('i18n/en.json')), false);
    assert.equal(compiled(file('i18n/package.json')), false);
  });
});

describe('matcher - status filtering', () => {
  it('only fires when the change matches an allowed status', () => {
    const r = rule({ name: 'm', paths: ['x/**'], status: ['modified'] });
    const compiled = compileRule(r);
    assert.equal(compiled(file('x/a', 'modified')), true);
    assert.equal(compiled(file('x/a', 'added')), false);
    assert.equal(compiled(file('x/a', 'deleted')), false);
  });

  it('defaults to all statuses when status is unset', () => {
    const r = rule({ name: 'm', paths: ['x/**'] });
    const compiled = compileRule(r);
    for (const s of ALL_STATUSES) {
      assert.equal(compiled(file('x/a', s)), true);
    }
  });

  it('object form parsed from YAML respects status filter', () => {
    const [r] = parseFilters(`
i18n:
  paths: ['i18n/**']
  status: [modified]
`);
    const compiled = compileRule(r!);
    assert.equal(compiled(file('i18n/de.json', 'modified')), true);
    assert.equal(compiled(file('i18n/de.json', 'added')), false);
  });
});

describe('matcher - force filters empty short-circuit', () => {
  it('returns a never-match when patterns is empty', () => {
    const m = compileForceFilters([]);
    assert.equal(m(file('anything')), false);
  });
});
