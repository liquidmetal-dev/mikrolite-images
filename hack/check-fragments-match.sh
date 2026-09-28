#!/usr/bin/env bash
# Fails if the copies of a kernel config fragment differ. Each kernel
# component is its own docker build context, so a fragment that every
# component needs has to be copied into each one.
set -euo pipefail

if [ "$#" -lt 2 ]; then
  echo "usage: $0 <fragment> <fragment> [fragment ...]" >&2
  exit 2
fi

first=$1
shift

rc=0
for f in "$@"; do
  if ! cmp -s "$first" "$f"; then
    echo "ERROR: $f differs from $first"
    diff -u "$first" "$f" || true
    rc=1
  fi
done

exit "$rc"
