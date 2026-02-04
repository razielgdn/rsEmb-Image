# This Dockerfile sets up a Debian-based environment for building Yocto projects for Raspberry Pi on ARM64 architecture.

FROM debian:trixie-slim
# Configure timezone
ENV TZ="America/Monterrey"
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Install dependencies
# Yocto offcial documentation remends: https://docs.yoctoproject.org/brief-yoctoprojectqs/index.html
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
    texinfo \
    unzip \
    wget \
    xz-utils \
    python3-yaml \
    ca-certificates \
    curl \
    && rm -rf /var/lib/apt/lists/* \
    && apt-get clean
# Yocto documentation recomends to set locale to UTF-8 locale  enable: 
#--all-locales | grep en_US.utf8
RUN sed -i '/en_US.UTF-8/s/^# //' /etc/locale.gen && locale-gen
ENV LANG=en_US.UTF-8 LANGUAGE=en_US:en LC_ALL=en_US.UTF-8

# Install Bitbake
RUN git clone --branch 2.16 https://git.openembedded.org/bitbake/ /opt/yocto/bitbake
ENV PATH="/opt/yocto/bitbake/bin:${PATH}"

# Configure user
ARG USERNAME=yocto
ARG USER_UID=1000
ARG USER_GID=$USER_UID
RUN groupadd --gid ${USER_GID} ${USERNAME} \
    && useradd --uid ${USER_UID} --gid ${USER_GID} -m ${USERNAME}

    # Switch to the user
USER ${USERNAME}

# Set up workspace
WORKDIR /home/${USERNAME}/workspace
