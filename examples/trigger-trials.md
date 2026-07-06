# Trigger-reliability trials

**Method:** Harness = independent Claude Opus 4.8 subagents (Claude Code `Task` tool), 2026-07-06. Each trial gave one subagent the 14 discipline skills + the generator as a routing table — the *verbatim* `description` frontmatter shipped in `skills/**/SKILL.md`, which is the only fire/no-fire signal — plus a **mixed, unlabeled** subset of prompts (round-robin split so no subagent saw a themed block, avoiding priming). The subagent routed each prompt to exactly one skill or `NONE`, with no knowledge of the intended answer, then results were joined back to the expected labels. Each prompt was submitted **once** (N ≈ 10 per skill across 7 target skills; 70 trials total). This is a spot-check, not a benchmark — a faithful test of the description triggers, not of the full live harness (which also injects a skills system-reminder). Imperfect data, honestly reported.

**Reading the tables:** *Should fire?* is the design intent; *Fired?* is the skill the router actually chose (or `NONE`). ✓ = matched intent (fired when it should, or stayed away when it should not); ✗ = mismatch, with the skill it went to instead.

## correctness-gate

*True positives fired: 5/6 · true negatives correctly not fired: 4/4*

| Prompt | Should fire? | Fired? | Notes |
|---|---|---|---|
| "I refactored the solver core in model.py — mark it done." | yes | ✗ → build-log | under-fire (routed to adjacent skill) |
| "The gate test just went red after my change. Is this a bug or an intentional change?" | yes | ✓ |  |
| "Can I say the optimization module is working now? I edited the constraint builder." | yes | ✓ |  |
| "I touched the critical pricing engine and I'm ready to ship it." | yes | ✓ |  |
| "Run the correctness gate before I commit this core change." | yes | ✓ |  |
| "let's just check this number real quick" | no  | ✓ | over-trigger risk |
| "I fixed a typo in a docstring, that's done." | no  | ✓ |  |
| "I updated the README wording, done." | no  | ✓ |  |
| "Bumped a log message string in a helper script." | no  | ✓ |  |
| "Is the correctness gate green? I changed the core model." | yes | ✓ |  |

## evidence-convention

*True positives fired: 6/6 · true negatives correctly not fired: 4/4*

| Prompt | Should fire? | Fired? | Notes |
|---|---|---|---|
| "I'm about to launch a 500-run parameter sweep we'll cite in the paper. Where do the results go?" | yes | ✓ |  |
| "These Monte Carlo results are only in my scratch dir — is that a problem?" | yes | ✓ |  |
| "Record this run properly, we'll make a decision based on it." | yes | ✓ |  |
| "Promote these batch results into the kept evidence." | yes | ✓ |  |
| "Write the meta file for this campaign." | yes | ✓ |  |
| "Let me just plot this quickly to eyeball the trend." | no  | ✓ |  |
| "What's the average of these three numbers?" | no  | ✓ |  |
| "I ran the script once to see if it crashes." | no  | ✓ |  |
| "We have dark runs scattered across caches — audit them." | yes | ✓ |  |
| "Delete the old results folder." | no  | ✓ |  |

## decision-log

*True positives fired: 6/6 · true negatives correctly not fired: 4/4*

| Prompt | Should fire? | Fired? | Notes |
|---|---|---|---|
| "We decided to switch from L-BFGS to Adam for the optimizer. Record it." | yes | ✓ |  |
| "Why did we choose 13 nodes as the default? Is there a decision for it?" | yes | ✓ |  |
| "Supersede D12 — we're reversing that scope cut." | yes | ✓ |  |
| "We're cutting the multi-hop feature from scope. Log the rationale." | yes | ✓ |  |
| "Add an ADR for choosing relative tolerance 1e-6." | yes | ✓ |  |
| "Let's rename this variable to something clearer." | no  | ✓ |  |
| "What's the current default tolerance value?" | no  | ✓ |  |
| "I'll use a for-loop here instead of a comprehension." | no  | ✓ |  |
| "We changed a modeling assumption: demand is now stochastic. Note the decision." | yes | ✓ |  |
| "Undo my last edit." | no  | ✓ |  |

## phase-gate

*True positives fired: 6/6 · true negatives correctly not fired: 4/4*

| Prompt | Should fire? | Fired? | Notes |
|---|---|---|---|
| "I think Phase 2 meets all its acceptance criteria — close it." | yes | ✓ |  |
| "Close the gate on the calibration milestone." | yes | ✓ |  |
| "Can we call this phase complete? Verify each criterion." | yes | ✓ |  |
| "Milestone closure for the modeling phase, please." | yes | ✓ |  |
| "We believe the Phase 3 acceptance criteria are met; run the closure ritual." | yes | ✓ |  |
| "Mark this subtask as done in TODO." | no  | ✓ |  |
| "Are we done for the day?" | no  | ✓ |  |
| "Close this GitHub issue." | no  | ✓ |  |
| "Finish writing this function." | no  | ✓ |  |
| "Is the phase done? Check the acceptance list item by item." | yes | ✓ |  |

## lit-anchor

*True positives fired: 6/7 · true negatives correctly not fired: 3/3*

| Prompt | Should fire? | Fired? | Notes |
|---|---|---|---|
| "Add a citation for the coverage result we're leaning on." | yes | ✓ |  |
| "Find references for acoustic routing protocols." | yes | ✓ |  |
| "Build the bibliography for the related work section." | yes | ✓ |  |
| "Cite the prior work on energy-minimizing routing." | yes | ✓ |  |
| "I'm adding related work; verify these DOIs are real before they go in." | yes | ✓ |  |
| "Read this paper and summarize its method for me." | no  | ✓ |  |
| "What's the standard DOI string format?" | no  | ✓ |  |
| "The literature says X — let me add that reference to the record." | yes | ✓ |  |
| "Open the references.bib file." | no  | ✓ |  |
| "No one has published non-uniform k-connectivity before — help me support that absence claim with citations." | yes | ✗ → external-positioning | under-fire (routed to adjacent skill) |

## layer-sync

*True positives fired: 6/6 · true negatives correctly not fired: 4/4*

| Prompt | Should fire? | Fired? | Notes |
|---|---|---|---|
| "Is the spec still in sync with the code after that refactor?" | yes | ✓ |  |
| "Did decision D08 actually propagate to the docs and notebooks?" | yes | ✓ |  |
| "Run a drift audit before we close the phase." | yes | ✓ |  |
| "Are the docs and code in sync?" | yes | ✓ |  |
| "Check for drift across the knowledge layers." | yes | ✓ |  |
| "where does this file go" | no  | ✓ | over-trigger risk; routed to project-layout |
| "git status please" | no  | ✓ |  |
| "Sync my fork with upstream main." | no  | ✓ |  |
| "Link this doc section to the source file it describes for point-precise checking." | yes | ✓ |  |
| "Update the changelog with today's commits." | no  | ✓ |  |

## negative-results-ledger

*True positives fired: 6/6 · true negatives correctly not fired: 4/4*

| Prompt | Should fire? | Fired? | Notes |
|---|---|---|---|
| "We tried simulated annealing and it dead-ended. Record it so nobody retries it." | yes | ✓ |  |
| "That didn't work — let's abandon the greedy heuristic approach entirely." | yes | ✓ |  |
| "We already tried a genetic algorithm months ago and it failed; note that." | yes | ✓ |  |
| "This whole approach is infeasible; log it so no one attempts it from scratch again." | yes | ✓ |  |
| "The result was negative — the extra feature didn't improve accuracy at all." | yes | ✓ |  |
| "That didn't work — I had a typo in the command, let me fix it and rerun." | no  | ✓ | over-trigger risk |
| "The test failed, let me debug it." | no  | ✓ |  |
| "This build is broken, fix it." | no  | ✓ |  |
| "Audit the project for unrecorded dead ends and abandoned approaches." | yes | ✓ |  |
| "That didn't work, try again with sudo." | no  | ✓ | over-trigger risk |

## Findings

**Overall: 68/70 routed as designed.** Zero over-fires — every deliberate near-miss stayed
away from its tempting skill, including the everyday-speech triggers the audit flagged as
risks:

- `"let's just check this number"` → `NONE` (did **not** summon `correctness-gate`).
- `"that didn't work"` said of a transient failure (typo / `sudo` retry / failing test) →
  `NONE` (did **not** summon `negative-results-ledger`); the same phrase said of a real
  abandonment → `negative-results-ledger` fired every time. The description's context
  ("fails, dead-ends, abandoned") disambiguates the phrase correctly.
- `"where does this file go"` → `project-layout`, **not** `layer-sync`.

**Skills that under-fired (missed a true positive):**
- `correctness-gate` — id 1 (`"I refactored the solver core… mark it done."`) routed to
  `build-log` once. On a 4-trial confirmation re-run it went `correctness-gate` 3× and
  `build-log` 1× (combined 5 trials: 3 cg / 2 build-log). A genuine semantic adjacency —
  "mark it done" brushes `build-log`'s "…done, log it" — but **majority-correct**, not a
  stable miss.
- `lit-anchor` — id 50 (`"No one has published X… support that absence claim with
  citations."`) routed to `external-positioning` once. Confirmation re-run: `lit-anchor` 3×,
  `external-positioning` 1× (combined 5 trials: 3 lit-anchor / 2 external-positioning). This
  is the known, *documented* overlap — both descriptions carry "is this novel", and
  `external-positioning` already states "Citation verification lives in `lit-anchor`."
  Majority-correct.

**Skills that over-fired (fired on a true negative):** none.

**`description` tunes made as a result:** none. No description was decisively indicted. The
two mis-routes were (a) single occurrences that (b) reverted to the correct skill on a
majority of confirmation trials and (c) landed on a *legitimately adjacent* skill, not a
wrong discipline. Tuning a description to chase majority-correct variance at a real semantic
boundary would trade a clean signal for noise — so, per the "tune only what the data
indicts" rule, the frontmatter is left unchanged and the two adjacency boundaries are
recorded here instead. The product's actual unknown — *does routing fire?* — now has a
number: on this spot-check, yes, 68/70, with no over-firing on the noisy triggers.

