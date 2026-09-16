#!/bin/sh
set -eu
test "$(uname -m)" = x86_64
. /etc/os-release
test "$ID" = debian
test "$VERSION_ID" = 12
if command -v docker >/dev/null 2>&1; then
    echo 'ERROR: esta réplica no debe incluir Docker' >&2; exit 1
fi
case "$(systemd-detect-virt)" in qemu|kvm) ;; *) exit 1;; esac
systemd-detect-virt
uname -a
df -h /
printf 'debian-min-persistence-ok\n' > /root/persistence-proof
echo 'BOOT, SSH, DEBIAN 12 AMD64 AND NO DOCKER: PASSED'
