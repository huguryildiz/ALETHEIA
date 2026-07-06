# CLAUDE.md — uwsn-k-connectivity

## One line

MATLAB + Python MILP-based non-uniform k-connectivity optimization for underwater sensor
networks (UWSN), behind the published paper "Mitigating Energy Cost of Connection
Reliability in UWSNs Through Non-Uniform k-Connectivity" (IEEE doc 11143186).

Current phase status is NOT kept in this file (it drifts) — derive it from `git log` and
the latest `docs/build_log/` entry. This is a completed, published research artifact
adopted retroactively; there is no active phase plan (see `phase_plan: null` below).

## Quick start

```bash
# No environment manifest exists (gap — see canonical_values / env_manifest below).
# Requires: Python 3.9+, gurobipy (licensed Gurobi install), numpy; MATLAB for the plot_*.m
# scripts. No shippable install command is recorded — do not fabricate one.
python3 Model/VariableK_MR.py   # runs the MILP; writes Results_<timestamp>.txt (aggregate
                                 # objective/gap/time only — does NOT write solutions_k*.csv;
                                 # see Rule 5 below, a real gap found by trying to run this.
# gate_command: none — see "Gate" under Operating rules below.
```

## Aletheia config block

Machine-readable bindings; every Aletheia skill resolves its `{{placeholder}}` references
here. Filled by the `skill-library-generator` interview on 2026-07-06 (see
`docs/decisions.md` D01 and `examples/adoption-transcript.md` for the full interview).

```yaml
aletheia:
  critical_modules: ["Model/VariableK_MR.py", "plot_k1.m", "plot_k3.m", "plot_k1_k3.m"]
  gate_command:     null   # gap — no automated correctness gate exists; see Rule 1 below
  canonical_values: "Model/VariableK_MR.py"   # hardcoded (node=30, Rate=0.5, dx=1/dy=3/dz=0.3,
                                               # N_l=3) inline in the script; not yet extracted
                                               # to a dedicated config — gap, recommendation only
  evidence_dir:     "results/"                # recommendation going forward; historical runs
                                               # live in ad hoc Results-YYYY-MM-DD/ dirs
  doc_layers:       [decisions, code]
  decision_log:     "docs/decisions.md"
  build_log_dir:    "docs/build_log/"
  phase_plan:       null   # N/A — published, closed-phase artifact, not an active project
  env_manifest:     null   # gap — no manifest observed anywhere; Model/.idea/Cagla.iml names
                            # "Python 3.9 (spyder-env)" but pins nothing shippable
  data_dir:         null   # solutions_k*.csv sit at repo root, consumed in place (no dedicated dir)
```

## Work-type routing (default + escalation — NOT mandatory-every-time)

Unchanged from the pack default (see `templates/CLAUDE.md` in the Aletheia pack for the
full table) — this project is small enough that the default table applies as-is; no
project-specific routing rows were needed.

## Operating rules (project-pinned summaries)

1. **Gate (honest statement of the gap).** There is no fast, shell-invocable correctness
   gate, and — see Rule 5 — the manual check below is *aspirational*, not currently
   reproducible end-to-end as shared. The closest honest check, as it would have to be
   practiced: rerun `Model/VariableK_MR.py` (requires a Gurobi license), regenerate
   `plot_k1.m` / `plot_k3.m` / `plot_k1_k3.m`, and visually confirm the resulting topology
   and path values still match what the paper reports. This is a manual, slow,
   human-in-the-loop check — not a `pytest`-style gate. Recorded here rather than invented,
   per the pack's ground-truth-only rule.
2. **Canonical operating point** — `node=30`, `Rate=0.5`, `dx=1`/`dy=3`/`dz=0.3`, `N_l=3`
   (in `Model/VariableK_MR.py`) change only with an explicit decision-log entry; today
   nothing enforces this beyond convention.
3. **Session artifacts** — AI-generated plans/scratch specs live under `.claude/plans/`,
   never in `docs/` or the repo root.
4. **Known stale scripts** — `testplot_v1.m`, `toyExampleplot_v0.py`, `toyExampleplot_v1.py`
   all read a `solutions.csv` that does not exist in this repo (superseded by the
   `solutions_k1.csv` / `solutions_k3.csv` / `solutions_k1_k3.csv` naming). Left in place
   (no re-architecting during adoption); flagged here so it isn't mistaken for a live path.
5. **Missing solution-export step (found by trying to run Rule 1's gate).**
   `Model/VariableK_MR.py` writes only `Results_<timestamp>.txt` aggregate summaries
   (`countNo; k_conn; objective; MIP_gap; runtime`); it has no code path that writes the
   per-edge `i,j,k,l,val` rows that `solutions_k1.csv` / `solutions_k3.csv` /
   `solutions_k1_k3.csv` actually contain (confirmed: `grep -n "solutions\|to_csv\|writerow\|savetxt\|DataFrame" Model/VariableK_MR.py`
   returns nothing). Whatever produced those CSVs is not in this repo. Until that export
   step is recovered or rewritten, Rule 1's gate cannot be executed end-to-end from the
   committed code alone — see `examples/adoption-transcript.md` §3a for how this was found.

## Pointers

- Decisions: `docs/decisions.md` (authority layer — newest on top).
- Evidence: `results/<name>_<date>/meta.json` — no dark runs. See D01's retroactive example.
- Historical (pre-adoption) run outputs: `Results-2024-09-15/`, `Results-2025-05-01/` —
  kept as-is; not migrated into `results/` (no re-architecting).
