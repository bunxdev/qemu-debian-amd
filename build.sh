#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"
[[ $(id -u) == 0 ]] || { echo 'La extracción del rootfs requiere root' >&2; exit 1; }
[[ ! -e build && ! -e dist ]] || { echo 'build/ o dist/ ya existen; conservar o mover antes de reconstruir' >&2; exit 1; }
for tool in docker qemu-img mkfs.ext4 tar xz; do command -v "$tool" >/dev/null; done
mkdir -p build/rootfs dist/debian-amd64-min
docker build --platform linux/amd64 -t qemu-debian-amd:builder .
container=$(docker create qemu-debian-amd:builder)
trap 'docker rm "$container" >/dev/null' EXIT
docker export "$container" | tar --numeric-owner -xf - -C build/rootfs
rootfs="$PWD/build/rootfs"
printf 'debian-amd64-min\n' > "$rootfs/etc/hostname"
rm -f "$rootfs/.dockerenv" "$rootfs/run/.containerenv" "$rootfs/run/systemd/container"
printf 'nameserver 10.0.2.3\n' > "$rootfs/etc/resolv.conf"
printf '127.0.0.1 localhost\n127.0.1.1 debian-amd64-min\n::1 localhost ip6-localhost\n' > "$rootfs/etc/hosts"
docker run --rm qemu-debian-amd:builder dpkg-query -W > PACKAGES.txt
docker run --rm qemu-debian-amd:builder sh -ec 'test -z "$(dpkg --audit)"'
cp "$rootfs"/boot/vmlinuz-* dist/debian-amd64-min/kernel
cp "$rootfs"/boot/initrd.img-* dist/debian-amd64-min/initramfs
truncate -s 1G build/disk.raw
mkfs.ext4 -q -F -m 0 -d "$rootfs" build/disk.raw
qemu-img convert -f raw -O qcow2 -c build/disk.raw dist/debian-amd64-min/disk.qcow2
for file in start.sh stop.sh ssh.sh resize-disk.sh sync-kernel.sh README.md; do
  cp "$file" dist/debian-amd64-min/
done
XZ_OPT='-T1 -6' tar -cJf dist/debian-amd64-min.tar.xz -C dist debian-amd64-min
(cd dist && sha256sum debian-amd64-min.tar.xz > SHA256SUMS)
echo 'Paquete limpio en dist/. Probar una copia, nunca esta imagen de distribución.'
