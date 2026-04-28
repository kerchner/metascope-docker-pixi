FROM rocker/rstudio:latest

# Create ubuntu user with home directory
# RUN id -u ubuntu 2>/dev/null || useradd -ms /bin/bash ubuntu # && \
#     echo "ubuntu:ubuntu" | chpasswd

# Update and install basic tools
RUN apt-get update && apt-get install -y \
    curl \
    wget \
    git \
    vim \
    python3 \
    python3-pip \
    libcurl4 \
    libssl3 \
    libssh2-1 \
    ca-certificates \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Switch to ubuntu user
# USER ubuntu
# WORKDIR /home/ubuntu

# Install pixi
RUN curl -fsSL https://pixi.sh/install.sh | bash
ENV PATH="/root/.pixi/bin:${PATH}"

# Copy your pixi project into the container
RUN mkdir -p /pixi
COPY ./pixi.toml /pixi
COPY ./pixi.lock /pixi
WORKDIR /pixi

# Build the pixi environment (linux-64)
RUN pixi install

# Tell RStudio Server to use pixi's R
RUN echo "rsession-which-r=/pixi/.pixi/envs/default/bin/R" \
    > /etc/rstudio/rserver.conf

EXPOSE 8787

# Default command
# CMD [ "bash" ]

# This is needed, because without it, `pixi shell` will not run the MetaScope script referenced
# in the warning:
# 
#  WARN Skipped running the post-link scripts because `run-post-link-scripts` = `false`
# 	- bin/.bioconductor-metascope-pre-unlink.sh
#
RUN pixi config set --local run-post-link-scripts insecure

# Ensure Pixi environment is available
ENV PATH="/pixi/.pixi/envs/default/bin:${PATH}"
ENV LD_LIBRARY_PATH="/pixi/.pixi/envs/default/lib:${LD_LIBRARY_PATH}"

# (Optional but recommended)
# Prevent system OpenSSL from being picked up accidentally
RUN ln -sf /pixi/.pixi/envs/default/lib/libssl.so.3 /usr/lib/x86_64-linux-gnu/libssl.so.3 && \
    ln -sf /pixi/.pixi/envs/default/lib/libcrypto.so.3 /usr/lib/x86_64-linux-gnu/libcrypto.so.3

CMD ["/usr/lib/rstudio-server/bin/rserver", "--server-daemonize=0"]
