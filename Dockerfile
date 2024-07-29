# syntax=docker/dockerfile:1.2
FROM python:3.12-bookworm

# Install apt packages, using the host cache
COPY packages.txt /tmp/packages.txt
RUN --mount=target=/var/lib/apt/lists,type=cache,sharing=locked \
    --mount=target=/var/cache/apt,type=cache,sharing=locked \
    rm -f /etc/apt/apt.conf.d/docker-clean \
    && apt-get update \
    && sed 's/#.*//' /tmp/packages.txt \
        | xargs apt-get -y --no-install-recommends install

# Install Python packages, using the host cache
COPY requirements.txt /tmp/requirements.txt
RUN --mount=type=cache,target=/root/.cache \
    python -m pip install --no-deps --requirement /tmp/requirements.txt

# Without this, the Jupyter terminal defaults to /bin/sh which is much less
# usable
ENV SHELL=/bin/bash
# Jupyter writes various runtime files to $HOME so we need that to be writable
# regardless of which user we run as
ENV HOME=/tmp
# Allow Jupyter to be configured from within the workspace
ENV JUPYTER_CONFIG_DIR=/workspace/jupyter-config
# This variable is only needed for the `ebmdatalab` package:
# https://pypi.org/project/ebmdatalab/
ENV EBMDATALAB_BQ_CREDENTIALS_PATH=/workspace/bq-service-account.json

# Run any necessary post-installation tasks
COPY postinstall.sh /tmp/postinstall.sh
RUN /tmp/postinstall.sh

RUN mkdir /workspace
WORKDIR /workspace
