# Construir Debian AMD64 mínimo

Anfitrión de construcción probado: Debian 13 Linux x86_64. Requiere Docker,
QEMU (`qemu-img`), e2fsprogs, GNU tar, xz, Bash y root para preservar propietarios
al extraer el rootfs. No usa Python.

```bash
sudo ./build.sh
```

1. El Dockerfile parte de `debian:12-slim` fijado por digest.
2. APT instala kernel cloud AMD64, systemd, OpenSSH, red, ext4 y certificados,
   sin paquetes recomendados. El initramfs contiene los módulos virtio, ext4 y fw_cfg.
3. `configure-rootfs.sh` configura servicios, SSH por clave, crecimiento de ext4,
   logs volátiles y elimina identidades/caches. Solo se ejecuta en el constructor.
4. Se exporta el filesystem, se quitan marcadores de contenedor y se fija DNS
   para la red user-mode de QEMU. Se registra `PACKAGES.txt` y comprueba dpkg.
5. Se crea ext4 de 1 GiB sin particiones, se puebla y convierte a QCOW2 comprimido.
6. Se copian el kernel bzImage y su initramfs, scripts y README al paquete.
7. Se genera `dist/debian-amd64-min.tar.xz` y `dist/SHA256SUMS`.

`build/` y `dist/` deben ser nuevos. El script no borra construcciones existentes.
Probar una copia del paquete; conservar intacta la distribución para publicar.
Al cambiar el paquete hay que actualizar el checksum fijado en `download-vm.sh`.

El digest del contenedor está fijado, pero APT obtiene las actualizaciones de
Debian 12 disponibles: no es una compilación reproducible byte a byte. El inventario
registra versiones. Se conservan los archivos de copyright/licencia de Debian;
las fuentes correspondientes se obtienen de Debian y Debian Security.
