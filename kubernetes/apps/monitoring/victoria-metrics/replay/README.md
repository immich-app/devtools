# vmalert replay — version-worker recording rules backfill

One-off backfill of history for the recording rules defined in
`../app/vmrule-version-worker.yaml`. Flux applies this directory once via the
`vmetrics-replay` Kustomization in `../ks.yaml` (after `victoria-metrics`, so
vmsingle, vmalert, and the VMRule are already in place). No manual steps are
needed on merge.

The Job:

1. replays the base group (`base.yaml`) from `-replay.timeFrom` to now,
2. then replays the derived groups (`derived.yaml`), which read the base rule
   series (ordering enforced by the pod's initContainer sequence),
3. then resets the vmsingle rollup result cache so queries immediately see the
   backfilled samples.

`-replay.timeFrom` is checked in as ~31d before the expected merge date. If the
merge slips past it, the early part of the window simply falls outside raw
retention and produces empty points — no action needed.

## Monitoring

```sh
kubectl -n monitoring logs -f job/version-worker-replay -c replay-base
kubectl -n monitoring logs -f job/version-worker-replay -c replay-derived
kubectl -n monitoring wait --for=condition=complete --timeout=2h job/version-worker-replay
```

## Cleanup

After the job completes and the rule series validate against the raw queries
(see the "Recording Rule Validation" row on the Version Worker Server Analytics
dashboard): remove this directory and the `vmetrics-replay` Kustomization from
`../ks.yaml` in a follow-up PR — `prune: true` then deletes the Job and
ConfigMap.

## Re-running

Jobs are immutable, so the Job carries the `kustomize.toolkit.fluxcd.io/force`
annotation: flux will delete+recreate (and therefore re-run the replay) on any
spec change. To re-run a window, edit `-replay.timeFrom` in `job.yaml` and let
flux reconcile. Note that manually deleting the completed Job also makes flux
recreate it on the next reconciliation — a re-replay overwrites the same
historical points with identical values, so this is harmless but heavy.

## Notes

- Replayed points whose lookbehind window crosses the retention horizon (e.g.
  `[30d]` windows evaluated near the start of retained raw data) are lower
  bounds, not exact values.
- If vmalert is down for a period later on, the rule series will have holes for
  that period unless the affected window is re-replayed.
- `configmap-rules.yaml` must be kept in sync with
  `../app/vmrule-version-worker.yaml` whenever the rules change — the replay
  files are a plain vmalert rule-file copy of the VMRule groups.
