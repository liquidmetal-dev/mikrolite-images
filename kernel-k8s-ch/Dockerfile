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

RUN curl -fL -o .config ${KERNEL_CONFIG}
COPY k8s_additions.config k8s_additions-fragment
# Merge fragment into base, then let Kconfig resolve dependencies
RUN ./scripts/kconfig/merge_config.sh -m .config k8s_additions-fragment \
 && make LOCALVERSION= olddefconfig
# Fail the build if any requested k8s symbol did not survive dependency resolution
RUN set -eu; rc=0; \
    while IFS= read -r line; do \
      case "$line" in ''|\#*) continue;; esac; \
      sym=${line%%=*}; val=${line#*=}; \
      if [ "$val" = n ]; then want="# $sym is not set"; else want="$line"; fi; \
      if ! grep -qxF "$want" .config; then \
        echo "DROPPED: wanted [$want] got [$(grep -w "$sym" .config || echo absent)]"; rc=1; \
      fi; \
    done < k8s_additions-fragment; \
    [ "$rc" -eq 0 ] || { echo 'ERROR: k8s options did not survive the config merge'; exit 1; }
RUN KCFLAGS="-Wa,-mx86-used-note=no" make LOCALVERSION= bzImage -j$(nproc)

RUN mkdir output
RUN cp arch/x86/boot/compressed/vmlinux.bin ./output/vmlinux.bin&& \
    cp .config ./output/config-${KERNEL_VERSION}.0

FROM scratch
LABEL org.opencontainers.image.source=https://github.com/liquidmetal-dev/mikrolite-images
COPY --from=builder /usr/src/linux/output   /
