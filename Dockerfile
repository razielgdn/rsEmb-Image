# This Dockerfile sets up a Debian-based environment for building Yocto projects for Raspberry Pi on ARM64 architecture.

FROM debian:12-slim
# Configure timezone
ENV TZ="America/Monterrey"
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Install dependencies
# Yocto official documentation recommends: https://docs.yoctoproject.org/brief-yoctoprojectqs/index.html
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    chrpath \
    cpio \
    debianutils \
    diffstat \
    file \
    gawk \
    gcc \
    git \
    iputils-ping \
    libacl1 \
    locales \
    python3 \
    python3-git \
    python3-jinja2 \
    python3-pexpect \
    python3-pip \
    python3-subunit \
    socat \
    sudo \
    texinfo \
    unzip \
    wget \
    zutils \
    lz4 \
    zstd \
    xz-utils \
    python3-yaml \
    ca-certificates \
    curl \
    && rm -rf /var/lib/apt/lists/* \
    && apt-get clean

# Yocto documentation recommends setting UTF-8 locale
RUN sed -i '/en_US.UTF-8/s/^# //' /etc/locale.gen && locale-gen
ENV LANG=en_US.UTF-8 LANGUAGE=en_US:en LC_ALL=en_US.UTF-8

# Install BitBake
RUN git clone --branch 2.16 https://git.openembedded.org/bitbake/ /opt/yocto/bitbake
ENV PATH="/opt/yocto/bitbake/bin:${PATH}"

# Configure user
ARG USERNAME=yocto
ARG USER_UID=1000
ARG USER_GID=$USER_UID
RUN groupadd --gid ${USER_GID} ${USERNAME} \
    && useradd --uid ${USER_UID} --gid ${USER_GID} -m ${USERNAME}

# Allow yocto user to run sudo without password for volume permission fixes
RUN echo "${USERNAME} ALL=(ALL) NOPASSWD: /bin/chown" >> /etc/sudoers.d/${USERNAME} \
    && chmod 0440 /etc/sudoers.d/${USERNAME}

# Create volume directories and ensure proper permissions
RUN mkdir -p /home/yocto/downloads /home/yocto/sstate-cache /home/yocto/tmp \
    && chown -R ${USER_UID}:${USER_GID} /home/yocto

# Switch to the user
USER ${USERNAME}

# Set up workspace
WORKDIR /home/${USERNAME}/workspace

CMD ["/bin/bash"]