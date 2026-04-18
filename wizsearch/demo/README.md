# WizSearch Demo — Anthropic Skills

This folder contains a working WizSearch demo built against [`anthropics/skills`](https://github.com/anthropics/skills) — Anthropic's official Agent Skills repository.

## Live URL

**https://g0rd33v.github.io/wizrag/wizsearch/demo/wizsearch.html**

## What This Demonstrates

WizSearch indexed 84 markdown files from the Anthropic skills repo into 762 chunks across 10 topics — completely automatically by Claude reading the BUILD INSTRUCTIONS embedded in `wizsearch.html`. No code was written. The result is a fully queryable knowledge base served as two static files on GitHub Pages.

## Try These Queries

Paste the demo URL into any AI chat (Claude, ChatGPT, Grok, Perplexity) and ask questions like:

- *How do I create a Claude skill?*
- *What's the difference between the docx and pdf skills?*
- *Show me how to use the Claude API with Python*
- *How do I build an MCP server?*
- *What does the skill-creator skill do?*

Or use the URL parameter for direct queries:

- [Skill authoring](https://g0rd33v.github.io/wizrag/wizsearch/demo/wizsearch.html?q=skill+authoring)
- [MCP server](https://g0rd33v.github.io/wizrag/wizsearch/demo/wizsearch.html?q=mcp+server)
- [Claude API streaming](https://g0rd33v.github.io/wizrag/wizsearch/demo/wizsearch.html?q=streaming)
- [Document creation](https://g0rd33v.github.io/wizrag/wizsearch/demo/wizsearch.html?q=document+creation)

## How It Was Built

1. Cloned [`anthropics/skills`](https://github.com/anthropics/skills) locally
2. Dropped `wiz.zip` into a Claude chat with access to the cloned folder
3. Asked: "Index this repo using the BUILD INSTRUCTIONS in wizsearch.html"
4. Claude scanned 84 files, chunked them into 762 segments, clustered into 10 topics, generated both files
5. Source links rewritten to point to the canonical GitHub URLs at `github.com/anthropics/skills`
6. Committed both files here

Total time: about 3 minutes.

## Three Visitor Types Supported

This single page serves three audiences from the same URL:

1. **Humans** — use the search box, click topic links to source files on GitHub
2. **Browser agents** (Claude in Chrome) — use the search box automatically
3. **Raw-fetch LLMs** (Claude web fetch, ChatGPT browsing) — read the topic index in the static HTML and follow source links to canonical Anthropic files

## Source Attribution

All indexed content is from [`anthropics/skills`](https://github.com/anthropics/skills), licensed under Apache 2.0 (see [LICENSE](https://github.com/anthropics/skills/blob/main/LICENSE)). This demo only contains the index and search interface — all source documents remain at their canonical location on GitHub.

## License

The WizSearch interface (`wizsearch.html`) is MIT licensed. The indexed content is owned by Anthropic and remains under its original Apache 2.0 license.

---

*WizSearch is a [Labs](https://labs.vc) project. Get the build kit at [github.com/g0rd33v/wizrag](https://github.com/g0rd33v/wizrag).*
