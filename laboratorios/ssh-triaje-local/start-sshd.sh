#!/bin/sh
set -eu

host_key=/etc/ssh/ssh_host_ed25519_key
if [ ! -f "$host_key" ]; then
    ssh-keygen -q -t ed25519 -N '' -f "$host_key"
fi

/usr/local/sbin/sshd -t -f /etc/ssh/sshd_config
exec /usr/local/sbin/sshd -D -e -f /etc/ssh/sshd_config
