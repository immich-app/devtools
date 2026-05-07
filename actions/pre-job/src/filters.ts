import yaml from 'js-yaml';
import { ALL_STATUSES, type ChangeStatus, type FilterRule } from './types.ts';

const STATUS_VALUES = new Set<ChangeStatus>(ALL_STATUSES);
const OBJECT_KEYS = new Set(['paths', 'paths-ignore', 'status']);

function asStringList(value: unknown): string[] {
  if (!Array.isArray(value) || value.some((i) => typeof i !== 'string')) {
    throw new Error(`expected list of strings, got ${JSON.stringify(value)}`);
  }
  return value as string[];
}

export function parseFilters(input: string): FilterRule[] {
  const parsed = yaml.load(input);
  if (parsed === null || typeof parsed !== 'object' || Array.isArray(parsed)) {
    throw new Error('filters must be a YAML mapping of filter-name to value');
  }
  return Object.entries(parsed as Record<string, unknown>).map(([name, value]) => parseRule(name, value));
}

function parseRule(name: string, value: unknown): FilterRule {
  if (Array.isArray(value)) {
    return { name, paths: asStringList(value), pathsIgnore: [], status: ALL_STATUSES };
  }
  if (value === null || typeof value !== 'object') {
    throw new Error(`Filter "${name}" must be a list or {paths, paths-ignore?, status?}`);
  }
  const obj = value as Record<string, unknown>;
  for (const key of Object.keys(obj)) {
    if (!OBJECT_KEYS.has(key)) {
      throw new Error(`Filter "${name}": unknown key "${key}"`);
    }
  }
  let status: readonly ChangeStatus[] = ALL_STATUSES;
  if ('status' in obj) {
    status = asStringList(obj.status).map((s) => {
      if (!STATUS_VALUES.has(s as ChangeStatus)) {
        throw new Error(`Filter "${name}" status "${s}" not in: ${ALL_STATUSES.join(', ')}`);
      }
      return s as ChangeStatus;
    });
  }
  return {
    name,
    paths: asStringList(obj.paths),
    pathsIgnore: 'paths-ignore' in obj ? asStringList(obj['paths-ignore']) : [],
    status,
  };
}

export function parseForceFilters(input: string): string[] {
  if (!input.trim()) {
    return [];
  }
  return asStringList(yaml.load(input));
}
