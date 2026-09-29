#!/usr/bin/env bash
# Pushes the tags of a kernel image build: for each short tag, the timestamped
# tag (<short tag>-<build id>) and then the short tag itself. Fails before
# pushing anything if a timestamped tag is already in the registry, so that a
# published build is never replaced.
set -euo pipefail

if [ "$#" -lt 3 ]; then
  echo "usage: $0 <image> <build-id> <short-tag> [short-tag ...]" >&2
  exit 2
fi

image=$1
build_id=$2
shift 2

if [ -z "$build_id" ]; then
  echo "ERROR: no build id. Run make build first, or set BUILD_ID" >&2
  exit 1
fi

rc=0
for tag in "$@"; do
  ref="$image:$tag-$build_id"
  if out=$(docker buildx imagetools inspect "$ref" 2>&1); then
    echo "ERROR: $ref is already published. Rebuild to get a new build id" >&2
    rc=1
  elif ! echo "$out" | grep -qE ': not found$'; then
    # Anything other than "not there" leaves it unknown whether the tag
    # exists, so do not push over it.
    echo "ERROR: could not check whether $ref is published:" >&2
    echo "$out" >&2
    rc=1
  fi
done
[ "$rc" -eq 0 ] || exit "$rc"

for tag in "$@"; do
  docker push "$image:$tag-$build_id"
done

for tag in "$@"; do
  docker push "$image:$tag"
done
