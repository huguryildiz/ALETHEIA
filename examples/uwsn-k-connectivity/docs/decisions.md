<!-- markdownlint-disable MD024 -->
# Decision Log

The project's significant decisions + their rationale. Authority layer: when code, docs,
and historical results disagree, this file arbitrates.

## Conventions

- **Status**: `accepted` (in force) / `superseded` / `rejected` / `deferred`
- New decision → added at the top
- Numbers are assigned at write time (next free number), never reserved in advance

Ordering: date (new → old).

---

## D01 — Adopt the Aletheia operating discipline

**Status**: accepted
**Date**: 2026-07-06

**Context**: This is a real, published MATLAB/Python repository (IEEE doc 11143186) adopted
as the Aletheia pack's adoption-transcript subject — the first end-to-end generator run on
a non-exemplar, non-Python-package-shaped repo. The project had no decision log, build log,
environment manifest, or correctness gate before this adoption.

**Decision**: Adopt the Aletheia skill pack. Bindings recorded in `CLAUDE.md`:
`critical_modules` = `Model/VariableK_MR.py` + the three `plot_k*.m` scripts; `gate_command`
left explicitly unbound (no automated gate exists — see `CLAUDE.md` Rule 1 for the honest
manual-check description); `canonical_values`, `env_manifest`, `data_dir`, and `phase_plan`
recorded as gaps rather than invented.

**Impact**: `CLAUDE.md` config block filled; `docs/build_log/` and `results/` conventions
created (both empty going forward — no retroactive backfill of runs that predate this
adoption, except the one illustrative `results/` example described below, which is labeled
retroactive). This entry is the log's founding record.
