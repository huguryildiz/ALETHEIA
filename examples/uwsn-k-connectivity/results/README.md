# Results — evidence convention

Every kept campaign going forward lands under `results/<name>_<date>/` with a `meta.json`
conforming to `docs/results-meta.schema.json`. The directory itself is gitignored except
for `README.md`, `meta.json`, and curated summaries (see `.gitignore` in this folder).

## `uwsn-k1-k3_2024-09-15/`

This one entry is **retroactive**, not a live campaign run during this adoption: it
documents the pre-existing `solutions_k1.csv` / `solutions_k3.csv` / `solutions_k1_k3.csv`
outputs (committed at the repo root, unmoved — no re-architecting) using real, computed
SHA-256 hashes of the actual committed files. It exists to (a) demonstrate the convention's
shape on this repo's real data and (b) honestly flag what could *not* be reconstructed
after the fact (seeds, environment, wall time — see `meta.json`'s `provenance_note`).
