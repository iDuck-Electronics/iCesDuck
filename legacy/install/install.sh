#!/bin/bash

manejo_error()
{
    echo "Error: $1" >&2
    exit 1
}

echo "Actualizando elementos..."
sudo apt-get update || manejo_error
read -p "¿Desea instalar los paquetes del sistema? (y/n): " answer
if [[ $answer =~ ^[Yy]$ ]]; then
    sudo apt-get upgrade -y || manejo_error "Problema al instalar los paquetes del sistema"
fi

paquetes=("python3" "virtualenv" "raspi-config" "git" "make" "gcc" "libcap2" "libcap-dev" "wget")

echo "Instalando paquetes..."
for paquete in "${paquetes[@]}"; do
    sudo apt-get install -y $paquete || manejo_error "Problema con alguna dependencia"
done

echo "Instalando elemento grafico..."
sudo apt-get install python3-pyqt5


read -p "¿Desea limpiar la terminal? (y/n): " answer
if [[ $answer =~ ^[Yy]$ ]]; then
    clear
fi

echo "Creando entornos virtuales..."
mkdir -p ~/iDuck
virtualenv ~/iDuck/VirtualDuck || manejo_error "Problema al crear el entorno virtual"

echo "Instalando librerias virtuales..."
cd ~/iDuck
source VirtualDuck/bin/activate

pip install -U apio==0.8.4
apio --version
apio install --all
pip install PyQt5
pip install matplotlib
pip install numpy

cd /VirtualDuck/lib/python3.11/site-packages
ln -s /usr/lib/python3/dist-packages/PyQt5
cd
deactivate

echo "Aplicando permisos..."
sudo adduser $USER kmem
echo 'SUBSYSTEM=="mem", KERNEL=="mem", GROUP="kmem", MODE="0660"' | sudo tee /etc/udev/rules.d/98-mem.rules
echo "Descargando librerias..."
wget http://www.airspayce.com/mikem/bcm2835/bcm2835-1.75.tar.gz

echo "Instalando librerias..."
tar zxvf bcm2835-1.75.tar.gz -C ~/iDuck || manejo_error "Problemas con la descompresion del archivo bcm2835"
cd ~/iDuck/bcm2835-1.75
./configure
make
sudo make check
sudo make install

echo "Configurando Raspberry Pi..."
sudo raspi-config nonint do_spi 0
sudo raspi-config nonint do_i2c 0
sudo raspi-config nonint do_serial 0
sudo raspi-config nonint do_onewire 0

read -p "Es necesario reiniciar el sistema. ¿Quieres hacerlo ahora? (y/n): " answer
if [[ $answer =~ ^[Yy]$ ]]; then
    echo "Reiniciando el sistema..."
    sudo reboot
else
    clear
fi

