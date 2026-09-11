#!/bin/bash
set -e

# Snapshot the real container environment (PRETALX_DB_*, PRETALX_REDIS*,
# etc. — injected by Docker/App Service into PID 1 only) so SSH logins get
# it too, instead of silently falling back to pretalx's defaults. Requires
# PermitUserEnvironment yes in sshd_config.
mkdir -p /root/.ssh
env -0 | grep -zvE '^(PWD|OLDPWD|SHLVL|_|HOSTNAME|SSH_[A-Z]+)=' | tr '\0' '\n' > /root/.ssh/environment
chmod 700 /root/.ssh
chmod 600 /root/.ssh/environment

echo "Starting SSH ..."
mkdir -p /run/sshd
service ssh start

exec /usr/local/bin/pretalx "$@"
