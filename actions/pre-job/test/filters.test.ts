import assert from 'node:assert/strict';
import { describe, it } from 'node:test';
import { parseFilters, parseForceFilters } from '../src/filters.ts';
import { ALL_STATUSES } from '../src/types.ts';

describe('parseFilters - list form', () => {
  it('accepts a single filter with a flat list of patterns', () => {
    const rules = parseFilters(`mobile:\n  - 'mobile/**'\n`);
    assert.equal(rules.length, 1);
    assert.equal(rules[0]!.name, 'mobile');
    assert.deepEqual(rules[0]!.paths, ['mobile/**']);
    assert.deepEqual(rules[0]!.pathsIgnore, []);
    assert.deepEqual([...rules[0]!.status], [...ALL_STATUSES]);
  });

  it('accepts multiple filters, preserving order', () => {
    const rules = parseFilters(`
i18n:
  - 'i18n/**'
web:
  - 'web/**'
  - 'i18n/**'
`);
    assert.deepEqual(
      rules.map((r) => r.name),
      ['i18n', 'web'],
    );
    assert.deepEqual(rules[1]!.paths, ['web/**', 'i18n/**']);
  });
});

describe('parseFilters - object form', () => {
  it('accepts paths/paths-ignore/status', () => {
    const rules = parseFilters(`
i18n:
  paths: ['i18n/**.json']
  paths-ignore: ['i18n/en.json', 'i18n/package.json']
  status: [modified]
`);
    assert.equal(rules[0]!.name, 'i18n');
    assert.deepEqual(rules[0]!.paths, ['i18n/**.json']);
    assert.deepEqual(rules[0]!.pathsIgnore, ['i18n/en.json', 'i18n/package.json']);
    assert.deepEqual([...rules[0]!.status], ['modified']);
  });

  it('defaults status and paths-ignore when omitted', () => {
    const rules = parseFilters(`docs:\n  paths: ['docs/**']\n`);
    assert.deepEqual([...rules[0]!.status], [...ALL_STATUSES]);
    assert.deepEqual(rules[0]!.pathsIgnore, []);
  });
});

describe('parseFilters - rejects malformed input', () => {
  it('rejects non-mapping top-level YAML', () => {
    assert.throws(() => parseFilters('- a\n- b'), /mapping/);
  });

  it('rejects unknown keys in object form', () => {
    assert.throws(() => parseFilters(`x:\n  paths: ['a']\n  garbage: true`), /unknown key/);
  });

  it('rejects unknown status values', () => {
    assert.throws(() => parseFilters(`x:\n  paths: ['a']\n  status: [moved]`), /not in/);
  });
});

describe('parseForceFilters', () => {
  it('returns [] for empty input', () => {
    assert.deepEqual(parseForceFilters(''), []);
    assert.deepEqual(parseForceFilters('   '), []);
  });

  it('parses a flat YAML list of strings', () => {
    assert.deepEqual(parseForceFilters(`- '.github/workflows/test.yml'\n- '.github/actions/image-build'`), [
      '.github/workflows/test.yml',
      '.github/actions/image-build',
    ]);
  });

  it('rejects non-list input', () => {
    assert.throws(() => parseForceFilters('foo: bar'), /list of strings/);
  });
});
