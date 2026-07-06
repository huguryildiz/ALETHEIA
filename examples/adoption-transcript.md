# Adoption transcript — UWSN k-connectivity (real repo)

Subject: [`examples/uwsn-k-connectivity/`](uwsn-k-connectivity/) — MATLAB/Python code behind
"Mitigating Energy Cost of Connection Reliability in UWSNs Through Non-Uniform
k-Connectivity" (IEEE doc 11143186, published). Slimmed for size/privacy; layout unchanged.
This is also the real repository that Aletheia's Core skills were originally harvested
from — see `examples/README.md`; it is named here because the paper is published.

Run date: 2026-07-06. Generator: `skill-library-generator` (this pack), invoked live
against the slimmed subject with `skill-library-generator/SKILL.md`'s own six-phase
process (discover → interview → extract → draft → audit → scaffold).

## 1. What the generator discovered (read-only)

**Observed** (commands actually run against the subject, verbatim):

```
$ find . -maxdepth 2 -type d
.
./Results-2025-05-01
./Results-2024-09-15
./Model
./Model/.idea

$ find . -maxdepth 1 -type f
./toyExampleplot_v0.py
./plot_k1.m
./fig_network_model.m
./plot_k1_k3.m
./toyExampleplot_v1.py
./solutions_k1_k3.csv
./plot_k3.m
./solutions_k1.csv
./testplot_v1.m
./2025-05-14-k-connectivity Sonuçlar.xlsx
./solutions_k3.csv

$ ls pyproject.toml uv.lock poetry.lock environment.yml requirements.txt
(none found)

$ ls tests/
(does not exist)

$ ls README* CLAUDE*
(none found)

$ git log --oneline -30 -- examples/uwsn-k-connectivity
7485995 examples: add slimmed UWSN k-connectivity subject repo for adoption transcript
```

- No environment manifest, no test directory, no README/CLAUDE.md, no decision or build log
  existed before this adoption.
- `Model/VariableK_MR.py` (346 lines) imports `gurobipy` — a commercial MILP solver
  requiring a license — and computes the k-connectivity solutions for `k_conn` = 1..3.
- **Correction, found while attempting to actually run it (see §3a below):**
  `VariableK_MR.py` does **not** write `solutions_k1.csv` / `solutions_k3.csv` /
  `solutions_k1_k3.csv` — confirmed by `grep -n "solutions\|to_csv\|writerow\|savetxt\|DataFrame" Model/VariableK_MR.py`,
  which returns no matches. It only writes `Results_<timestamp>.txt`, containing aggregate
  summary rows (`countNo; k_conn; objective; MIP_gap; runtime`), not the per-edge
  `i,j,k,l,val` rows the committed CSVs actually contain. The step that turns a solved
  model's `f`/`g` variables (present in the code, but only ever read via a commented-out
  post-processing block at the file's end — never written to disk) into those CSVs is
  **not present anywhere in this repository**. An earlier draft of this transcript stated
  the opposite (that this script "is the sole producer" of the CSVs) — that was an
  unverified inference stated as fact, caught only once we tried to actually exercise the
  gate. It is corrected here rather than silently fixed, per the pack's own
  ground-truth-only rule.
- Those three CSVs are each read by exactly one corresponding MATLAB script:
  `plot_k1.m` ↔ `solutions_k1.csv`, `plot_k3.m` ↔ `solutions_k3.csv`,
  `plot_k1_k3.m` ↔ `solutions_k1_k3.csv` (confirmed by `grep -n "readtable" *.m`).
- `random.seed(iterNo)` is used inside `VariableK_MR.py`'s solve loop, and the seed is
  printed to stdout on each iteration (`"seed={}, countNo={}, ..."`) — but not captured to
  any structured, kept record.
- A single fixed seed, `rng(42)`, appears in `fig_network_model.m` (base-station placement
  only, not the optimization).
- `Model/.idea/` is a committed JetBrains project (`Cagla.iml`) naming a local
  `Python 3.9 (spyder-env)` interpreter — not a shippable environment pin.

**Inferred**: `testplot_v1.m`, `toyExampleplot_v0.py`, and `toyExampleplot_v1.py` are stale
— each reads a `solutions.csv` file (confirmed by `grep`) that does not exist anywhere in
this repo. Inferred conclusion: these are earlier, superseded exploration scripts, kept
around but no longer wired to real data. Not verified with the original author; labeled as
inference in `CLAUDE.md` and `docs/project-layout.md`.

## 2. Interview and bindings

Two questions, asked of the repo's maintainer (also the Aletheia pack's author) directly,
per `skill-library-generator/SKILL.md` Phase 1:

**Q1 — "Which modules, if silently wrong, corrupt your results?"**
Proposed first (from discovery): `Model/VariableK_MR.py` alone, since it is the sole
numeric source. Maintainer's actual answer: include the plotting scripts too — both
`VariableK_MR.py` **and** `plot_k1.m` / `plot_k3.m` / `plot_k1_k3.m`, since a bug in the
MATLAB edge/node mapping could misrepresent a correct solution just as badly as a wrong
solve. **Bound**: `critical_modules: ["Model/VariableK_MR.py", "plot_k1.m", "plot_k3.m", "plot_k1_k3.m"]`.

**Q2 — "What's the closest thing to a single command that must pass before 'done'?"**
Proposed first (from discovery): no such command exists. Maintainer's actual answer
confirmed this directly: **no such command exists**. **Bound**: `gate_command: null`,
recorded as an honest gap rather than a fabricated fast command (see §3).

## 3. Where the gate-command binding did NOT fit

This repo has no fast single shell-invocable gate. Its de facto "gate" — as it would have to
be practiced, since none is written down anywhere in the repo today — is: rerun
`Model/VariableK_MR.py` (which needs a paid Gurobi license and can take real solver time,
not a sub-second unit test), regenerate the three `plot_k*.m` figures in MATLAB, and
**visually** confirm the resulting topology and path values still match what the published
paper reports. That is a slow, licensed, human-in-the-loop check, not a `pytest`-style
green/red signal.

This is exactly the binding assumption the design spec (§4.5) flagged as this example's
reason for existing: `{{gate_command}}` implicitly assumes a fast, free, automatable check.
For a MATLAB-plus-commercial-solver batch workflow, that assumption does not hold. The
honest resolution taken here: bind `gate_command` to `null` and write out the real manual
procedure in `CLAUDE.md` Rule 1, rather than either (a) inventing a fake fast command that
would silently pass without ever running the real solver, or (b) omitting the gate concept
entirely and pretending correctness isn't a concern for this repo.

## 3a. Attempted live verification (what actually happened when we tried)

After the scaffold below shipped, we tried to actually exercise the manual gate rather than
just describe it, to check the description was honest.

**Observed**: `gurobipy` was importable and a real academic license was active (expires
2026-11-28) in this environment — `mdl.optimize()` on a trivial one-variable model
succeeded. No MATLAB was available, so the `plot_k*.m` half of the gate could not be run
here regardless. Running `Model/VariableK_MR.py` unmodified at `node=30` (its committed
value) did not return a solution within several minutes — the delay was in Python-side
model construction (nested loops building `Interference` as a `(30,30,30)` array and the
MILP's variables/constraints), not in Gurobi's own `TimeLimit=3600` setting, which only
bounds the solver call itself. The run was stopped rather than left to complete
indefinitely.

**What that attempt surfaced**: trying to actually run the gate is what caught the CSV-
provenance error corrected in §1 above — `VariableK_MR.py` has no code path that writes
`solutions_k1.csv`-shaped output, so even a completed run would not have reproduced the
committed CSVs. **This is itself the honest finding worth keeping**: the manual gate
described above is *aspirational* — it describes what verification *should* look like, but
as shared, this repo cannot actually reproduce its own committed evidence end-to-end
without an undocumented step. That gap is now recorded here and in `CLAUDE.md`, not papered
over.

## 4. Scaffold produced (diff)

New files created in `examples/uwsn-k-connectivity/` (none pre-existed; nothing was
overwritten):

- **`CLAUDE.md`** — filled config block (see §2 above for the two interviewed bindings;
  `canonical_values`, `env_manifest`, `data_dir`, `phase_plan` recorded as gaps/N-A rather
  than invented), quick-start, and the honest gate description from §3.
- **`docs/decisions.md`** — founding entry `D01 — Adopt the Aletheia operating discipline`,
  dated 2026-07-06.
- **`docs/build_log/README.md`** — empty log, ready for the first real milestone.
- **`docs/project-layout.md`** — the pack's layout template pruned down to this repo's
  actual flat-script structure (no `src/`, no `tests/`, no `notebooks/` — none exist).
- **`docs/results-meta.schema.json`** — copy of the pack's evidence schema.
- **`results/README.md`** + **`results/.gitignore`** — the evidence convention going
  forward (bulk outputs ignored; `README.md`/`meta.json`/curated summaries tracked).
- **`results/uwsn-k1-k3_2024-09-15/meta.json`** — one illustrative entry, explicitly
  **retroactive** (labeled as such in its own `provenance_note`), built from real SHA-256
  hashes of the already-committed `solutions_k1.csv` / `solutions_k3.csv` /
  `solutions_k1_k3.csv`, honestly listing under `not_done` what could not be reconstructed
  after the fact (seeds, environment, wall time). Validated against
  `docs/results-meta.schema.json`.

## 5. Honest notes

- **Removed before the run** (mandatory cleanup, size/privacy only — not re-architecting):
  the 15 MB `Results-2024-09-25/` dump (including a stray `Solution_k1.csv.zip`), the 68 KB
  `fig_network_model.eps` binary, and recursive `.DS_Store` files. `Cagla.zip` did not exist
  in this checkout (a no-op). Confirmed no PII (emails, absolute home paths) present before
  renaming `Codes/` → `uwsn-k-connectivity/`.
- **Kept as real messiness, deliberately not fixed**: `Model/.idea/` (a committed IDE
  project pointing at the author's local environment), the three stale scripts referencing
  a nonexistent `solutions.csv`, the two differently-dated `Results-*/` snapshot folders
  sitting alongside the new `results/` convention rather than being migrated into it.
- **What the generator inferred vs. observed**: all layout/tooling facts in §1 are observed
  (command run, output shown); the "these three scripts are stale/superseded" conclusion in
  §1 is inference, and is labeled as such in both this transcript and `CLAUDE.md`.
- **Binding left as a recommendation, not enforced**: `canonical_values` points at
  `Model/VariableK_MR.py` (where `node=30`, `Rate=0.5`, `dx=1`/`dy=3`/`dz=0.3`, `N_l=3` are
  hardcoded) with no extraction to a dedicated config and no lock preventing silent edits —
  recorded as a gap in `CLAUDE.md`, not invented as if it already existed.
