# Reinicio estructurado de iCesDuck

Este documento sirve como guia para retomar iCesDuck desde el avance anterior sin borrar el trabajo realizado.

## Objetivo inicial

Recuperar la capacidad de cargar hardware.bin desde Raspberry Pi hacia la FPGA iCE40UP5K y confirmar la carga mediante la senal CDONE.

## Enfoque

- legacy: conserva el trabajo anterior.
- src: contiene el codigo limpio que se retomara y mejorara.
- hardware: documenta pines, alimentacion, SPI, UART, ADC y DAC.
- tools: contiene scripts para facilitar comandos de trabajo.
- tests: contiene pruebas pequenas y controladas.

## Primeras metas

1. Clonar el repositorio en Ubuntu.
2. Cambiar a la rama restart-structure.
3. Ejecutar tools/setup/restart_structure.sh.
4. Revisar que el cargador anterior quede en legacy/spi-upload.
5. Copiar el cargador funcional a src/pi/loader.
6. Probar la carga de hardware.bin en la Raspberry Pi.
7. Confirmar que CDONE indique carga correcta.
8. Despues avanzar a comunicacion UART basica.

## Estructura propuesta

- .vscode
- docs
- hardware
- src/fpga
- src/pi
- tools
- tests
- legacy
- build
- tmp

## Nota importante

GitHub no guarda carpetas vacias. Por eso el script crea archivos .gitkeep dentro de carpetas que aun no tienen contenido.
