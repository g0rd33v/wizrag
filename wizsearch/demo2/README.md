# WizSearch Demo 2 — Berkshire Hathaway Shareholder Letters

A WizSearch knowledge base built from Warren Buffett's annual shareholder letters to Berkshire Hathaway shareholders, spanning 1977 through 2025 — nearly five decades of investment wisdom, business philosophy, and candid commentary.

## Source

All letters are sourced from [berkshirehathaway.com/letters](https://www.berkshirehathaway.com/letters/letters.html).

- **1977–2024:** Warren Buffett, Chairman and CEO
- **2025:** Gregory E. Abel, CEO (Warren Buffett continues as Chairman)

## Structure

```
demo2/
├── README.md
└── letters/
    ├── 1977.md
    ├── 1978.md
    ├── ...
    └── 2025.md
```

49 letters total, each stored as a standalone Markdown file named by the year the letter covers.

## Building the Index

To generate `wizsearch.html` and `wizindex.json` for this collection:

1. Download `wiz.zip` from the [WizSearch bundle](https://github.com/g0rd33v/wizrag/tree/main/wizsearch)
2. Drop it into any LLM chat with access to this folder
3. Point the LLM at the `letters/` folder
4. The LLM will scan all `.md` files, build the index, and output the two WizSearch files

Once built and pushed, the live search page will be available at:
**https://g0rd33v.github.io/wizrag/wizsearch/demo2/wizsearch.html**

---

*Part of the [WizRAG](https://github.com/g0rd33v/wizrag) project by [Eugene Gordeev](https://x.com/egordeev).*
