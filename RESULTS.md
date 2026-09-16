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

## Pendientes

Verificación de la descarga publicada y TCG se añadirán después de ejecutarse.
No se ha probado macOS, Windows ni Docker dentro de esta versión. El soporte
multiplataforma se planifica en Voxy y no se deduce del arranque correcto en Linux.
