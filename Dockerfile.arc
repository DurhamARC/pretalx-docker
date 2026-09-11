ARG PRETALX_IMAGE=pretalx/standalone:latest
FROM ${PRETALX_IMAGE}

USER root

# Install the recruitment workflow as an independent pretalx plugin. Its
# runtime adapters leave upstream source files unchanged.
COPY arc/plugin /opt/pretalx-arc-application
RUN python3 -m pip install --no-cache-dir --no-deps --no-build-isolation \
    /opt/pretalx-arc-application

# ARC is an additive reskin of the upstream image. Keeping the catalogue here
# avoids carrying a fork of pretalx and makes upgrades a base-image change.
COPY --chown=pretalxuser:pretalxuser \
    arc/locale/en/LC_MESSAGES/django.po \
    arc/locale/en/LC_MESSAGES/django.mo \
    /pretalx/src/pretalx/locale/en/LC_MESSAGES/

# ssh (DurhamARC ops/debug access to the running container, e.g. via
# `az webapp create-remote-connection`). Kept out of the community-facing
# root Dockerfile / pretalx/standalone image on purpose: this is a
# DurhamARC-specific convention, not something to bake into the generic
# image everyone else pulls.
RUN DEBIAN_FRONTEND=noninteractive apt-get -qq update && \
    DEBIAN_FRONTEND=noninteractive apt-get -qq install -y --no-install-recommends \
        openssh-server && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*
ENV SSH_PASSWD="root:Docker!"
RUN echo "$SSH_PASSWD" | chpasswd
COPY conf/sshd_config /etc/ssh/
COPY conf/init.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/init.sh

# init.sh needs to run as root to start sshd; it execs into the base image's
# own pretalx entrypoint afterwards.
EXPOSE 2222
ENTRYPOINT ["init.sh"]
