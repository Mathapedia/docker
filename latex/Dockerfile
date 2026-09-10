FROM ubuntu:22.04

# Set non-interactive mode for apt
ENV DEBIAN_FRONTEND=noninteractive

# Update package lists
RUN apt-get update

# Install dependencies required for TeX Live
RUN apt-get install -y \
    curl \
    software-properties-common \
    build-essential \
    perl \
    wget \
    tzdata

# Workaround for `fmtutil` failures during installation
RUN mkdir -p /root/.texmf-var /root/.texlive

# Install TeX Live in smaller chunks to avoid resource issues
RUN apt-get install -y texlive-base
RUN apt-get install -y texlive-latex-base
RUN apt-get install -y texlive-latex-extra
RUN apt-get install -y texlive-pictures


RUN apt-get install -y texlive-formats-extra
RUN apt-get install --reinstall -y tex-common

# no recommends needed to avoid fmtutil ERROR https://forums.opensuse.org/t/latex-on-fresh-install/131784
RUN apt-get install -y --no-install-recommends texlive-pstricks
RUN apt-get install -y texlive-lang-all

# Install Ghostscript for ps2pdf and related tools
RUN apt-get install -y ghostscript

# Install libalgorithm-diff-perl (addon, for latexdiff support)
RUN apt-get install -y libalgorithm-diff-perl

# Build/lint tooling: latexmk (incremental builds), chktex + latexindent
# (lint/format), biber, IEEEtran and other .bst styles, dvisvgm for SVG
RUN apt-get install -y --no-install-recommends \
    latexmk \
    chktex \
    biber \
    texlive-extra-utils \
    texlive-bibtex-extra \
    texlive-publishers \
    texlive-science \
    libyaml-tiny-perl \
    libfile-homedir-perl \
    libunicode-linebreak-perl \
    liblog-log4perl-perl \
    make \
    git \
    python3

# Install Node.js
RUN curl -fsSL https://deb.nodesource.com/setup_current.x | bash - && \
    apt-get install -y nodejs

# Cleanup unused files and lists
RUN apt-get clean && rm -rf /var/lib/apt/lists/*

# Add custom files and configuration
ADD mount/etc /etc
ADD mount/dotfiles /root
ADD mount/bin /bin

# Define volume and working directory
VOLUME ["./tex:/usr/src"]
WORKDIR /usr/src
