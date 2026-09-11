#!/bin/bash
set -e

echo "Starting SSH ..."
mkdir -p /run/sshd
service ssh start

exec /usr/local/bin/pretalx "$@"
