#!/bin/bash

if [ $# -ne 1 ]; then
    echo "Usage: $0 <git-repository-path>"
    exit 1
fi

cd "$1" || exit 1

if ! git rev-parse --git-dir > /dev/null 2>&1; then
    echo "Error: Not a git repository"
    exit 1
fi

# Process all changes in one pass using awk to track authors and edits
git log --format="commit %H%n%aN" --numstat | awk '
    $1 != "commit" && NF == 1 { author = $1 }
    NF == 3 { 
        if (!creators[$3]) {
            creators[$3] = author
        } else if (author != creators[$3]) {
            edits[$3]++
        }
    }
    END {
        for (file in edits) {
            printf "%d\n", edits[file]
        }
    }' | sort -n | uniq -c