#!/bin/bash
# Download all Berkshire Hathaway shareholder letters
# Run from the demo2/ directory

set -e
mkdir -p letters
cd letters

echo "=== Downloading HTML letters (1977-2000) ==="
for year in $(seq 1977 2000); do
  if [ ! -f "${year}.md" ]; then
    curl -s "https://www.berkshirehathaway.com/letters/${year}.html" | \
      python3 -c "
import sys, re
html = sys.stdin.read()
# Strip HTML tags, keep text
text = re.sub(r'<[^>]+>', '', html)
# Clean up whitespace
text = re.sub(r'\n\s*\n\s*\n+', '\n\n', text)
text = text.strip()
# Add header
print(f'# Berkshire Hathaway — Chairman'\''s Letter, ${year}\n')
print(text)
print(f'\n---\n*Source: berkshirehathaway.com/letters/${year}.html*')
" > "${year}.md"
    echo "  ${year} ✓"
  else
    echo "  ${year} (exists, skipping)"
  fi
done

echo ""
echo "=== Downloading PDF letters (2001-2025) ==="
for year in $(seq 2001 2025); do
  if [ ! -f "${year}.md" ]; then
    curl -s "https://www.berkshirehathaway.com/letters/${year}ltr.pdf" -o "/tmp/${year}.pdf"
    if command -v pdftotext &> /dev/null; then
      pdftotext -layout "/tmp/${year}.pdf" - | python3 -c "
import sys
text = sys.stdin.read().strip()
print(f'# Berkshire Hathaway — Chairman'\''s Letter, ${year}\n')
print(text)
print(f'\n---\n*Source: berkshirehathaway.com/letters/${year}ltr.pdf*')
" > "${year}.md"
    else
      echo "  WARNING: pdftotext not found. Install poppler-utils."
      echo "  Saving raw PDF for ${year}"
    fi
    rm -f "/tmp/${year}.pdf"
    echo "  ${year} ✓"
  else
    echo "  ${year} (exists, skipping)"
  fi
done

echo ""
echo "=== Done ==="
ls -la *.md | wc -l
echo "letters downloaded"
