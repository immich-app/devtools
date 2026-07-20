# vmalert replay — version-worker recording rules backfill

One-off backfill of history for the recording rules defined in
`../app/vmrule-version-worker.yaml`. This directory is **not** referenced by any
flux Kustomization — it is inert until applied manually.

## Runbook

1. Edit `job.yaml`: set both `-replay.timeFrom` placeholders to the same
   RFC3339 timestamp, normally `now-31d` (e.g. `2026-06-19T00:00:00Z`).
2. Apply and wait for completion:

   ```sh
   kubectl apply -f configmap-rules.yaml -f job.yaml
   kubectl -n monitoring wait --for=condition=complete --timeout=2h job/version-worker-replay
   ```

3. Reset the vmsingle rollup result cache so queries immediately see the
   backfilled samples (run from any pod in the `monitoring` namespace):

   ```sh
   curl -s http://vmsingle-vmetrics:8428/internal/resetRollupResultCache
   ```

4. Clean up:

   ```sh
   kubectl -n monitoring delete job/version-worker-replay
   kubectl -n monitoring delete configmap/version-worker-replay-rules
   ```

## Notes

- The base group must be replayed before the derived groups, because the
  derived rules query the base rule series. The Job enforces this: the
  initContainer replays `base.yaml`, then the main container replays
  `derived.yaml`.
- Replayed points whose lookbehind window crosses the retention horizon (e.g.
  `[30d]` windows evaluated near the start of retained raw data) are lower
  bounds, not exact values.
- If vmalert is down for a period later on, the rule series will have holes for
  that period unless the affected window is re-replayed.
- `configmap-rules.yaml` must be kept in sync with
  `../app/vmrule-version-worker.yaml` whenever the rules change — the replay
  files are a plain vmalert rule-file copy of the VMRule groups.
