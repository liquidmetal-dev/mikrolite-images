FROM ubuntu:22.04 AS builder

RUN apt-get update -y && \
    apt-get install -y --no-install-recommends \
    bc                  \
    bison               \
    build-essential     \
    gcc                 \
    flex                \
    git                 \
    libelf-dev          \
    libncurses-dev      \
    libssl-dev          \
    ca-certificates     \
    kmod                \
    curl                \
    wget

ENV SRC_DIR=/usr/src            \
    DIST_DIR=/dist              \
    LINUX_DIR=/usr/src/linux    \
    LINUX_REPO_URL=git://git.kernel.org/pub/scm/linux/kernel/git/stable/linux-stable.git


ARG KERNEL_VERSION

RUN mkdir -p ${SRC_DIR} ${DIST_DIR} && \
    git clone --depth 1 --branch v${KERNEL_VERSION} ${LINUX_REPO_URL} ${LINUX_DIR} && \
    cd ${LINUX_DIR}

WORKDIR ${LINUX_DIR}

ARG KERNEL_CONFIG
ARG KERNEL_FRAGMENTS

COPY ${KERNEL_CONFIG} .config
COPY configs/ /tmp/k8s-configs/

# Merge the k8s fragment(s) onto the base config, then let Kconfig resolve
# dependencies deterministically.
RUN set -eu; frags=""; for f in ${KERNEL_FRAGMENTS}; do frags="$frags /tmp/k8s-configs/$f"; done; \
    ./scripts/kconfig/merge_config.sh -m .config $frags \
 && make LOCALVERSION= olddefconfig

# Fail the build if any requested option did not survive dependency resolution
# (merge_config.sh only warns on drops).
RUN set -eu; rc=0; \
    for f in ${KERNEL_FRAGMENTS}; do \
      while IFS= read -r line || [ -n "$line" ]; do \
        case "$line" in ''|\#*) continue;; esac; \
        sym=${line%%=*}; val=${line#*=}; \
        if [ "$val" = n ]; then want="# $sym is not set"; else want="$line"; fi; \
        if ! grep -qxF "$want" .config; then \
          echo "DROPPED: wanted [$want] got [$(grep -w "$sym" .config || echo absent)]"; rc=1; \
        fi; \
      done < /tmp/k8s-configs/$f; \
    done; \
    [ "$rc" -eq 0 ] || { echo 'ERROR: fragment options did not survive the config merge'; exit 1; }

# Fail the build if any option is enabled as a loadable module: microVM
# images boot with no initrd/module filesystem, so a modular option is
# silently non-functional.
RUN if grep -E '=m$' .config; then \
      echo "ERROR: kernel modules enabled above — all options must be y or disabled for microVM images" >&2; \
      exit 1; \
    fi

RUN make LOCALVERSION= -j$(nproc)


RUN cp vmlinux /boot/vmlinux && \
    cp .config /boot/config-${KERNEL_VERSION}.0

FROM scratch
LABEL org.opencontainers.image.source=https://github.com/liquidmetal-dev/mikrolite-images
COPY --from=builder /boot /