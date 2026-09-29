# AGENTS.md

Guidance for coding agents working in this repository.

## What this repo is

`mikrolite-images` builds kernel and rootfs images consumed by [Flintlock](https://github.com/liquidmetal-dev/flintlock)-managed microVMs. There is no application source code here — every top-level component directory (`kernel-fc/`, `kernel-k8s-fc/`, `kernel-ch/`, `kernel-k8s-ch/`, `ubuntu/`, `rke2/`) is a Dockerfile + Makefile pair that produces one OCI image, pushed to `ghcr.io/liquidmetal-dev/*`. See [README.md](README.md) for the full breakdown of images and directories.

## Critical invariant: no loadable kernel modules

Every kernel `.config` in this repo (`kernel-fc/`, `kernel-k8s-fc/`, `kernel-ch/`, `kernel-k8s-ch/`) must build required drivers directly into the kernel (`CONFIG_X=y`), never as a loadable module (`CONFIG_X=m`). MicroVMs have no way to load modules at runtime, with or without an initrd, so a `=m` option is silently non-functional at best.

This is enforced in two places — **never bypass either**:

- Each kernel `Dockerfile` greps the merged `.config` for `=m$` and fails the build if it finds one.
- [`hack/check-no-modules.sh`](hack/check-no-modules.sh) runs the same check across every `*.config` file in the repo and is wired into CI via [`.github/workflows/lint-kernel-config.yml`](.github/workflows/lint-kernel-config.yml) on any PR touching a `.config` file.

If a change requires a new kernel option, it must be added as `=y` (or left unset), not `=m`.

## Kernel config conventions

- Base kernel configs (`microvm-kernel-ci-x86_64-*.config`, or the Cloud Hypervisor `linux-config-x86_64`) are fetched from upstream Firecracker/Cloud Hypervisor projects at build time and must not be hand-edited — repo-specific additions live in each component's `configs/` directory (e.g. `configs/additional-61.config`, `configs/k8s_additions.config`). `kernel-k8s-ch/` is the exception: it has no `configs/` directory and keeps its fragments (`k8s_additions.config`, `erofs.config`) at the component root.
- `kernel-k8s-fc/`, `kernel-k8s-ch/` and `kernel-ch/` merge fragments with the kernel's own `scripts/kconfig/merge_config.sh` and then validate that every requested symbol actually survived Kconfig dependency resolution (the Dockerfile fails the build otherwise — `merge_config.sh` only warns).
- `erofs.config` exists once per kernel directory and every copy must be identical. Change all four together; `hack/check-fragments-match.sh` fails in CI when a copy is missing or differs. The lint workflow names each copy, so a new kernel component must be added to that list.
- `kernel-fc/` concatenates its fragments onto the base config with `awk 1` in the `Makefile`, and its `Dockerfile` then checks that every fragment option survived. `awk 1` ends every line with a newline, so a fragment with no final newline cannot fuse with the one after it, as it would with `cat`.
- Upstream config sources are pinned (Firecracker ref, Cloud Hypervisor tag/branch) for reproducibility — check the relevant `Makefile`/`Dockerfile` `ARG`s before changing a pin.

## Version pinning

- `ubuntu/Dockerfile`: `GUEST_AGENT_VERSION` pins the [guest-agent](https://github.com/liquidmetal-dev/guest-agent) `.deb` release, verified against its published `checksums.txt` via `sha256sum -c`. Bumping this version requires updating the `ARG` only — the checksum is fetched, not hardcoded.
- `rke2/Dockerfile`: `RKE2_VERSION` pins the RKE2 release whose artifacts are bundled for airgapped install.
- Kernel builds pin a `KERNEL_VERSION` (tag of `linux-stable`) and a `KERNEL_CONFIG` source per variant; see each component's `Makefile`.

## Kernel image tags

Every kernel build is published as `<short tag>-<BUILD_ID>` (e.g. `6.1-20260929-1432`) and as the short tag (`6.1`). The timestamped tag is permanent; the short tag moves to the newest build. See the README for the full scheme.

- The tagging lives in [`hack/kernel-image.mk`](hack/kernel-image.mk), which every kernel `Makefile` includes. It provides `BUILD_ID`, the `image_tags` and `image_labels` helpers, `record_build_id`, and the `push` target. Do not write tags or a `push` target by hand in a kernel `Makefile`.
- `BUILD_ID` is the UTC build start time, `YYYYMMDD-HHMM`. `make build` writes it to `out/build-id` and `make push` reads it back, because the two are separate runs. The publish workflows resolve it once and export it.
- **Never overwrite a timestamped tag.** [`hack/push-kernel-image.sh`](hack/push-kernel-image.sh) checks the registry before pushing and fails if a timestamped tag exists, or if it cannot tell. Do not bypass or weaken that check.
- A new kernel component must set `TAGS` to the short tags it publishes, include `hack/kernel-image.mk`, end its `build` recipe with `$(record_build_id)`, and ignore `out/`.
- The second argument of `image_labels` is the kernel version label and must match the `KERNEL_VERSION` build arg of the same `docker build`.

## Build and verify

```bash
cd <component>
make build     # docker build
```

There is no test suite beyond the kernel-config lint. Before considering a change complete:

- Run `hack/check-no-modules.sh` if any `.config` file changed.
- Run `docker build` (via `make build`) for the affected component(s) to confirm the image still builds.
- Never run `make push` against `ghcr.io/liquidmetal-dev` to test a change. Set `REGISTRY` to a throwaway registry instead.

## Commit conventions

This repository uses **[Conventional Commits](https://www.conventionalcommits.org/)** (`feat:`, `fix:`, `docs:`, `chore:`, `ci:`, etc.). Write commit messages accordingly, and keep unrelated changes in separate commits.
