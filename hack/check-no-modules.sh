#!/usr/bin/env bash
# Fails if any of the given kernel config fragment files enable an option as
# a loadable module (=m). microVM images boot with no initrd/module
# filesystem, so a modular option is silently non-functional.
set -euo pipefail

if [ "$#" -eq 0 ]; then
  echo "usage: $0 <config-file> [config-file ...]" >&2
  exit 2
fi

rc=0
for f in "$@"; do
  matches=$(grep -nE '=m$' "$f" || true)
  if [ -n "$matches" ]; then
    echo "$matches" | while IFS= read -r line; do
      echo "ERROR: kernel module enabled in $f:$line"
    done
    rc=1
  fi
done

exit "$rc"
