# Methodology — read once

Philosophy that should be read once, not triggered as a skill. The operative rituals live in
their own skills (`phase-gate`, `evidence-convention`, `decision-log`, `correctness-gate`,
`canonical-params`) and the work-type routing table lives once in
[`templates/CLAUDE.md`](../templates/CLAUDE.md) — the single source. What remains here are the
two ideas that are stance, not procedure: how ideas enter and leave the project, and where
tests are owed.

The stance underneath both: **claims follow verification, predictions precede runs, negative
results are findings, and ceremony scales with consequence — never with enthusiasm.**

## The idea lifecycle

Every idea moves through one of three fates; an idea that is neither adopted nor retired after
its probe is an open loop — close it.

- **Probe** — a one-off question runs as a notebook or script-level flag (`project-layout`),
  never by editing defaults (`canonical-params`). Cheap, disposable, logged lightly.
- **Adopt** — the probe changed a default, a method, or the plan → `decision-log` entry with
  evidence linked; propagation owed to the other layers (`layer-sync`).
- **Retire** — the idea failed or lost → one-line `negative-results-ledger` entry (why it
  died, pointer to evidence). Retired ideas stay findable so they are not re-attempted from
  scratch.

## Test density scales with silent-failure risk

One question decides where tests are owed: **"can this code fail silently and corrupt a
result?"**

- **Yes — result-critical code** (core computations, data transforms feeding claims): high
  density, analytic pins, cross-checks; lives inside the critical modules under the
  `correctness-gate`.
- **Sometimes — shared utilities**: a handful of sanity tests at the boundaries.
- **No — orchestration, plotting, one-offs**: skip; their failures are loud or their outputs
  are inspected visually.

Do not write defensive-raise tests, trivial shape/type tests, or subsets of existing tests —
test count is not the metric; silent-failure coverage is.

For the operative work-type routing table, see [`templates/CLAUDE.md`](../templates/CLAUDE.md)
(the single source).
