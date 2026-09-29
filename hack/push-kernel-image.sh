#!/usr/bin/env bash
# Pushes the tags of a kernel image build: for each short tag, the timestamped
# tag (<short tag>-<build id>) and then the short tag itself.
#
# A timestamped tag that is already in the registry is never pushed again. If
# it holds the image that is about to be pushed, it is skipped, so that a push
# that failed part way can be run again. If it holds anything else, or the
# registry cannot be asked, nothing is pushed at all.
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

# Prints the id of the local image $1, or nothing if there is none.
local_image_id() {
  docker image inspect "$1" --format '{{.Id}}' 2>/dev/null || true
}

# Succeeds if the local image $1 has the digest $2.
local_image_has_digest() {
  local digests
  digests=$(docker image inspect "$1" \
    --format '{{range .RepoDigests}}{{println .}}{{end}}' 2>/dev/null) || return 1
  grep -qxF "$image@$2" <<<"$digests"
}

to_push=()
rc=0
for tag in "$@"; do
  ref="$image:$tag-$build_id"

  id=$(local_image_id "$ref")
  if [ -z "$id" ]; then
    echo "ERROR: there is no local image $ref. Run make build first" >&2
    rc=1
    continue
  fi
  # The short tag is pushed as it is locally, so it has to be this build.
  if [ "$(local_image_id "$image:$tag")" != "$id" ]; then
    echo "ERROR: the local $image:$tag is not the build $build_id." \
      "Rebuild to get a new build id" >&2
    rc=1
    continue
  fi

  if out=$(docker buildx imagetools inspect "$ref" --format '{{.Manifest.Digest}}' 2>&1); then
    if ! [[ "$out" =~ ^sha256:[0-9a-f]{64}$ ]]; then
      echo "ERROR: could not read the digest of $ref in the registry:" >&2
      echo "$out" >&2
      rc=1
    elif local_image_has_digest "$ref" "$out"; then
      echo "$ref is already published from this build, skipping"
    else
      echo "ERROR: $ref is already published and is not this build ($out)." \
        "Rebuild to get a new build id" >&2
      rc=1
    fi
  elif ! grep -qE ': not found$' <<<"$out"; then
    # Anything other than "not there" leaves it unknown whether the tag
    # exists, so do not push over it.
    echo "ERROR: could not check whether $ref is published:" >&2
    echo "$out" >&2
    rc=1
  else
    to_push+=("$ref")
  fi
done
[ "$rc" -eq 0 ] || exit "$rc"

for ref in ${to_push[@]+"${to_push[@]}"}; do
  docker push "$ref"
done

for tag in "$@"; do
  docker push "$image:$tag"
done
