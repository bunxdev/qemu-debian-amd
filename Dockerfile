# The builder is not required by users of the released VM.
FROM debian:12-slim@sha256:88200866dfff7ea7f5cbcb6ec7c8a701889efe6fe859fe64d6990e4b07ea4171
ENV DEBIAN_FRONTEND=noninteractive
RUN printf '#!/bin/sh\nexit 101\n' > /usr/sbin/policy-rc.d && chmod +x /usr/sbin/policy-rc.d \
 && apt-get update \
 && apt-get install -y --no-install-recommends linux-image-cloud-amd64 initramfs-tools systemd-sysv openssh-server iproute2 e2fsprogs ca-certificates \
 && printf 'MODULES=list\nCOMPRESS=gzip\n' > /etc/initramfs-tools/conf.d/90-qemu \
 && printf 'virtio_pci\nvirtio_blk\nvirtio_net\nvirtio_rng\nqemu_fw_cfg\next4\n' > /etc/initramfs-tools/modules \
 && update-initramfs -u -k all
COPY configure-rootfs.sh /tmp/configure-rootfs.sh
RUN touch /.qemu-debian-builder && sh /tmp/configure-rootfs.sh \
 && rm /tmp/configure-rootfs.sh /.qemu-debian-builder
