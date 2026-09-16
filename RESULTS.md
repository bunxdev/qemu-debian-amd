# Resultados AMD64 — 2026-09-16

Construcción y prueba en Debian 13 Linux x86_64, QEMU 10.0.13.
Invitado Debian 12 AMD64, kernel `6.1.0-53-cloud-amd64`, una CPU, 512 MiB de RAM.
No contiene Docker. Estas son pruebas propias de AMD64, no resultados heredados de ARM.

## KVM

`VM_SSH_PORT=22224 VM_HTTP_PORT=28081 ./run-tests.sh` terminó con
**ALL TESTS PASSED**, código **0**.

- Arranque directo del kernel, clave SSH por fw_cfg y Debian x86_64 correctos.
- DNS y acceso a repositorios APT correctos; Docker ausente.
- Hashes del kernel e initramfs idénticos después de sincronizarlos desde el invitado.
- Ampliación mientras la VM estaba encendida rechazada.
- Apagado e integridad QCOW2 correctos, sin errores.
- Disco ampliado de 1 a 2 GiB; intento de reducción rechazado.
- Nuevo arranque, crecimiento de ext4 y persistencia del archivo correctos.
- SSH, preparación y red activos; ninguna unidad systemd fallida.
- Medición final dentro del invitado: 470 MiB de RAM totales, **52 MiB usados**,
  417 MiB disponibles. No equivale al consumo RSS del proceso QEMU anfitrión.
- Sistema de archivos final: 2 GiB, **276 MiB usados**, aproximadamente 1,7 GiB libres.

Registro local: `vm/test-logs.hwm7Bo/results.log`. La imagen publicada se conserva
limpia, separada de esta copia usada para pruebas, y mantiene 1 GiB de capacidad.
El rootfs limpio ocupa aproximadamente 258 MiB en el constructor.

## Release pública y TCG

Se descargó v0.1.0 desde GitHub mediante el script publicado. SHA256 correcto:

`748e6a7b184c7f4093ed8c64bb522ca68272a303917eb0cfa92c8940d1f51092`

Paquete: **109.641.380 bytes (104,6 MiB)**. La descarga se extrajo en una copia
nueva y se repitió la prueba completa con `VM_ACCEL=tcg`: **ALL TESTS PASSED**,
código **0**. Pasaron SSH, DNS, APT, kernel, integridad, ampliación de 1 a 2 GiB,
rechazo de reducción y persistencia. Los servicios quedaron activos sin unidades fallidas.
Medición final: 469 MiB de RAM total, **52 MiB usados**, 416 MiB disponibles;
276 MiB de disco ocupado. TCG se probó en Linux x86_64, no en un anfitrión ARM.

Registro local: `build/release-test/test-logs.IOpdZ9/results.log`.
Las VMs de prueba se apagan al finalizar para liberar recursos.

## Pendientes

No se ha probado macOS, Windows ni Docker dentro de esta versión. El soporte
multiplataforma se planifica en Voxy y no se deduce del arranque correcto en Linux.
