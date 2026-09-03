FROM ubuntu:24.04 AS builder

RUN apt-get update -y && \
    apt-get install -y --no-install-recommends \
    python3 bc binutils bison dwarves flex gcc git gnupg2 gzip libelf-dev libncurses5-dev libssl-dev make openssl pahole perl-base rsync tar xz-utils

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

COPY ${KERNEL_CONFIG} .config

RUN make LOCALVERSION= olddefconfig

# Fail the build if any option is enabled as a loadable module: microVM
# images boot with no initrd/module filesystem, so a modular option is
# silently non-functional.
RUN if grep -E '=m$' .config; then \
      echo "ERROR: kernel modules enabled above — all options must be y or disabled for microVM images" >&2; \
      exit 1; \
    fi

RUN make LOCALVERSION= -j32

RUN cp vmlinux /boot/vmlinux && \
    cp .config /boot/config-${KERNEL_VERSION}.0

FROM scratch
LABEL org.opencontainers.image.source=https://github.com/liquidmetal-dev/mikrolite-images
COPY --from=builder /boot /boot