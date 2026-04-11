# Cross-Chat Knowledge Base

A pattern for persistent, cross-platform knowledge using URLs and markdown.

## The core idea

Every AI chat is a dead end. You build up context in ChatGPT — decisions, research, analysis — and it dies when the session ends. Switch to Claude and you start from zero. Use Grok for a brainstorm and the insights vanish when you close the tab.

RAG solves one part of this: you can upload documents and the AI retrieves from them. But RAG systems require vector databases, embedding pipelines, API keys, SDKs, and integration code. They're read-only — the AI can query the knowledge base but can't write to it. And they're locked to one platform.

The idea here is different. Instead of a complex RAG setup, you get **a single URL**. Paste it into any AI chat. The AI visits the URL, reads a markdown instruction page, and learns how to retrieve from your knowledge base, save new context back to it, check itself against it, and build a browsable wiki from it. All by visiting URLs and reading markdown.

The URL is the API. The markdown is the SDK. Every LLM that can browse the web is already a client.

This turns RAG from a developer tool into something anyone can set up in three minutes — and it makes the knowledge base **writable** and **cross-platform** by default.

## How it works

There are three layers:

**The documents** — your source material. PDFs, markdown files, text files, HTML pages. You upload them once. They get chunked, embedded, and indexed in a vector database. This is standard RAG infrastructure, hidden behind a simple upload interface.

**The URL** — a short, unique link that acts as both the access token and the instruction manual. When an LLM visits this URL, it receives a markdown page that teaches it the available commands. The URL path contains an API key, so no additional authentication is needed. Every command is a URL the LLM can visit.

**The wiki** — an auto-generated, browsable collection of interconnected markdown pages built from everything in the knowledge base. Not raw chunks — structured, cross-referenced, with contradictions flagged and a changelog showing how knowledge evolved. The wiki is a compounding artifact that gets richer with every save and every question.

## The commands

After the LLM reads the instruction page, it knows six commands. Each command is a URL visit that returns markdown.

**Ask** — the LLM visits a URL with a query parameter. The server embeds the query, searches the vector database, augments the results with an LLM, and returns a grounded answer in markdown. Zero hallucination — the answer comes only from the documents.

**Save** — the LLM visits a URL with data in a query parameter. The server chunks, embeds, and upserts the data into the vector database. The knowledge base grows from live conversations. This is the key difference from traditional RAG — it's read-write, not read-only.

**Validate** — the LLM queries the knowledge base, compares the retrieved ground truth against its own output, and self-corrects if it drifted. RAG as guardrail. The knowledge base becomes the source of truth that keeps every AI honest.

**Update wiki** — the server clusters all chunks by topic, generates interconnected wiki pages with cross-references, detects contradictions between claims, and builds an index and changelog. The wiki compiles knowledge once and keeps it current — it's not re-derived on every query.

**Lint wiki** — the server scans the wiki for contradictions, stale claims, orphan pages, missing cross-references, and data gaps. Returns an actionable health report.

**Save to wiki** — a good answer from the AI gets filed as a new wiki page, auto cross-referenced. Explorations compound in the knowledge base just like ingested sources.

## Why URLs and markdown

Two design constraints that make everything work:

**Everything is a GET request.** LLMs can visit URLs (HTTP GET) but most cannot make POST requests, set authentication headers, or parse JSON responses reliably. By using GET requests with query parameters and returning plain markdown, every command works in every LLM without integration code. The API key lives in the URL path — no headers needed.

**Everything returns markdown.** Every LLM can read markdown. No JSON parsing, no schema validation, no error handling. The LLM reads the response like it reads any web page. The instruction page is markdown. The answers are markdown. The wiki is markdown. It's markdown all the way down.

This means the "SDK" is a markdown page and the "API" is a set of URLs. There is nothing to install, nothing to configure, nothing to integrate. If an LLM can browse the web, it can use this system.

## Cross-platform sync

This is what makes the pattern powerful beyond a better RAG setup.

You brainstorm in Grok. You say "save to Wiz." The AI compacts the key insights and visits the save URL. The knowledge base is updated.

You open Claude. You paste the same URL. Claude reads the instruction page, retrieves the brainstorm you just saved from Grok, and continues where Grok left off. You structure the ideas. You save again.

You open ChatGPT. Same URL. It retrieves everything — the brainstorm from Grok, the structure from Claude. Full context. No export, no copy-paste, no "let me paste my notes from the other chat."

The knowledge base is the persistent memory that no single chat provides. Each AI reads from it and writes to it. The URL is the bridge between all of them.

## The wiki as a compounding artifact

Traditional RAG rediscovers knowledge from scratch on every question. The wiki layer changes this fundamentally.

When you trigger a wiki rebuild, the system doesn't just list your documents. It:

1. Pulls all chunks — from uploads and from saves
2. Clusters them by topic using an LLM
3. Generates a wiki page per topic: title, summary, key facts, cross-references to related pages
4. Detects contradictions — when two chunks claim opposite things, both are preserved with a flag
5. Builds an index page linking everything
6. Appends to a changelog that shows how knowledge evolved over time

The result is a structured, browsable knowledge base where the cross-references are already built, the contradictions are already flagged, and the synthesis already reflects everything you've saved. The wiki gets richer with every source you add and every question you ask.

The lint operation keeps it healthy: it finds contradictions between pages, stale claims superseded by newer saves, orphan pages with no connections, important concepts mentioned but lacking their own page, and data gaps the wiki should cover but doesn't.

Good query answers can be filed back as wiki pages. A comparison you asked for, an analysis, a connection between topics — these shouldn't disappear into chat history. Filing them into the wiki means explorations compound just like ingested sources.

The LLM does all the bookkeeping that humans abandon wikis over — updating cross-references, flagging contradictions, maintaining consistency across pages. The human's job is to curate sources, direct the analysis, ask good questions, and think. The LLM handles everything else.

This borrows directly from Karpathy's LLM Wiki pattern (April 2026), adapted for the cross-platform URL-based architecture.

## Semantic dedup

Before saving new data, the system embeds it and checks the cosine distance against existing chunks. If the new data is too similar to what's already stored (distance < 0.02), the save is skipped. This prevents the knowledge base from bloating with repeated information across saves from different chats.

The threshold is the same one used in production crawling systems for detecting meaningful changes in web pages. It filters out noise while preserving genuinely new information.

## URL structure

```
{base_url}/{api_key}                          → instruction page (skill)
{base_url}/{api_key}/ask?q={query}            → retrieval + augmented answer
{base_url}/{api_key}/ask?q={query}&validate=true → retrieval for validation
{base_url}/{api_key}/save?d={data}            → save context to knowledge base
{base_url}/{api_key}/wiki                     → wiki index
{base_url}/{api_key}/wiki/{slug}              → wiki topic page
{base_url}/{api_key}/wiki/log                 → wiki changelog
{base_url}/{api_key}/wiki/lint                → wiki health report
{base_url}/{api_key}/wiki/update              → trigger wiki rebuild
{base_url}/{api_key}/wiki/add?d={data}        → file answer as wiki page
{base_url}/{api_key}/info                     → project stats
```

All endpoints return `text/markdown`. All accept GET only. The `api_key` in the path is the only authentication.

## URL length constraints

- Query parameter `q` for ask: practical limit ~1,500 characters. Typical questions are 20-100 characters.
- Query parameter `d` for save: practical limit ~1,500 URL-encoded characters, which is roughly 500 words of plain text. For larger context dumps, the LLM should summarize first, or split across multiple saves.
- Most browsers support URLs up to 2,048 characters. The base URL + API key + endpoint use ~40 characters, leaving ~2,000 for parameters.

## The instruction page

When an LLM visits the base URL, it receives a markdown page structured like this:

```markdown
# Knowledge Base — Instructions for AI

You are connected to a persistent knowledge base.
Contains {doc_count} documents, {chunk_count} data points.
Last updated: {timestamp}.

## Commands

### Ask
When the user asks a question:
1. Visit: {base_url}/{api_key}/ask?q={url_encoded_question}
2. Read the response. Use the information to answer the user.

### Save
When the user says "save" or you detect important context:
1. Compact the key information (max 500 words)
2. Visit: {base_url}/{api_key}/save?d={url_encoded_data}
3. Confirm: "Saved."

### Validate
When the user says "validate":
1. Summarize your understanding in 1-2 sentences
2. Visit: {base_url}/{api_key}/ask?q={summary}&validate=true
3. Compare and correct.

### Wiki
- Update: visit {base_url}/{api_key}/wiki/update
- Browse: visit {base_url}/{api_key}/wiki
- Health check: visit {base_url}/{api_key}/wiki/lint

## Rules
- Visit the full URL including the key path
- URL-encode all parameters
- Use only retrieved information — do not hallucinate beyond it
```

The instruction page is dynamically generated with the API key pre-filled in all URL templates. The LLM reads it once at the start of a conversation and follows the commands from that point forward.

## Implementation notes

This pattern is intentionally abstract. The specific implementation depends on your stack, your scale, and your preferences. Here are the building blocks:

**Vector database** — Pinecone, Qdrant, pgvector, Weaviate, or any vector store that supports namespaced search. One namespace per knowledge base.

**Embedding model** — any embedding model that produces consistent vectors. bge-m3 (1024 dimensions, multilingual) is a good balance of quality and cost. text-embedding-3-large (3072 dimensions) if you need maximum retrieval quality.

**LLM for augmentation** — any capable model for grounded Q&A and wiki generation. GPT-4.1 mini, GPT-5.4 nano, Claude Haiku, Gemini Flash — whatever fits your cost/quality tradeoff. Temperature = 0 for deterministic answers.

**Document parsing** — standard tools for PDF, DOCX, HTML, markdown. The chunker should target ~400 tokens per chunk with 20% overlap for context continuity.

**Caching** — Redis or any key-value store for caching repeated queries. Cache key = hash of (knowledge base ID + normalized query). 5-minute TTL is reasonable.

**Job queue** — wiki rebuilds and lint passes take time. Process them asynchronously. Postgres SKIP LOCKED is simple and effective if you're already on Postgres.

**Hosting** — the server needs to handle GET requests and return markdown. Any web framework works. The computational work is in the embedding and LLM calls, which are external API calls.

## Who this is for

**Individuals** who work across multiple AI tools and want persistent context. Brainstorm in one AI, continue in another, never lose a thought.

**Builders** who want to give users a knowledge base without building RAG infrastructure. Upload docs, hand out a URL, done.

**Teams** where knowledge is scattered across chat histories, documents, and different AI tools. A shared URL becomes the team's persistent AI memory.

**Agent developers** who need their agents to have access to a grounded knowledge base without SDK integration. The agent visits URLs — that's the entire integration.

## What this is not

This is not a chatbot. There is no chat UI (though you could build one). All interaction happens in the user's existing AI chat.

This is not a vector database. It uses one, but the vector database is infrastructure — the user never touches it.

This is not an API in the traditional sense. There are no API keys (beyond the URL path), no JSON responses, no authentication headers, no client libraries. The "API" is URLs returning markdown.

This is not a single-platform tool. The entire point is that it works across every AI simultaneously. If it only worked in ChatGPT, it would just be a ChatGPT plugin.

## Related work

- **Karpathy's LLM Wiki** (April 2026) — the compounding wiki concept, lint operations, and filing answers back are directly influenced by this pattern. Karpathy's version is local-first (Obsidian + LLM agent). This pattern is web-first (URLs + any LLM).
- **RAG systems** (Pinecone, Vectara, Mendable) — the retrieval infrastructure. This pattern wraps RAG in a URL-based protocol that makes it accessible without SDKs.
- **NotebookLM** (Google) — similar goal of making documents queryable. But single-platform, read-only, no write-back, no cross-chat sync.
- **Claude Projects / ChatGPT file uploads** — per-platform document grounding. Doesn't sync across platforms. No write-back from conversations.
- **MCP (Model Context Protocol)** — Anthropic's protocol for tool integration. Requires server setup and client support. This pattern uses URLs only — no protocol support needed.

## Note

This document describes a pattern, not a product. The URL structure, the markdown format, the wiki generation logic, the semantic dedup threshold — all of these are implementation choices that can be adapted. The core idea is simpler: **a URL that any AI can read from, write to, and browse — making knowledge persistent across every chat, every platform, every session.**

Your LLM can help you build it. Share this document with Claude Code, Codex, Cursor, or whatever you use. The pattern is the starting point. The implementation is yours.

---

*Cross-Chat Knowledge Base · v1 · April 2026*
*By Eugene Gordeev · [Labs](https://labs.vc)*
