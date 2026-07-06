# Project Layout — uwsn-k-connectivity

This document describes the folder organization as it actually exists. Pruned to reality
(per the Aletheia `project-layout` template) — this is a flat script collection, not an
installable src-layout package, so most of the pack's default tree does not apply here.

## Actual tree (observed, not aspirational)

```text
uwsn-k-connectivity/
├── CLAUDE.md                  # operating rules + Aletheia config block (this adoption)
├── docs/
│   ├── decisions.md           # ADR-lite decision chain (authority layer)
│   ├── build_log/             # empty as of adoption — see its README
│   ├── project-layout.md      # this file
│   └── results-meta.schema.json  # copy of the pack's evidence schema
├── results/                   # evidence convention going forward (empty except example)
│
├── Model/                     # the MILP formulation and its Gurobi solve driver
│   ├── VariableK_MR.py        # critical module — produces solutions_k*.csv
│   ├── .idea/                 # committed JetBrains project config (author's local env;
│   │                          #   left as-is, no re-architecting)
│   └── Results_*.txt          # historical per-run solver logs (dated filenames, flat)
│
├── plot_k1.m, plot_k3.m,       # critical modules — regenerate figures from the
│   plot_k1_k3.m                # corresponding solutions_k*.csv
├── solutions_k1.csv,           # MILP output consumed by the plot_k*.m scripts above
│   solutions_k3.csv,
│   solutions_k1_k3.csv
├── fig_network_model.m        # topology/base-station-placement figure (rng(42) seeded)
├── testplot_v1.m,              # STALE — read a 'solutions.csv' that does not exist in
│   toyExampleplot_v0.py,       # this repo; superseded by the solutions_k*.csv scripts
│   toyExampleplot_v1.py        # above. Left in place, flagged in CLAUDE.md.
│
├── Results-2024-09-15/         # historical output snapshot (kept, not migrated)
└── Results-2025-05-01/         # historical output snapshot (kept, not migrated)
```

## Module responsibilities

| Directory / file | Responsibility | Notes |
|---|---|---|
| `Model/VariableK_MR.py` | the MILP that computes k-connectivity solutions in-memory | in `critical_modules`; requires a Gurobi license; does **not** write the `solutions_k*.csv` files below — see `CLAUDE.md` Rule 5 |
| `plot_k1.m` / `plot_k3.m` / `plot_k1_k3.m` | regenerate figures from real solution CSVs | in `critical_modules` |
| `testplot_v1.m`, `toyExampleplot_v*.py` | stale — reference a nonexistent `solutions.csv` | not in `critical_modules`; not deleted (no re-architecting) |
| `Results-2024-09-15/`, `Results-2025-05-01/` | historical, pre-adoption output snapshots | not migrated into `results/`; kept as ground truth of what the generator actually saw |

## Invariants (from the project-layout skill, as they apply here)

1. Retired/stale documents are flagged, not deleted, during adoption.
2. Structural changes get a decision-log entry before files move — none have moved here.
3. `results/` (new) and the historical `Results-*/` dirs are intentionally kept separate;
   unifying them is a future decision, not part of this adoption.
