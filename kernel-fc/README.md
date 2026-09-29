# Kernel images

This creates bare Firecracker-compatible kernel images. `make build` (or the individual `build-61`, `build-5-10`, `build-5-10-no-acpi` targets) produces three variants, each pushed as a separate image tag:

- **6.1** — built from `microvm-kernel-ci-x86_64-6.1.config` merged with `configs/additional-61.config` (adds `CONFIG_PCI=y`) and `configs/erofs.config`
- **5.10** — built from `microvm-kernel-ci-x86_64-5.10.config` merged with `configs/erofs.config`
- **5.10-no-acpi** — built from `microvm-kernel-ci-x86_64-5.10-no-acpi.config` merged with `configs/erofs.config`

Each variant is published under that tag, which moves to the newest build, and under a timestamped tag such as `6.1-20260929-1432`, which does not. See [Kernel image tags](../README.md#kernel-image-tags).

A couple of things to note:

- modules are disabled — every kernel `.config` here must build all required drivers directly into the kernel (`=y`), not as loadable modules (`=m`), since microVMs have no way to load modules at runtime. This is enforced both by the `Dockerfile` and by [`hack/check-no-modules.sh`](../hack/check-no-modules.sh) in CI.
- The `microvm-kernel-ci-x86_64-*.config` files come from the supported kernel configs published by Firecracker from [here](https://github.com/firecracker-microvm/firecracker/tree/main/resources/guest_configs).
- These downloaded configs are fetched into `out/` (gitignored) at build time and shouldn't be modified in any way — repo-specific additions live in `configs/`.

