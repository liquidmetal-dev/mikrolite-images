#!/usr/bin/env bash
# Fails if a copy of a kernel config fragment is missing or the copies
# differ. Each kernel component is its own docker build context, so a
# fragment that every component needs has to be copied into each one.
set -euo pipefail

if [ "$#" -lt 2 ]; then
  echo "usage: $0 <fragment> <fragment> [fragment ...]" >&2
  exit 2
fi

rc=0
for f in "$@"; do
  if [ ! -f "$f" ]; then
    echo "ERROR: $f is missing"
    rc=1
  fi
done
[ "$rc" -eq 0 ] || exit "$rc"

first=$1
shift

for f in "$@"; do
  if ! cmp -s "$first" "$f"; then
    echo "ERROR: $f differs from $first"
    diff -u "$first" "$f" || true
    rc=1
  fi
done

exit "$rc"
