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

git log --format="commit %H%n%aN" --numstat | awk '
    $1 != "commit" && NF == 1 { author = $1 }
    NF == 3 { 
        if (!creators[$3]) {
            creators[$3] = author
            files_created[author]++
        } else if (author != creators[$3]) {
            edits[creators[$3]]++
        }
    }
    END {
        printf "%-40s %10s %10s\n", "Author", "Created", "Other Edits"
        printf "%-40s %10s %10s\n", "------", "-------", "----------"
        for (author in files_created) {
            printf "%-40s, %10d, %10d\n", author, files_created[author], edits[author] + 0
        }
    }' | sort -k2,2nr