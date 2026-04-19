# WizRAG v2 — Local-First Knowledge Search

**You are reading this because someone dropped `wiz2.zip` into your chat.** They want you to turn their repository or folder of documents into a fast, beautiful, AI-queryable knowledge base.

## What's in This Bundle

Two template files and this README:

- **`wizsearch.html`** — the search page template (FT-editorial design, IndexedDB cache, Fuse.js fuzzy search, markdown rendering)
- **`wizindex.json`** — the enriched index schema template

Your job: fill them in for the user's content and (if you can) commit them.

## What to Do

1. **Open `wizsearch.html` in a text view.** At the very top of the file is an HTML comment block labeled `BUILD INSTRUCTIONS FOR THE LLM`. Read it carefully — it has the full v2 build process.

2. **Confirm what you're indexing.** Ask the user if it's unclear. This might be a GitHub repo, a local folder, a cloud drive, or any collection of documents you can access.

3. **Follow the build instructions.** Key v2 principles:
   - Chunks must be **semantic units** of 400–1200 tokens, not arbitrary splits
   - Each chunk must be **self-contained** — readable and useful on its own
   - Each chunk must include **keywords, synonyms, and alt-phrasings** for robust fuzzy retrieval
   - Inventory every proper noun, product, person, and acronym that appears in the corpus, then embed the exact strings into chunk keywords so Fuse matches them with high confidence
   - Write the full topic list as **static HTML** inside `<div id="topics-list">` and the chart data as JSON inside `data-topics` on `#topic-chart`
   - Replace the `{{LOGO_SVG}}` placeholder with an inline SVG — either the project's actual logo or a simple geometric mark

4. **Output both completed files.** Filenames must be lowercase: `wizsearch.html` and `wizindex.json`. If you have write access, commit them to a sensible location (repo root, `/docs/`, or `/wizsearch/`). Give the user the expected live URL.

## What WizRAG v2 Is

v2 is a local-first, blazing-fast knowledge interface. The index file (`wizindex.json`) carries the full answer — rich self-contained chunks enriched with keywords, synonyms, acronyms, and alternative phrasings. The search page caches the index in the browser's IndexedDB, so after the first load everything is instant and works offline.

This is a shift from v1, where the search page routed users to original source files. In v2, **the search page is the destination**. Source URLs exist as a fallback for verification, not as the primary retrieval path.

### How v2 improves on v1

- **Fuzzy multi-field search** (title, keywords, synonyms, alt-phrasings, topic, text) with relevance ranking — v1 was plain substring matching
- **Semantic chunks** on paragraph boundaries instead of arbitrary text slices
- **Enrichment per chunk**: title, keywords, synonyms, acronyms, alt-phrasings
- **IndexedDB caching** + cache-bust on first fetch so users always start on the latest build
- **Nonsense queries return 0** via score filtering; real queries return up to 25 ranked hits
- **Static HTML topic directory** and chart data in the DOM so raw-fetch LLMs can read the page without JS
- **Two-path retrieval protocol** for AI agents: prefer `wizindex.json` (one fetch, full knowledge base), fall back to original sources only for verification
- **"How to use" section** explaining three ways in: quick search, agent-driven, paste URL into any AI

### Three Visitor Types

1. **Humans in a browser** — beautiful search experience, rendered markdown results, click-to-copy, keyboard shortcuts
2. **Browser agents** (Claude in Chrome, headless browsers) — act like humans, use the search box, get rich rendered output to augment their answers
3. **Raw-fetch LLMs** (Claude web fetch, ChatGPT browsing, Grok, Perplexity) — read the static HTML with retrieval guidance, then fetch `wizindex.json` for the full knowledge base

### Why This Matters

- **Speed** — after the first load, queries are instant (no network round trip)
- **Offline** — works without internet once cached
- **Privacy** — no telemetry, no external calls, no API keys, no tracking
- **Local-LLM-ready** — chunks are sized (400–1200 tokens) to fit in quantized local model context windows
- **Portable** — two static files, runs anywhere that serves HTML (GitHub Pages, S3, local file system, USB stick)

## Design Rules (baked into the template)

The template encodes a strict set of typographic rules. Don't fight them:

- **Serif (Playfair Display) for headlines and section titles only.** Everything else is IBM Plex Sans or IBM Plex Mono.
- **Search input uses IBM Plex Sans**, not italic serif.
- **Results use sans-only.** No italic accents, no drop-cap first-letters, no accent-colored body text.
- **The hero order is fixed**: kicker → search box → headline → description. Search comes first so users can query before reading anything.
- **Accent color is typographic**, used for hover and focus states only — not for decorative emphasis in body copy.

## Search Behavior (baked into the template)

The template ships with a tuned Fuse.js config. Don't weaken it:

- `threshold: 0.4`, post-filter score cutoff `0.38`, `minMatchCharLength: 3`
- `useExtendedSearch: false` — plain mode gives more predictable multi-word behavior
- No acronym-expansion step — it bloats queries and hurts short terms
- Fetches `wizindex.json` with a cache-bust so users always get the latest build
- Up to 25 results per query, nonsense queries return 0
- Result count shown as "N entries for …"

## Honest Trade-offs You Should Know

- **Enrichment is expensive.** Adding synonyms and alt-phrasings to every chunk adds work at build time. For a 500-chunk index, budget accordingly.
- **Index size grows.** A v2 index is typically 2–5x larger than a v1 index. Up to ~10 MB is fine thanks to IndexedDB caching.
- **Named-entity coverage matters.** Entities that don't appear in chunk keywords (only in the raw text body) score poorly. Inventory your named entities and embed them as keywords — not just "topic" labels.
- **Manual rebuilds only.** v2 does not auto-update. When sources change, re-run this build process.
- **First load waits for the index.** Subsequent loads are instant from cache, but the first visit may take 1–3 seconds on a cold network.

## Quick Sanity Check Before You Start

- Do you have access to the user's content (repo, folder, or URLs)?
- Do you have write access to push the generated files? If not, present them in chat.
- Is the corpus big? For 1000+ docs, consider splitting into multiple indexes by topic.
- Does the project have a logo? If so, embed it inline as SVG. If not, generate a distinctive mark.

Now open `wizsearch.html` and follow the BUILD INSTRUCTIONS at the top.

---

*WizRAG is a [Labs](https://labs.vc) project. Repo: https://github.com/g0rd33v/wizrag*
