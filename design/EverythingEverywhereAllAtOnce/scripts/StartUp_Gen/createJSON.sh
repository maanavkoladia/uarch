#!/bin/bash

input=$(cat)

echo "$input" \
| sed -E 's/([A-Za-z_]+):/"\1":/g; s#:[[:space:]]*([^",}]+)#:"\1"#g' \
| sed -E 's/"([^"]*[^[:space:]])[[:space:]]+"/"\1"/g' \
| sed 's#//#/#g' \
| jq .
