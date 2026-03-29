#!/bin/bash

echo "Starting to Clean"

genPath=$1

if [ -z "$genPath" ]; then
    echo "Usage: $0 <directory>"
    exit 1
fi

shopt -s nullglob

for file in "$genPath"/*; do
    [ -f "$file" ] || continue

    sed -i \
        -e 's/\t/,,/g' \
        -e 's/,,/,/g' \
        -e '/,,,/d' "$file"
done

echo "Done Cleaning"
