# qemu-debian-amd

Debian 12 mínimo para **QEMU x86_64 (AMD64, tanto Intel como AMD)**, preparado
como componente independiente para [Voxy](https://github.com/bunxdev/voxy) y
[Lupa](https://github.com/bunxdev/lupa). No incluye Docker ni Lupa.

Equivalente de [qemu-debian-arm](https://github.com/bunxdev/qemu-debian-arm):
arranque directo de kernel + initramfs, ext4 sin particiones, disco QCOW2 de
1 GiB ampliable, una CPU y 512 MiB de RAM por defecto. SSH por clave generada
para cada instalación, sin contraseña predeterminada. La clave se entrega al
invitado mediante `fw_cfg`; no usa cloud-init ni un disco semilla.

## Descargar e iniciar en Linux

[Paquete v0.1.0](https://github.com/bunxdev/qemu-debian-amd/releases/download/v0.1.0/debian-amd64-min.tar.xz)
· [SHA256SUMS](https://github.com/bunxdev/qemu-debian-amd/releases/download/v0.1.0/SHA256SUMS)
· [Resultados](RESULTS.md)

```bash
sudo apt-get install --no-install-recommends qemu-system-x86 qemu-utils \
  openssh-client curl ca-certificates xz-utils git
git clone https://github.com/bunxdev/qemu-debian-amd.git
cd qemu-debian-amd
./download-vm.sh
./vm/start.sh
# Esperar a que arranque, sobre todo si se usa TCG.
./vm/ssh.sh
./vm/stop.sh
```

`sudo ./debian-setup.sh` instala las herramientas ausentes y descarga la VM en
un anfitrión Debian/Ubuntu. No sobrescribe un destino existente. El descargador
verifica el SHA256 fijado en su código **antes de extraer**.

Con `/dev/kvm` accesible en Linux x86_64 se selecciona KVM. En otros casos se
selecciona TCG, más lento. Si el dispositivo KVM existe pero el hipervisor no
permite virtualización anidada, QEMU fallará; puede elegirse TCG explícitamente:

```bash
VM_ACCEL=tcg ./vm/start.sh
```

SSH se publica exclusivamente en `127.0.0.1:2222`. También se reenvía
`127.0.0.1:8080` al puerto 8080 del invitado, sin servicio web preinstalado.
`VM_RAM_MB`, `VM_CPUS`, `VM_SSH_PORT` y `VM_HTTP_PORT` permiten ajustar recursos
y puertos. Mantener los mismos puertos en los comandos posteriores.

## Disco, actualizaciones y pruebas

```bash
./vm/stop.sh
./vm/resize-disk.sh 8G
./vm/start.sh
./vm/ssh.sh df -h /
```

Solo se admite ampliar con la VM apagada. ext4 crece al arrancar. Una capacidad
virtual de 8 GiB no implica descargar ni reservar físicamente 8 GiB.
Para actualizar paquetes se usa APT. Si cambia el kernel, ejecutar
`./vm/sync-kernel.sh` **antes de apagar y arrancar de nuevo**: los archivos externos
deben coincidir con los módulos del invitado. Respaldar el directorio completo
con la VM apagada; nunca distribuir una copia que contenga claves o datos propios.

```bash
# Requiere una copia nueva y apagada de 1 GiB. La ampliará a 2 GiB.
./run-tests.sh
./vm/stop.sh
```

El test comprueba Debian/arquitectura, SSH, DNS, APT, ausencia de Docker,
sincronización del kernel, integridad QCOW2, ampliación, rechazo de reducción y
persistencia tras un nuevo arranque. Conserva registros en `vm/test-logs.*/` y
deja la VM encendida si termina correctamente. Para repetirlo, descargar otra
copia en un directorio nuevo. `BOOT_TIMEOUT` controla la espera de arranque.

## Construcción y alcance

`sudo ./build.sh` construye y empaqueta una imagen limpia usando Docker solo
en el **constructor**. El usuario final no necesita Docker. Véase [BUILD.md](BUILD.md)
y el inventario [PACKAGES.txt](PACKAGES.txt). Los discos van en Releases, no en Git.

Los scripts actuales están destinados a Linux. macOS Intel, Apple Silicon,
Windows x64 y Windows ARM64 requieren adaptación y pruebas; no se declara aquí
soporte nativo. En Apple Silicon se debe preferir Debian ARM64 acelerado, frente
a emular AMD64. El plan multiplataforma está en el README de Voxy.

Basado en `bunxdev/qemu-debian-arm`, commit
`24197335d1098d1e002fe525e5b4cf0b225ebf2f`. Las mediciones del repo ARM no se
atribuyen a esta versión AMD64; sus resultados propios están en `RESULTS.md`.
