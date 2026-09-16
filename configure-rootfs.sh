#!/bin/sh
# Run only in the Docker build stage, never directly on the host.
set -eu
test -f /.qemu-debian-builder || { echo 'Run using Dockerfile only' >&2; exit 1; }
printf 'debian-amd64-min\n' > /etc/hostname
printf '/dev/vda / ext4 defaults,noatime 0 1\n' > /etc/fstab
mkdir -p /etc/systemd/network /etc/systemd/system.conf.d /etc/systemd/journald.conf.d /etc/ssh/sshd_config.d /etc/systemd/system/ssh.service.d
cat > /etc/systemd/network/20-qemu.network <<'CONFIG'
[Match]
Name=en* eth*
[Network]
DHCP=ipv4
IPv6AcceptRA=yes
CONFIG
cat > /etc/systemd/system.conf.d/90-tcg.conf <<'CONFIG'
[Manager]
DefaultTimeoutStartSec=300s
DefaultDeviceTimeoutSec=300s
DefaultTimeoutStopSec=120s
CONFIG
printf '[Journal]\nStorage=volatile\nRuntimeMaxUse=8M\n' > /etc/systemd/journald.conf.d/90-minimal.conf
cat > /etc/ssh/sshd_config.d/10-vm.conf <<'CONFIG'
PermitRootLogin prohibit-password
PasswordAuthentication no
KbdInteractiveAuthentication no
HostKey /etc/ssh/ssh_host_ed25519_key
CONFIG
cat > /usr/local/sbin/vm-prepare <<'SCRIPT'
#!/bin/sh
set -eu
/sbin/resize2fs /dev/vda
modprobe qemu_fw_cfg
mkdir -p /root/.ssh
chmod 700 /root/.ssh
cat /sys/firmware/qemu_fw_cfg/by_name/opt/vm/ssh-key/raw > /root/.ssh/authorized_keys
chmod 600 /root/.ssh/authorized_keys
ssh-keygen -lf /root/.ssh/authorized_keys >/dev/null
if [ ! -f /etc/ssh/ssh_host_ed25519_key ]; then
    ssh-keygen -q -t ed25519 -N '' -f /etc/ssh/ssh_host_ed25519_key
fi
SCRIPT
chmod +x /usr/local/sbin/vm-prepare
cat > /etc/systemd/system/vm-prepare.service <<'CONFIG'
[Unit]
Description=Grow root filesystem and configure per-device SSH keys
After=local-fs.target systemd-udev-trigger.service
Before=ssh.service
[Service]
Type=oneshot
ExecStart=/usr/local/sbin/vm-prepare
RemainAfterExit=yes
TimeoutStartSec=300
[Install]
WantedBy=multi-user.target
CONFIG
printf '[Unit]\nRequires=vm-prepare.service\nAfter=vm-prepare.service\n' > /etc/systemd/system/ssh.service.d/10-vm.conf
systemctl enable systemd-networkd ssh vm-prepare
systemctl set-default multi-user.target
rm -f /etc/ssh/ssh_host_* /etc/machine-id /var/lib/dbus/machine-id /usr/sbin/policy-rc.d
: > /etc/machine-id
apt-get clean
rm -rf /var/lib/apt/lists/* /var/log/* /var/tmp/*
