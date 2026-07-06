# Core vs Extended — what the tiers mean

Every skill carries a `tier` in its frontmatter. The split is about *adoption pressure*,
not importance.

## Core (9) — `tier: core`

The everyday operating discipline. These were **harvested from a working research
repository** — its practiced rules and skills, plus `run-provenance`, consolidated from
that project's own gap audit as the highest-value reproducibility lever (environment +
input + seed fingerprints for every kept run). A project adopting Aletheia is expected to
run all of Core from day one; each one exists because its absence produced a real failure
mode.

`project-layout` · `layer-sync` · `decision-log` · `build-log` · `phase-gate` ·
`correctness-gate` · `canonical-params` · `run-provenance` · `evidence-convention`

## Extended (5) — `tier: extended`, `status: recommended`

The reproducibility-and-positioning canon: authored against computational-science best
practice, grounded in the exemplar where it practiced them. Recommended, adopted
deliberately — a small exploratory project may defer some; a project writing a paper should
be running all seven by submission time.

`statistical-reporting` · `numerical-determinism` · `negative-results-ledger` ·
`external-positioning` · `lit-anchor`

## Generator (1) — `tier: generator`

`skill-library-generator` — the meta-skill that binds the pack to a repo and mines
project-local skills. Run at adoption and quarterly thereafter.

## Work-type routing

The operative work-type routing table lives once in
[`templates/CLAUDE.md`](../templates/CLAUDE.md) — the adopter's always-loaded config. (Do not
mirror it here; a copy is a drift source by construction — the pack's own `layer-sync` would
flag it.) The read-once philosophy behind it — the idea lifecycle and where tests are owed —
lives in [`methodology.md`](methodology.md).

## Agents (3) — read-only auditors

`session-historian` (state digest), `drift-auditor` (layer sync), `verifier` (adversarial
claim refutation). All strictly read-only reporters: they write nothing; log/decision
writing is a *skill* action in the main session. Writer agents (runners, implementers) are
deliberately out of scope — execution automation is project-specific workflow; the generic
patterns are documented in [the examples gallery](../examples/).
