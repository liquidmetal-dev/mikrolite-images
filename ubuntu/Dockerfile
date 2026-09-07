ARG UBUNTU_VERSION="24.04"
ARG GUEST_AGENT_VERSION="0.3.0"

FROM ubuntu:${UBUNTU_VERSION}
LABEL org.opencontainers.image.source=https://github.com/liquidmetal-dev/mikrolite-images

# Re-declare so the global ARG is visible in this build stage.
ARG GUEST_AGENT_VERSION

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

# Install the pinned guest-agent (vsock host control + ssh proxy) and enable its
# systemd unit so it starts on boot. The .deb drops the binary to /usr/local/bin and
# the unit to /lib/systemd/system; `systemctl enable` symlinks it into
# multi-user.target.wants (works offline at build time).
RUN cd /tmp && \
    curl -OLsf https://github.com/liquidmetal-dev/guest-agent/releases/download/v${GUEST_AGENT_VERSION}/guest-agent_${GUEST_AGENT_VERSION}_linux_amd64.deb && \
    curl -OLsf https://github.com/liquidmetal-dev/guest-agent/releases/download/v${GUEST_AGENT_VERSION}/checksums.txt && \
    grep " guest-agent_${GUEST_AGENT_VERSION}_linux_amd64.deb\$" checksums.txt | sha256sum -c - && \
    dpkg -i guest-agent_${GUEST_AGENT_VERSION}_linux_amd64.deb && \
    systemctl enable guest-agent.service && \
    rm -f guest-agent_${GUEST_AGENT_VERSION}_linux_amd64.deb checksums.txt
