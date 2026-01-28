# iCesDuck

<p align="center">
  <img src="../iCesDuck/Documents/Images/Camera/" alt="Portada" width="220">
</p>

## Introduccion

**iCesDuck** es una placa de control basada en la FPGA **Lattice iCE40UP5K**, diseñada para llevar tus desarrollos en **Verilog** y **VHDL** desde simulación hasta hardware real, utilizando una **Raspberry Pi 4B** como plataforma principal y entorno de desarrollo.

Integra **FPGA**, **DAC**, **ADC** y un **convertidor de niveles lógicos** para adaptación de voltajes, permitiendo experimentar con **lógica digital** y **señales mixtas** de forma ordenada y sin depender de cableado excesivo o montajes improvisados.

<p align="center">
  <img src="../iCesDuck/Documents/Images/Camera/BOARD.jpg" alt="iCesDuck – Placa FPGA para Raspberry Pi 4B" width="220">
</p>

La comunicación con la Raspberry Pi se realiza principalmente mediante **SPI**, interfaz usada para la **carga/configuración** del diseño en la FPGA. Adicionalmente, se exponen pines dedicados para interacción en tiempo real entre la FPGA y la Raspberry Pi a través de **UART** e **I²C**, ya sea para **enviar comandos de control** o para **intercambiar datos de mayor volumen**.

La interacción usuario–máquina puede realizarse mediante pines hembra en **modo espejo** compatibles con los GPIO de la Raspberry Pi, y para la FPGA se dispone de una salida por **conector FFC/FPC (flex)** que permite acceder a señales y a los **drivers** integrados en la misma placa.

---

### Características principales

- Compatíble con **Raspberry Pi 4B** como host y entorno de pruebas  
- **FPGA Lattice iCE40UP5K** para implementación de diseños en Verilog/VHDL  
- **DAC** y **ADC** integrados para manejo de señales analógicas de entrada/salida  
- **Convertidor lógico** para distintos niveles de voltaje en E/S digitales  
- **Conector flex** hacia placa de expansión para llevar señales a pines, bornes o módulos externos
- **Conectividad directa con RP4B** mediante **UART** y **GPIO/I2C**

---

### Usos típicos

- **Laboratorio de prácticas** de sistemas digitales y sistemas mixtos (Analógico–Digital)  
- **Prototipado rápido** de módulos de control, interfaces y lógica embebida  
- **Depuración de HDL en hardware**, usando la Raspberry Pi como consola, programador y logger  

> iCesDuck está pensada como una plataforma pequeña pero completa para jugar, experimentar y construir proyectos serios de electrónica digital sin complicarte la vida con el hardware de alrededor.

---

### Origen del proyecto

iCesDuck surge con la intención de ofrecer una **herramienta libre** que permita procesar código **Verilog** y **VHDL** e interpretarlo directamente sobre una tarjeta con **módulos especializados para control**, apoyada por un entorno de cómputo dedicado para el **procesamiento** y su **presentación gráfica**. De esta forma, la plataforma busca acercar el diseño digital y los sistemas Control a laboratorios, aprendizaje autodidacta y proyectos de investigación sin depender de soluciones propietarias.

El proyecto se encuentra todavía en fase de **experimentación y crecimiento**: hay secciones de hardware, firmware y documentación que siguen puliéndose. La publicación en este repositorio busca que otras personas puedan **probarlo, replicarlo, adaptarlo y mejorar lo existente**, manteniendo vivo el espíritu original del trabajo de tesis.

---

## Estado del proyecto

- **05-09-2024** - **Nuevo**

> Proyecto estructurado y placa ensamblada correctamente. Reguladores (3.3 V/1.2 V) y reloj verificados: CLK estable a 48 MHz. FPGA operativa (bitstream + pruebas de E/S OK). Pendiente validar DAC/ADC por falta de cores SPI/I²C. EEPROM inestable: requiere recargar .bin tras cada apagado. Código en C adaptado de RPi 3B a 4B y dependencias simplificadas.


- **XX-XX-XXXX** - **En proceso**

> Esperena a una nueva actualizacion...

---

## Arquitectura

  El proyecto se compone de diversos elementos que, al unificarse, dan forma a la placa **iCesDuck**. Como se mencionó anteriormente, el objetivo es construir un sistema electrónico capaz de generar señales de control mediante la **FPGA**; sin embargo, esta tarjeta por sí sola no está pensada para ser programada desde cualquier equipo de cómputo, sino para **embebirse directamente en una Raspberry Pi 4B** a través de sus pines **GPIO**.  

  Bajo este enfoque, la Raspberry Pi actúa como entorno de cómputo principal (síntesis, carga y supervisión), mientras que iCesDuck concentra la lógica programable, la adaptación de señales/datos y la actuación sobre el entorno mediante sus salidas digitales y analógicas.

- ### Raspberry Pi 4B

   La **Raspberry Pi 4B** es el sistema de cómputo principal del proyecto. Está basada en un procesador **ARM** y cuenta con pines **GPIO** que permiten interactuar directamente con la placa **iCesDuck**, estableciendo la comunicación con la **memoria de configuración de la FPGA** y con la **EEPROM** que resguarda el bitstream. De este modo, la Raspberry Pi no solo ejecuta las herramientas de síntesis y carga, sino que también controla y supervisa la lógica implementada en la FPGA.
  
  Esta interfaz se construye alrededor de la FPGA **Lattice iCE40UP5K**, compatible con la [herramienta de síntesis APIO](https://github.com/FPGAwars/apio), que permite generar el archivo de configuración (**bitstream**) a partir de código **Verilog** usando únicamente herramientas libres.
  
  <p align="center">
    <img src="docs/img/icesduck_front.png" alt="iCesDuck – Flujo de configuración" width="420">
  </p>
  
  En el flujo de trabajo de iCesDuck, el bitstream no se envía directamente: primero se convierte desde **hardware.bin** a un **vector hexadecimal** (`bitmap[]`). Después, la **Raspberry Pi** lo transmite hacia la **FPGA** y/o la **EEPROM** mediante una interfaz tipo **SPI por bit-banging**, permitiendo almacenar la configuración y recuperarla al encender el sistema. La rutina puede consultarse en: [`iDuck-RP-Upload.c`](../iCesDuck/Core-Raspi/SPI-Upload/iDuck-RP-Upload.c).

  Durante la carga, la **Raspberry Pi 4B** utiliza la librería **bcm2835** para controlar los GPIO conectados a la FPGA. Los pines se emplean así: **SDO** envía los datos, **SCLK** genera el reloj, **CSN** actúa como chip-select (activo en bajo), **CRESETB** realiza el reset de la FPGA y **CDONE** indica si la configuración ha finalizado correctamente.
  
  <p align="center">
    <img src="docs/img/icesduck_front.png" alt="iCesDuck – Pines SPI" width="420">
  </p>
  
  El código se organiza en dos etapas: primero, el bitstream **`hardware.bin`** (generado por APIO) se convierte a un arreglo en C (**`bitmap[]`**). Luego, la Raspberry Pi reinicia la FPGA, activa **CSN** y envía el contenido de `bitmap[]` byte a byte mediante **bit-banging** sobre **SDO** y **SCLK**, supervisando la línea **CDONE**; si `CDONE` pasa a nivel alto durante la transmisión, la configuración se considera exitosa, de lo contrario se reporta un error.

 #### Inclusión de archivos relevantes

  En esta sección se muestran los `#include` principales y qué aporta cada uno al programa:

  ```c
  #include ".tempHex.c"
  #include <bcm2835.h>
  ````

  La inclusión de `.tempHex.c` permite tener cargados temporalmente los datos de `hardware.bin` en un **vector hexadecimal**, de forma que el código pueda recorrerlo y transmitirlo mediante las rutinas de **SPI (bit-banging)**. Por su parte, la librería `bcm2835.h` proporciona el mapeo y control de los **GPIO** (nombres/definiciones de pines y funciones de acceso), necesarios para generar las señales usadas en la comunicación tipo SPI.

  #### Variables de almacenamiento
  ```C
  const char *nombre_archivo_entrada = "hardware.bin";
  const char *nombre_archivo_salida  = ".tempHex.c";
  ```
  #### Conversión del bitstream binario a código C
  ```C
  void convertir_binario_a_c(const char *nombre_archivo_entrada,
                             const char *nombre_archivo_salida);

  ```
  #### Definición de pinnes I/O:
  ```C
  #define SDO     RPI_BPLUS_GPIO_J8_35
  #define SCLK    RPI_BPLUS_GPIO_J8_36
  #define CSN     RPI_BPLUS_GPIO_J8_37
  #define SDI     RPI_BPLUS_GPIO_J8_38
  #define CRESETB RPI_BPLUS_GPIO_J8_40
  #define CDONE   RPI_BPLUS_GPIO_J8_15
  ```
  #### Control de linea de datos y de reloj
  ```C
  void assert_sdo();
  void dessert_sdo();
  void assert_sclk();
  void dessert_sclk();
  ```
  #### Control del chip select
  ```C
  void assert_ss();
  void dessert_ss();
  ```
  #### Envio de bytes a FPGA
  ```C
  void sendbyte(char data);
  ```
  
  > **Nota:** En el script anterior se declara un archivo auxiliar llamado `.temp.c`. Este archivo intermedio es necesario, ya que en él se define de forma temporal el arreglo `bitmap[]` generado a partir del bitstream. Si `.temp.c` no existe, el programa no encontrará dicha matriz y la carga fallará, por lo que es importante que el archivo se genere correctamente (aunque internamente el arreglo se inicialice vacío).

  ```C
  char bitmap[] = { 0x.., 0x.., ... };
  ```
  
  Recordemos que cualquier código escrito en **C** para Raspberry Pi que acceda a los GPIO, como el archivo [`iDuck-RP-Upload.c`](firmware/src/loader.c), debe compilarse con **gcc** para que el sistema pueda ejecutar la lógica definida en el fuente, ejemplo:
  
  ```bash
  gcc -Wall -O2 iDuck-RP-Upload.c -o iDuck-RP-Upload -lbcm2835
  ```
  
  ```bash
  sudo ./iDuck-RP-Upload
  ```
  
---

## Funcionamiento

---

## Ejemplos/Demos

---

## Creditos

---


