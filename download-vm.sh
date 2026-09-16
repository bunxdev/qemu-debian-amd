#!/bin/sh
set -eu
repo_dir=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
destination=${1:-"$repo_dir/vm"}
if [ "$#" -gt 1 ] || [ -e "$destination" ] || [ -L "$destination" ]; then
    echo 'Uso: ./download-vm.sh [directorio NUEVO]. No se sobrescriben instalaciones.' >&2
    exit 1
fi
for tool in curl tar xz sha256sum mktemp; do command -v "$tool" >/dev/null; done
mkdir -p "$(dirname -- "$destination")"
parent=$(CDPATH= cd -- "$(dirname -- "$destination")" && pwd)
destination="$parent/$(basename -- "$destination")"
stage=$(mktemp -d "$parent/.qemu-debian-download.XXXXXX")
trap 'rm -rf -- "$stage"' EXIT
trap 'exit 130' INT
trap 'exit 143' TERM HUP
version=v0.1.0
archive=debian-amd64-min.tar.xz
expected=748e6a7b184c7f4093ed8c64bb522ca68272a303917eb0cfa92c8940d1f51092
curl --fail --location --show-error --retry 3 --connect-timeout 30 \
    --output "$stage/$archive" \
    "https://github.com/bunxdev/qemu-debian-amd/releases/download/$version/$archive"
(
    cd "$stage"
    printf '%s  %s\n' "$expected" "$archive" | sha256sum -c -
    tar -xJf "$archive"
)
# El archivo se verifica antes de extraerlo. Las claves se generan al arrancar.
test ! -e "$destination" && test ! -L "$destination"
mv "$stage/debian-amd64-min" "$destination"
printf 'VM %s preparada en %s\n' "$version" "$destination"
