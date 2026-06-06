#!/bin/bash

set -e

PROJECT_ROOT="$(pwd)"

if [ ! -d ".git" ]; then
  echo "Error: ejecuta este script desde la raiz del repositorio iCesDuck."
  exit 1
fi

echo "Reestructurando iCesDuck desde: $PROJECT_ROOT"
echo "No se eliminara informacion; lo anterior se movera a legacy cuando exista."

# =========================
# Nueva estructura base
# =========================
mkdir -p .vscode

mkdir -p docs/images
mkdir -p docs/notes
mkdir -p docs/roadmap

mkdir -p hardware/board
mkdir -p hardware/pins
mkdir -p hardware/power
mkdir -p hardware/adc
mkdir -p hardware/dac
mkdir -p hardware/uart
mkdir -p hardware/spi

mkdir -p src/fpga/rtl
mkdir -p src/fpga/pins
mkdir -p src/fpga/sim
mkdir -p src/fpga/bin
mkdir -p src/fpga/build

mkdir -p src/pi/loader
mkdir -p src/pi/gpio
mkdir -p src/pi/uart
mkdir -p src/pi/spi
mkdir -p src/pi/app
mkdir -p src/pi/scripts

mkdir -p tools/setup
mkdir -p tools/fpga
mkdir -p tools/pi
mkdir -p tools/debug

mkdir -p tests/loader
mkdir -p tests/gpio
mkdir -p tests/uart
mkdir -p tests/fpga

mkdir -p legacy/spi-upload
mkdir -p legacy/install

mkdir -p build
mkdir -p tmp

# =========================
# Migracion segura desde estructura anterior
# =========================
if [ -d "Core-Raspi/SPI-Upload" ]; then
  echo "Copiando Core-Raspi/SPI-Upload a legacy/spi-upload..."
  cp -rn Core-Raspi/SPI-Upload/* legacy/spi-upload/ 2>/dev/null || true
fi

if [ -d "Install" ]; then
  echo "Copiando Install a legacy/install..."
  cp -rn Install/* legacy/install/ 2>/dev/null || true
fi

if [ -d "Documents/Images" ]; then
  echo "Copiando Documents/Images a docs/images..."
  cp -rn Documents/Images/* docs/images/ 2>/dev/null || true
fi

# =========================
# Copia de trabajo para reinicio
# =========================
if [ -f "legacy/spi-upload/iDuck-RP-Upload.c" ]; then
  echo "Copiando cargador a src/pi/loader..."
  cp -n legacy/spi-upload/iDuck-RP-Upload.c src/pi/loader/iDuck-RP-Upload.c 2>/dev/null || true
fi

if [ -f "legacy/spi-upload/hardware.bin" ]; then
  echo "Copiando hardware.bin a src/fpga/bin..."
  cp -n legacy/spi-upload/hardware.bin src/fpga/bin/hardware.bin 2>/dev/null || true
fi

# =========================
# Mantener carpetas vacias en Git
# =========================
find . \
  -path ./.git -prune -o \
  -type d \
  ! -path "./.git*" \
  ! -path "./build" \
  ! -path "./tmp" \
  -exec sh -c 'touch "$0/.gitkeep"' {} \;

echo ""
echo "Estructura preparada. Revisa con:"
echo "git status"
echo ""
echo "Despues puedes guardar cambios con:"
echo "git add ."
echo "git commit -m \"Restart project structure\""
echo "git push origin restart-structure"
