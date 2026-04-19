# WizSearch

**A static, two-file knowledge base search system. Drop into any GitHub repo. Works in any AI.**

> **v2.0 is out.** The new bundle is **[`wiz2.zip`](./wiz2.zip)**. Loose templates live in [`/v2/`](./v2). Summary of changes in [`CHANGELOG.md`](./CHANGELOG.md). v1 (`wiz.zip`) is preserved alongside for backward compatibility.

WizSearch is a sub-product of WizRAG. Where the main WizRAG project (still in development) is a hosted service with persistent memory and write-back, WizSearch is the radically simple version: two static files, hosted anywhere, queried by humans, browser agents, and raw-fetch LLMs alike.

If you have a folder of documents and you want any AI to be able to retrieve from them, WizSearch turns that folder into a queryable knowledge base in about two minutes — for free, forever.

---

## What's in the Bundle

`wiz.zip` contains three files:

- **`README.md`** — instructions for the LLM that builds the index
- **`wizsearch.html`** — the search page template (front-end, branding, JavaScript already built)
- **`wizindex.json`** — the index schema template

You drop the zip into any LLM chat that has access to your repo. The LLM reads the README, follows the embedded build instructions in `wizsearch.html`, scans your docs, builds the index, and (if it has write access) commits both files to your repo. Done.

---

## How It Works

WizSearch serves three types of visitors from a single page:

### 1. Humans in a browser

Open the page. Use the search box. See results with links to source documents. Or browse the topic index and click through to specific files. URLs with `?q=question` auto-load with results pre-filled.

### 2. Browser agents (Claude in Chrome, headless browsers, Computer Use)

Same as humans. JavaScript runs, search executes, results render. The agent reads the rendered page and gets precise chunk-level retrieval.

### 3. Raw-fetch LLMs (Claude web fetch, ChatGPT browsing, Perplexity, Grok)

Cannot execute JavaScript. They fetch the raw HTML, see a static topic index with one-line descriptions and direct links to source files, pick the relevant topic, and fetch that source file in their next request. No JavaScript needed. The topic index is written as static HTML so it's always visible in the source.

The same page serves all three without any backend, without any detection, without any compromises. Each visitor type uses what they can.

---

## Architecture

```
┌────────────────────────────────────────────────────────────┐
│                    Static host (GitHub Pages, etc.)         │
│                                                             │
│   /wizsearch.html    ← front door, all three visitor types  │
│   /wizindex.json     ← chunk index for JS search            │
│   /docs/...          ← your existing documentation files    │
│                                                             │
└────────────────────────────────────────────────────────────┘
                            │
                ┌───────────┼───────────┐
                ▼           ▼           ▼
         ┌──────────┐  ┌─────────┐  ┌──────────────┐
         │  Human   │  │ Browser │  │ Raw-fetch    │
         │  in      │  │ agent   │  │ LLM          │
         │  browser │  │         │  │              │
         └──────────┘  └─────────┘  └──────────────┘
              │            │              │
         search box    search box      topic index
         + topics      + topics        + linked files
              │            │              │
              ▼            ▼              ▼
         JS renders   JS renders     Raw HTML →
         chunks       chunks         fetch source file
```

No backend. No vector database. No API keys. No compute. Just static files served from anywhere — GitHub Pages, S3, Netlify, your own server, even local file system.

---

## URL Structure

The page handles a `q` URL parameter for direct search links:

```
https://yoursite.com/wizsearch.html
https://yoursite.com/wizsearch.html?q=your+question
```

When the `?q=` parameter is present, the page loads with the query pre-filled and results auto-rendered (for visitors that execute JavaScript).

For raw-fetch LLMs, the URL parameter is ignored — they use the topic index path instead. This is the one tradeoff of the static-only design.

---

## Why Two Files

The constraint shaped the design.

A single HTML file would mean embedding the entire chunk index inline, which would bloat the page and make every query load the full index. Splitting the index into a separate JSON file means the search page loads instantly, the index loads only when search is used, and the index can be regenerated independently when source documents change.

More than two files would add complexity. Topic-summary files, separate template files, configuration files — each one is a thing the user has to understand, regenerate, and keep in sync. Two files is the minimum that works, and the minimum is the goal.

---

## Use Cases

**Open-source documentation** — turn your project's `/docs` folder into an AI-queryable knowledge base. Anyone can paste your `wizsearch.html` URL into Claude or ChatGPT and ask questions about your project.

**Personal wikis** — index your Obsidian vault, your notes folder, your research collection. Query it from any AI without exporting or building a custom RAG.

**Product manuals** — turn a folder of PDFs and markdown into a searchable knowledge base. Customers paste the URL into their AI and get answers.

**Reference material** — academic papers, legal docs, API references, anything you'd want to query semantically without setting up infrastructure.

**Snapshot documentation** — when you publish a versioned spec or release, generate a WizSearch index alongside it. Future readers (and their AIs) can query that exact version forever.

---

## Limitations

WizSearch is read-only. It does not save context back to the knowledge base. It does not sync across chats. It does not auto-update when source files change — you regenerate the index by re-running the build prompt.

For dynamic, writable, cross-chat knowledge with persistent memory, see the main WizRAG project (in development).

WizSearch is also limited by the index size that an LLM's context window can handle. For repositories with thousands of documents, the index may need to be sharded by topic into multiple files. The build prompt addresses this for typical repos (under 500 chunks).

---

## How to Use

1. **Download `wiz.zip`** from this repo (`/wizsearch/wiz.zip`).
2. **Open a chat with an LLM that has access to your repository.** Claude, ChatGPT, Cursor, Claude Code — anything with file system or repo access works.
3. **Drop the zip into the chat** with one line of context: "Use this to index my repo: [your repo URL]"
4. **The LLM reads the README, follows the build instructions, scans your docs, generates both files.**
5. **If the LLM has write access**, it commits both files to your repo automatically. If not, you commit them manually.
6. **Enable GitHub Pages** if not already on (Settings → Pages → source: main branch, root or `/docs`).
7. **Visit `https://username.github.io/repo/wizsearch.html`** — your knowledge base is live.

---

## Test It

WizSearch was built and tested against the [Zeus Protocol](https://github.com/g0rd33v/zeus-protocol) repository. You can see a working instance at:

**https://g0rd33v.github.io/zeus-protocol/wizsearch.html**

Try the search box, browse the topic index, or paste the URL into Claude/ChatGPT and ask about Zeus Protocol.

---

## Files

- **`wiz.zip`** — the bundle to drop into any LLM chat
- **`wizsearch.html`** — the source template (also inside the zip)
- **`wizindex.json`** — the index schema template (also inside the zip)
- **`README.md`** — the LLM-facing entry point (also inside the zip)

---

## Roadmap

WizSearch is shipping as v1 — radically simple, two files, static-only.

Future versions may add:

- **WizSearch Edge** — a Cloudflare Pages variant with serverless functions, enabling true `?q=` server-side rendering for raw-fetch LLMs (single-request retrieval for everyone)
- **Index sharding** — for very large repositories, split the index by topic into multiple files
- **Multilingual support** — better handling of non-English documentation
- **Update detection** — a tiny script that checks if source files have changed since the last index build

These are deferred until v1 has been used in the wild and real needs surface.

---

## License

MIT

---

*WizSearch is part of the [WizRAG](https://github.com/g0rd33v/wizrag) project by [Eugene Gordeev](https://x.com/egordeev) — a [Labs](https://labs.vc) project.*
