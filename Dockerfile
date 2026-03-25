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
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Switch to ubuntu user
# USER ubuntu
# WORKDIR /home/ubuntu

# Install pixi
RUN curl -fsSL https://pixi.sh/install.sh | bash
ENV PATH="/root/.pixi/bin:${PATH}"

# Copy your pixi project into the container
COPY . /workspace
WORKDIR /workspace

# Build the pixi environment (linux-64)
# RUN pixi install

# Tell RStudio Server to use pixi's R
RUN echo "rsession-which-r=/workspace/.pixi/envs/default/bin/R" \
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

CMD ["/usr/lib/rstudio-server/bin/rserver", "--server-daemonize=0"]
