export type ChangeStatus = 'added' | 'modified' | 'deleted' | 'renamed';

export const ALL_STATUSES: readonly ChangeStatus[] = ['added', 'modified', 'deleted', 'renamed'];

export interface ChangedFile {
  path: string;
  status: ChangeStatus;
}

export interface FilterRule {
  name: string;
  paths: string[];
  pathsIgnore: string[];
  status: readonly ChangeStatus[];
}
