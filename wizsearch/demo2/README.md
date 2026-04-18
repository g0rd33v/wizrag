# WizSearch Demo 2 — Berkshire Hathaway Shareholder Letters

A WizSearch knowledge base built from Warren Buffett's annual shareholder letters to Berkshire Hathaway shareholders, spanning 1977 to 2025 — nearly five decades of investment wisdom, business philosophy, and candid commentary.

## Source

All letters are sourced from [berkshirehathaway.com/letters](https://www.berkshirehathaway.com/letters/letters.html).

- **1977–2000:** Originally published as HTML
- **2001–2025:** Published as PDF

## Structure

```
demo2/
├── README.md
├── letters/
│   ├── 1977.md
│   ├── 1978.md
│   ├── ...
│   └── 2025.md
├── wizsearch.html
└── wizindex.json
```

Each letter is stored as a standalone Markdown file named by year. The WizSearch index covers all letters with topics spanning investment philosophy, insurance operations, acquisitions, market commentary, corporate governance, and more.

## Building the Index

To rebuild the WizSearch index after adding or updating letters:

1. Drop `wiz.zip` (from the [WizSearch bundle](https://github.com/g0rd33v/wizrag/tree/main/wizsearch)) into any LLM chat
2. Point it at this folder
3. The LLM will scan all `.md` files in `letters/`, build the index, and output `wizsearch.html` and `wizindex.json`

## Letter Download Script

To download all letters from berkshirehathaway.com and convert to markdown:

```bash
#!/bin/bash
# Run this in the letters/ directory

# HTML letters (1977-2000)
for year in $(seq 1977 2000); do
  curl -s "https://www.berkshirehathaway.com/letters/${year}.html" | \
    pandoc -f html -t markdown -o "${year}.md" 2>/dev/null || \
    python3 -c "
import urllib.request, html2text
url = 'https://www.berkshirehathaway.com/letters/${year}.html'
data = urllib.request.urlopen(url).read().decode('utf-8', errors='replace')
h = html2text.HTML2Text()
h.ignore_links = False
print(h.handle(data))
" > "${year}.md"
  echo "Downloaded ${year}"
done

# PDF letters (2001-2025)
for year in $(seq 2001 2025); do
  curl -s "https://www.berkshirehathaway.com/letters/${year}ltr.pdf" -o "${year}.pdf"
  # Extract text (requires pdftotext from poppler-utils)
  pdftotext "${year}.pdf" "${year}.md" 2>/dev/null
  rm "${year}.pdf"
  echo "Downloaded ${year}"
done
```

Alternatively, use Claude Code:
```
claude "Download all Berkshire Hathaway shareholder letters from berkshirehathaway.com/letters/ (1977-2025), convert to markdown, save in the letters/ folder"
```

## Live Demo

Once GitHub Pages is enabled:
**https://g0rd33v.github.io/wizrag/wizsearch/demo2/wizsearch.html**

---

*Part of the [WizRAG](https://github.com/g0rd33v/wizrag) project by [Eugene Gordeev](https://x.com/egordeev).*
