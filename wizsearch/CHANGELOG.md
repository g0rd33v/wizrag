# WizSearch Changelog

## v2.0 — 19 April 2026

Second release. The bundle is `wiz2.zip`. Loose template files live in `/wizsearch/v2/`.

### Search quality

- **Fuzzy multi-field search** across title, keywords, synonyms, alt-phrasings, topic, and text — weighted so keyword hits outrank text hits. v1 was plain substring matching with no ranking.
- **Score-filtered results.** Nonsense queries return zero; real terms surface up to 25 ranked hits. Fuse.js config: `threshold: 0.4`, post-filter cutoff `0.38`, `minMatchCharLength: 3`, `useExtendedSearch: false`.
- **No acronym expansion.** v2 removed query-time acronym rewriting — it was bloating queries and hurting short terms. Users who type an acronym find the chunks that contain it directly.

### Chunking

- **Semantic chunks** of 400–1200 tokens on paragraph and section boundaries, not arbitrary text slices.
- **Self-contained** — every chunk reads and retrieves on its own.
- **Per-chunk enrichment:** title (3–8 words), keywords (up to 14), synonyms (3–8), acronyms (map with full expansions), alt_phrasings (2–4 question-form variants), source_label.

### Named-entity coverage

- Build script now inventories named entities (people, products, subsidiaries) and **embeds exact strings into chunk keywords** — not only buried in the `text` field where Fuse scores them poorly. This is the single biggest relevance win.
- Keyword cap per chunk raised from 8 to 14 so expanded entities are not truncated.

### Performance

- **IndexedDB caching.** First load fetches `wizindex.json`; subsequent loads are instant and work offline.
- **Cache-bust on first fetch** (`?v=<timestamp>`) so users always start on the latest build instead of a stale CDN copy.
- **Background freshness check.** If the on-disk `built_at` differs from the cached copy, the index is refreshed silently.

### Design

- **Hero order:** kicker → search box → headline → description. Search comes first so users can query before reading anything.
- **Typography discipline.** Serif (Playfair Display) for headlines and section titles only. Everything else — search input, results, body copy — IBM Plex Sans or IBM Plex Mono.
- **No italic or accent-color ornaments** in body text. No drop-cap first-letters. Accent color is reserved for hover and focus states.
- **FT-editorial dark palette** with a salmon accent (`#e5817f` default, overridable).
- **Stats grid** (chunks, files, chars, payload) + bar-chart topic coverage view above the directory.

### New sections

- **§ II · How to use — Three ways in:** (1) quick search, (2) agent-driven via Claude in Chrome, (3) paste URL into any AI and let it read the index as RAG context.
- **§ IV · Protocol for AI agents:** Path A (fetch `wizindex.json` — recommended, one fetch covers everything) vs Path B (fetch original sources — verification only).

### Agent/LLM readiness

- **Static topic directory and chart data** embedded in the DOM so raw-fetch LLMs can read topics and coverage without running JavaScript.
- **Roman-numeral section numbering** (§I–§IV) for deterministic reference in agent scripts.
- **The index is the destination, not a waypoint.** One fetch of `wizindex.json` is the full knowledge base. Source URLs are a fallback for verification.

### Schema (`wizindex.json` v2.0)

```
{
  "version": "2.0",
  "project": "...",
  "description": "...",
  "built_at": "<ISO 8601>",
  "logo": null | "<inline SVG or data URI>",
  "accent_color": "#e5817f",
  "stats": { "files", "chunks", "topics", "total_characters", "index_size_kb" },
  "sources": [ { "label", "url", "type" } ],
  "topics": [ { "name", "description", "keywords", "chunk_count" } ],
  "entries": [ {
    "id", "source", "source_label", "topic", "title", "text",
    "keywords", "synonyms", "acronyms", "alt_phrasings"
  } ]
}
```

### Breaking changes from v1

- The search page is now the **destination**, not a router to source files. Expect users to read results in-place instead of clicking through.
- Chunk shape is different — v1 chunks are not compatible with v2 search.
- `wizsearch.html` now reads `wizindex.json` (lowercase, no suffix) — v1 used `wizindex1.json` in some forks. Make sure your deploy path matches.
- Filenames are strictly lowercase.

### Honest trade-offs

- **Index size grows.** A v2 index is typically 2–5× larger than v1. Up to ~10 MB is fine thanks to IndexedDB caching.
- **Enrichment is expensive.** Generating synonyms and alt-phrasings per chunk adds build-time work. Budget accordingly.
- **Manual rebuilds only.** v2 does not auto-update when sources change.
- **First load waits for the index** (1–3 seconds cold). Every subsequent load is instant.

---

## v1.0 — Earlier in 2026

First release. The bundle was `wiz.zip`. Two-file static search: `wizsearch.html` + `wizindex.json`. Substring-based search, arbitrary text chunks, routed users to original source files. Radically simple. Still shipped in the repo alongside v2.
