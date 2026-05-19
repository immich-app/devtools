import { compileForceFilters, compileRule } from './matcher.ts';
import type { ChangedFile, FilterRule } from './types.ts';

export interface PipelineInputs {
  filters: FilterRule[];
  forceFilters: string[];
  forceEvents: string[];
  forceBranches: string[];
  skipForceLogic: boolean;
  force: boolean;
}

export interface RuntimeContext {
  eventName: string;
  branch: string;
}

export interface Decision {
  results: Record<string, boolean>;
  reason: string;
}

export function evaluateUpfront(inputs: PipelineInputs, ctx: RuntimeContext): Decision | null {
  if (!inputs.skipForceLogic) {
    if (inputs.force) {
      return { results: all(inputs.filters, true), reason: '🚀 FORCED: custom force input is true' };
    }
    if (inputs.forceEvents.includes(ctx.eventName)) {
      return { results: all(inputs.filters, true), reason: `🚀 FORCED: event "${ctx.eventName}" is in force-events` };
    }
    if (inputs.forceBranches.includes(ctx.branch)) {
      return { results: all(inputs.filters, true), reason: `🚀 FORCED: branch "${ctx.branch}" is in force-branches` };
    }
  }
  return null;
}

export function evaluatePaths(inputs: PipelineInputs, changes: readonly ChangedFile[]): Decision {
  const forceMatch = compileForceFilters(inputs.forceFilters);
  if (!inputs.skipForceLogic && inputs.forceFilters.length > 0 && changes.some(forceMatch)) {
    return { results: all(inputs.filters, true), reason: '🚀 FORCED: force-filters matched a changed path' };
  }
  const results: Record<string, boolean> = {};
  for (const rule of inputs.filters) {
    results[rule.name] = changes.some(compileRule(rule));
  }
  return { results, reason: '📁 PATH FILTERING: results computed from changed paths' };
}

const all = (filters: FilterRule[], value: boolean): Record<string, boolean> =>
  Object.fromEntries(filters.map((f) => [f.name, value]));
