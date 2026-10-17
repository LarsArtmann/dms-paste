# Status Reports

Point-in-time snapshots of project state. The living sources are [TODO_LIST.md](../../TODO_LIST.md) and [ROADMAP.md](../../ROADMAP.md); plans live under [docs/planning/](../planning/).

**Convention:** each new report adds its own row to the index below. Once every item in a report carries an inline resolution marker (`done at` / `Won't implement` / routed), the report moves to [archived/](archived/) and its row follows it there.

## Index (unarchived)

_None — every snapshot to date is fully resolved; see [archived/](archived/)._

## Archived

| Date       | Report                                                                                                          | Occasion                                                                             |
| ---------- | --------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------ |
| 2026-10-17 | [Hardening, preflight, release, M19 re-audit](archived/2026-10-17_06-31_hardening-release-docs-audit-status.md) | Sweep #2: CI hardened, qml-preflight shipped, v1.1.0 released, audit as-found 6.5/10 |
| 2026-10-17 | [Execution sweep + self-review](archived/2026-10-17_06-05_execution-sweep-self-review.md)                       | Pareto plan P1–P4 executed                                                           |
| 2026-10-17 | [docs-health audit + self-critical status](archived/2026-10-17_02-05_docs-health-audit.md)                      | First docs audit (baseline 7.0/5.5)                                                  |

The [Pareto master plan](../planning/archived/2026-10-17_02-09_pareto-master-plan.md) is archived alongside its reports.

## Docs-health scores history

| Audit | Date       | Occasion                               | Accuracy (as-found) | Fitness (as-found) |
| ----- | ---------- | -------------------------------------- | ------------------- | ------------------ |
| 1     | 2026-10-17 | Initial docs-health audit              | 7.0                 | 5.5                |
| 2     | 2026-10-17 | M19 re-audit (hardening session)       | 6.5                 | 10.0               |
| 3     | 2026-10-17 | Annotation + archive sweep (this pass) | 8.25                | 9.25               |

Re-audit convention: after each feature ship, run the docs-health pass again and compare Accuracy/Fitness against the history above.
