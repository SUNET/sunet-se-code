#!/bin/bash

DIRECTORY=$1

find "$DIRECTORY" -type f -name "*.md" | while IFS= read -r file; do
    # Skip files that already have front matter delimiters
    if head -n 1 "$file" | grep -q '^---$'; then
        continue
    fi
    awk '
    BEGIN {print "---"; inParagraph=1}
    /^$/ && inParagraph {print "---\n"; inParagraph=0; next}
    {print}
    ' "$file" > tmpfile && mv tmpfile "$file"
done
