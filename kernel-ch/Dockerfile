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
    rsync               \
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

RUN curl -L -o .config ${KERNEL_CONFIG}
#RUN make LOCALVERSION= -j32
RUN KCFLAGS="-Wa,-mx86-used-note=no" make bzImage -j32

RUN mkdir output
RUN cp arch/x86/boot/compressed/vmlinux.bin ./output/vmlinux.bin&& \
    cp .config ./output/config-${KERNEL_VERSION}.0

RUN mkdir output_headers
RUN make LOCALVERSION= headers_install INSTALL_HDR_PATH=./output_headers/linux-headers-${KERNEL_VERSION}.0

FROM scratch AS kernel
LABEL org.opencontainers.image.source=https://github.com/liquidmetal-dev/mikrolite-images
COPY --from=builder /usr/src/linux/output   /

FROM scratch AS headers
LABEL org.opencontainers.image.source=https://github.com/liquidmetal-dev/mikrolite-images
COPY --from=builder /usr/src/linux/output_headers  /
