# Kernel images

This creates Firecracker-compatible kernel images suitable for running Kubernetes nodes. `make build` produces two variants, each pushed as a separate image tag:

- **6.1** — built from `microvm-kernel-ci-x86_64-6.1.config`, merged with `configs/additional-61.config`, `configs/k8s_additions.config` and `configs/erofs.config`
- **5.10** — built from `microvm-kernel-ci-x86_64-5.10.config`, merged with `configs/k8s_additions.config` and `configs/erofs.config`

Each variant is published under that tag, which moves to the newest build, and under a timestamped tag such as `6.1-20260929-1432`, which does not. See [Kernel image tags](../README.md#kernel-image-tags).

A couple of things to note:

- modules are disabled — every kernel `.config` here must build all required drivers directly into the kernel (`=y`), not as loadable modules (`=m`), since microVMs have no way to load modules at runtime. This is enforced both by the `Dockerfile` and by [`hack/check-no-modules.sh`](../hack/check-no-modules.sh) in CI.
- The `microvm-kernel-ci-x86_64-*.config` files come from the supported kernel configs published by Firecracker from [here](https://github.com/firecracker-microvm/firecracker/tree/main/resources/guest_configs), pinned to a specific Firecracker ref (`FIRECRACKER_REF` in the `Makefile`) for reproducibility, and shouldn't be modified in any way.
- Additional config required for Kubernetes (netfilter, IPVS, bridge networking) is added via **configs/k8s_additions.config**.
- The **scripts/kconfig/merge_config.sh** script is used to merge the config files, and the build also validates that every requested config symbol actually made it into the final `.config` (i.e. no dependency-resolution drops).
