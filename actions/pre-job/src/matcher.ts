import picomatch from 'picomatch';
import type { ChangedFile, FilterRule } from './types.ts';

const PICO: picomatch.PicomatchOptions = { dot: true };

export function compileRule(rule: FilterRule) {
  const includes = rule.paths.map((p) => picomatch(p, PICO));
  const ignores = rule.pathsIgnore.map((p) => picomatch(p, PICO));
  const statuses = new Set(rule.status);
  return (file: ChangedFile) =>
    statuses.has(file.status) && !ignores.some((m) => m(file.path)) && includes.some((m) => m(file.path));
}

export function compileForceFilters(patterns: readonly string[]): (file: ChangedFile) => boolean {
  if (patterns.length === 0) {
    return () => false;
  }
  const matchers = patterns.map((p) => picomatch(p, PICO));
  return (file) => matchers.some((m) => m(file.path));
}
