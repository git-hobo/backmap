# =========================
#   Backmap Dockerfile
# =========================

FROM continuumio/miniconda3

LABEL maintainer="<fabian.schweitzer@biologie.uni-freiburg.de>"
LABEL description="Container for backmap.pl with all dependencies"

# Prevent interactive prompts
ENV DEBIAN_FRONTEND=noninteractive

# -------------------------
# Base Linux Dependencies
# -------------------------
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        curl \
        build-essential \
        perl \
        cpanminus \
    && rm -rf /var/lib/apt/lists/*
# Install basic troubleshooting tools
RUN apt-get update && apt-get install -y --no-install-recommends \
    vim less nano tree wget curl unzip tar \
    procps iputils-ping net-tools lsof \
    htop bash-completion jq \
    && rm -rf /var/lib/apt/lists/*

# -------------------------
# Conda Channels
# -------------------------
RUN conda config --add channels defaults && \
    conda config --add channels bioconda && \
    conda config --add channels conda-forge

# -------------------------
# Bio Dependencies
# -------------------------
RUN conda install -y \
        samtools \
        bwa \
        minimap2 \
        qualimap \
        multiqc \
        bedtools \
        r-base \
    && conda clean -a -y

# -------------------------
# Perl Dependencies
# -------------------------
# Ensure system perl instead of conda perl used
ENV PATH="/usr/bin:${PATH}"
RUN cpanm Number::FormatEng Parallel::Loops

# -------------------------
# Backmap Repository
# -------------------------
WORKDIR /app
RUN git clone --depth 1 https://github.com/git-hobo/backmap . \
    && chmod +x backmap.pl \
    && rm -rf .git

# Add /app to PATH
ENV PATH="/app:${PATH}"

# Create aliases
RUN ln -s /app/backmap.pl /usr/local/bin/backmap && \
    ln -s /app/backmap.pl /usr/local/bin/Backmap && \
    ln -s /app/backmap.pl /usr/local/bin/backmap.pl

# -------------------------
# Set entrypoint
# -------------------------
ENTRYPOINT ["perl", "/app/backmap.pl"]
