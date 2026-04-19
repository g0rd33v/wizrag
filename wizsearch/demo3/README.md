# WizSearch — Anthropic Agent Skills Archive

Stable v1.0 — a single-file static search page over 190 chunks of Anthropic Agent Skills documentation.

**Live:** https://g0rd33v.github.io/wizrag/wizsearch/demo3/

## Files

| File | Purpose |
|---|---|
| `index.html` | Self-contained UI + runtime. External deps: Fuse.js 7 (CDN), Inter webfont. |
| `wizindex-manifest.json` | Lists the shards, topics, sources, stats, suggested questions. |
| `chunks/shard-001.json` … `shard-004.json` | Chunk data, ~48 chunks per shard. |

## Manifest schema

```json
{
  "version": "3.0",
  "project": "Anthropic Agent Skills Archive",
  "description": "...",
  "built_at": "2026-04-19T...",
  "stats": { "chunks": 190, "sources": 41, "topics": 11, "index_size_kb": 488 },
  "topics": [ { "name": "...", "chunk_count": 54, "description": "..." }, ... ],
  "sources": [ { "url": "...", "label": "...", "chunk_count": 1 }, ... ],
  "shards": [ { "chunks_url": "chunks/shard-001.json", "chunk_count": 48 }, ... ],
  "suggested_questions": [ "What is a SKILL.md file...", ... ]
}
```

## Chunk schema

Each entry in a shard's `chunks[]` array has this shape:

```json
{
  "id": "chunk_0001",
  "title": "Short, descriptive section title",
  "topic": "Exact name from manifest.topics[]",
  "keywords": ["primary", "terms"],
  "synonyms": ["alternate spellings", "variations"],
  "alt_phrasings": ["how someone might phrase a question about this"],
  "source": "https://canonical-source-url",
  "source_label": "Human-friendly source name",
  "text": "The full chunk body, ~800-2000 characters, newlines preserved."
}
```

Quality of `keywords`, `synonyms`, and `alt_phrasings` directly determines search recall. Fuse.js weights: title 0.30, keywords 0.25, synonyms 0.15, alt_phrasings 0.10, topic 0.08, text 0.12.

## Expanding the index

Three ways to add content, in increasing complexity:

### 1. Append to an existing shard

Simplest. Open any `chunks/shard-00N.json`, append new chunk objects to its `chunks[]` array, increment its `chunk_count`. Then update `wizindex-manifest.json`: bump `stats.chunks`, matching `shards[n].chunk_count`, and any affected `topics[].chunk_count` and `sources[].chunk_count`.

### 2. Create a new shard

Create `chunks/shard-00N.json` with `{ "version": "3.0", "shard_index": N, "chunks": [...] }`. Add an entry `{ "chunks_url": "chunks/shard-00N.json", "chunk_count": X }` to `manifest.shards[]`. Update stats and topic/source counts.

The runtime fetches all shards in parallel and merges them. No code change needed.

### 3. New topic or source

If the new chunks introduce a topic or source that doesn't exist yet, also append to `manifest.topics[]` and `manifest.sources[]`. Topics render as chips on the home view sorted by `chunk_count` descending. Suggested starter questions render as pill cards above the topics — add to `manifest.suggested_questions[]` as desired.

## Runtime architecture

```
boot                      DOM ready + Fuse.js loaded
  -> loadIndex            fetch manifest + shards in parallel
  -> build FUSE           Fuse.js over keys with weights
  -> renderStarters       from manifest.suggested_questions
  -> renderTopics         from manifest.topics
  -> syncFromURL          auto-run ?q= if present

runSearch
  1. Fuse(full query) — best for phrases
  2. If 0 matches AND 2+ meaningful tokens:
     multiTokenSearch → Fuse once per token, merge by chunk id,
     rank by (tokens_matched DESC, best_score ASC)
  3. renderResults → grouped or flat view
```

## Local development

Since this is a static single-file page that fetches JSON, you need a local HTTP server (file:// won't work for CORS). From the repo root:

```bash
cd wizsearch/demo3
python3 -m http.server 8000
# Then open http://localhost:8000/
```

## Commit history

The `/demo3-step1/` through `/demo3-step10/` directories preserve the step-by-step build as independently-deployed snapshots. See the main repo README for the full build log.
