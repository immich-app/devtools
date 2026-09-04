# vmalert replay — data pipeline recording rules backfill

One-off backfill of history for the recording rules defined in
`../app/vmrule-data-pipeline.yaml`. Flux applies this directory once via the
`data-pipeline-vmetrics-replay` Kustomization in `../ks.yaml` (after
`data-pipeline-vmetrics`, so vmsingle, vmalert, and the VMRule are already in
place). No manual steps are needed on merge.

The Job replays the rule group from `-replay.timeFrom` (Feb 2022, before the
first ingested sample) to now, then resets the vmsingle rollup result cache so
queries immediately see the backfilled samples. The data vmsingle keeps 50y of
raw data, so the whole history is covered.

## Monitoring

```sh
kubectl -n data logs -f job/data-pipeline-replay -c replay
kubectl -n data wait --for=condition=complete --timeout=1h job/data-pipeline-replay
```

## Validation

Compare a rule series against the raw query the site used before, e.g. in the
data Grafana or with `curl` against vmsingle:

```
interpolate(max(max_over_time(immich_data:repository_star_total:max1h{environment="prod",repository_name="immich"}[1d])))
interpolate(max(max_over_time(immich_data_repository_star_total{environment="prod",repository_name="immich"}[1d])))
```

Both should produce the same daily values. The second one is the expensive
scan; expect it to take 20-30s.

## Cleanup

After the job completes and the rule series validate: remove this directory
and the `data-pipeline-vmetrics-replay` Kustomization from `../ks.yaml` in a
follow-up PR — `prune: true` then deletes the Job and ConfigMap.

## Re-running

Jobs are immutable, so the Job carries the `kustomize.toolkit.fluxcd.io/force`
annotation: flux will delete+recreate (and therefore re-run the replay) on any
spec change. Manually deleting the completed Job also makes flux recreate it on
the next reconciliation — a re-replay overwrites the same historical points
with identical values, so this is harmless.

## Notes

- If vmalert is down for a period later on, the rule series will have holes
  for that period unless the affected window is re-replayed.
- `configmap-rules.yaml` must be kept in sync with
  `../app/vmrule-data-pipeline.yaml` whenever the rules change — the replay
  file is a plain vmalert rule-file copy of the VMRule group.
