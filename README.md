# mikrolite-images

Kernel and rootfs images for microVMs, built for [Flintlock](https://github.com/liquidmetal-dev/flintlock) / the Liquidmetal microVM stack.

[![Kernel (FC) - Build and publish](https://github.com/liquidmetal-dev/mikrolite-images/actions/workflows/kernel-firecracker.yml/badge.svg)](https://github.com/liquidmetal-dev/mikrolite-images/actions/workflows/kernel-firecracker.yml)
[![Kernel for k8s (FC) - Build and publish](https://github.com/liquidmetal-dev/mikrolite-images/actions/workflows/kernel-firecracker-k8s.yml/badge.svg)](https://github.com/liquidmetal-dev/mikrolite-images/actions/workflows/kernel-firecracker-k8s.yml)
[![Kernel (CH) - Build and publish](https://github.com/liquidmetal-dev/mikrolite-images/actions/workflows/kernel-cloudhypervisor.yml/badge.svg)](https://github.com/liquidmetal-dev/mikrolite-images/actions/workflows/kernel-cloudhypervisor.yml)
[![Kernel for k8s (CH) - Build and publish](https://github.com/liquidmetal-dev/mikrolite-images/actions/workflows/kernel-cloudhypervisor-k8s.yml/badge.svg)](https://github.com/liquidmetal-dev/mikrolite-images/actions/workflows/kernel-cloudhypervisor-k8s.yml)
[![Ubuntu - Build and publish](https://github.com/liquidmetal-dev/mikrolite-images/actions/workflows/ubuntu.yml/badge.svg)](https://github.com/liquidmetal-dev/mikrolite-images/actions/workflows/ubuntu.yml)
[![RKE2 - Build and publish](https://github.com/liquidmetal-dev/mikrolite-images/actions/workflows/rke2.yml/badge.svg)](https://github.com/liquidmetal-dev/mikrolite-images/actions/workflows/rke2.yml)
[![Lint kernel configs - No modules](https://github.com/liquidmetal-dev/mikrolite-images/actions/workflows/lint-kernel-config.yml/badge.svg)](https://github.com/liquidmetal-dev/mikrolite-images/actions/workflows/lint-kernel-config.yml)
[![License: Apache-2.0](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](LICENSE)

> The six "Build and publish" workflows above are triggered manually (`workflow_dispatch`) rather than on every push, so their badges reflect the result of the last manual run, not continuous build status. The "Lint kernel configs" workflow runs automatically on every pull request that touches a `.config` file.

## Overview

This repository builds the kernel and root filesystem images consumed by [Flintlock](https://github.com/liquidmetal-dev/flintlock)-managed microVMs. It does not contain a runnable application — it is a collection of Dockerfiles and Makefiles that each produce one OCI image, published to `ghcr.io/liquidmetal-dev/*`, which Flintlock then uses as the kernel and/or disk image source when creating a microVM.

Images are built for two hypervisors:

- **[Firecracker](https://firecracker-microvm.github.io/)** (`kernel-fc`, `kernel-k8s-fc`)
- **[Cloud Hypervisor](https://www.cloudhypervisor.org/)** (`kernel-ch`, `kernel-k8s-ch`)

and two rootfs flavours:

- A general-purpose **Ubuntu** guest image with the [guest-agent](https://github.com/liquidmetal-dev/guest-agent) pre-installed
- An **airgapped RKE2** node image, bundling RKE2 install artifacts for offline Kubernetes node bootstrap

## Why the kernels have no loadable modules

MicroVMs booted by Flintlock have no mechanism to load kernel modules at runtime. Most boot straight into the kernel with no initrd. Flintlock's overlay volume mode boots with an initrd that Flintlock provides, and that initrd carries no modules either. Every driver a guest needs (virtio, networking, filesystem, etc.) must therefore be **built directly into the kernel** (`=y`), not built as a loadable module (`=m`).

This invariant is enforced twice:

- At **build time**, each kernel `Dockerfile` fails the build if the merged kernel `.config` contains any `=m` line.
- In **CI**, [`hack/check-no-modules.sh`](hack/check-no-modules.sh) runs against every `*.config` file in the repo and is wired into [`lint-kernel-config.yml`](.github/workflows/lint-kernel-config.yml), which runs on any pull request touching a `.config` file.

## Images

| Directory | Image | Description |
|---|---|---|
| [`kernel-fc/`](kernel-fc) | `ghcr.io/liquidmetal-dev/firecracker-kernel` | Bare Firecracker-compatible kernel. Builds three variants: `6.1`, `5.10`, `5.10-no-acpi`. |
| [`kernel-k8s-fc/`](kernel-k8s-fc) | `ghcr.io/liquidmetal-dev/firecracker-kernel-k8s` | Firecracker kernel with additional netfilter/IPVS/bridge config needed for Kubernetes nodes (`kube-proxy`, CNI). Variants: `6.1`, `5.10`. |
| [`kernel-ch/`](kernel-ch) | `ghcr.io/liquidmetal-dev/cloudhypervisor-kernel` | Bare Cloud Hypervisor kernel (`6.2`) plus a matching `6.2-headers` image. |
| [`kernel-k8s-ch/`](kernel-k8s-ch) | `ghcr.io/liquidmetal-dev/cloudhypervisor-kernel-k8s` | Cloud Hypervisor kernel (`6.2`) with the same Kubernetes networking config additions as `kernel-k8s-fc`. |
| [`ubuntu/`](ubuntu) | `ghcr.io/liquidmetal-dev/ubuntu` | Ubuntu `24.04` rootfs with networking, systemd and cloud-init configured, and [guest-agent](https://github.com/liquidmetal-dev/guest-agent) installed and enabled as a systemd service. |
| [`rke2/`](rke2) | `ghcr.io/liquidmetal-dev/node-rke2-airgapped` | Ubuntu `22.04`-based RKE2 node rootfs, pre-loaded with RKE2 release artifacts for airgapped/offline installation. |

Each kernel image is built from real upstream `linux-stable` source, using kernel `.config`s sourced from the Firecracker/Cloud Hypervisor projects and merged with the additional config fragments in each directory's `configs/` folder.

Every kernel also gets the `erofs.config` fragment, which enables the EROFS filesystem. Flintlock's overlay volume mode presents the root filesystem as a read-only EROFS image. The fragment is copied into each kernel directory because each directory is its own docker build context; [`hack/check-fragments-match.sh`](hack/check-fragments-match.sh) fails the lint when a copy is missing or the copies differ.

## Building locally

Every component follows the same `make` interface:

```bash
cd <component>       # e.g. ubuntu, kernel-fc, rke2, ...
make build            # docker build
make push             # docker push
```

The target registry defaults to `ghcr.io/liquidmetal-dev` and can be overridden:

```bash
make build REGISTRY=my-registry.example.com
```

Docker (with buildx) is the only required tool — kernel builds compile the actual Linux kernel inside the build container, so expect kernel-image builds to take a while.

## Repository layout

```
kernel-fc/          Bare Firecracker kernel (6.1, 5.10, 5.10-no-acpi)
kernel-k8s-fc/       Firecracker kernel with Kubernetes networking config
kernel-ch/           Bare Cloud Hypervisor kernel (6.2)
kernel-k8s-ch/       Cloud Hypervisor kernel with Kubernetes networking config
ubuntu/              Ubuntu rootfs image with guest-agent
rke2/                Airgapped RKE2 node rootfs image
hack/                Repo-wide dev/CI scripts (e.g. check-no-modules.sh)
.github/workflows/   CI: per-image build-and-publish workflows, kernel-config lint
```

## License

Apache License 2.0, see [LICENSE](LICENSE).
