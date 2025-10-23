ARG UBUNTU_VERSION="24.04"

FROM ubuntu:${UBUNTU_VERSION}
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
