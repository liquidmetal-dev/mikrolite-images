ARG RKE2_VERSION="v1.28.3+rke2r1"

FROM ubuntu:22.04
LABEL org.opencontainers.image.source=https://github.com/liquidmetal-dev/mikrolite-images

RUN apt-get update && apt-get install -y \
    kmod \
    dbus \
    iproute2 \
    iputils-ping \
    net-tools \
    openssh-server \
    dnsutils \
    sudo \
    curl \
    cloud-init \
    linux-image-virtual  \
    less \
    udev \
    wget \
    apt-transport-https \
    ca-certificates \
    gnupg2 \
    software-properties-common \
    libseccomp2 \
    systemd \
    jq && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* && \
    sed -i -e 's/^AcceptEnv LANG LC_\*$/#AcceptEnv LANG LC_*/' /etc/ssh/sshd_config

RUN mkdir /root/rke2-artifacts && \
    cd /root/rke2-artifacts && \
    curl -OLs https://github.com/rancher/rke2/releases/download/${RKE2_VERSION}/rke2-images.linux-amd64.tar.zst && \
    curl -OLs https://github.com/rancher/rke2/releases/download/${RKE2_VERSION}/rke2.linux-amd64.tar.gz && \
    curl -OLs https://github.com/rancher/rke2/releases/download/${RKE2_VERSION}/sha256sum-amd64.txt && \
    curl -sfL https://get.rke2.io --output install.sh

# To run the install: INSTALL_RKE2_ARTIFACT_PATH=/root/rke2-artifacts sh install.sh