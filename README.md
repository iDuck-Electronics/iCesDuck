# iCesDuck

<p align="center">
  <img src="docs/img/icesduck_front.png" alt="iCesDuck – Placa FPGA para Raspberry Pi 4B" width="420">
</p>

## Introduccion

**iCesDuck** es una placa de control basada en una FPGA **Lattice iCE40UP5K**, pensada para llevar tus diseños en **Verilog** y **VHDL** del simulador al hardware real, usando una **Raspberry Pi 4B** como cerebro y entorno de desarrollo.  

Integra **FPGA**, **DAC**, **ADC** y un **convertidor lógico** para adaptación de niveles, de modo que puedas probar lógica digital y señales mixtas sin armar medio laboratorio de cableado alrededor.

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
sshtermi
- **Laboratorio de prácticas** de sistemas digitales y sistemas mixtos (Analógico–Digital)  
- **Prototipado rápido** de módulos de control, interfaces y lógica embebida  
- **Depuración de HDL en hardware**, usando la Raspberry Pi como consola, programador y logger  

> iCesDuck está pensada como una plataforma pequeña pero completa para jugar, experimentar y construir proyectos serios de electrónica digital sin complicarte la vida con el hardware de alrededor.

---

### Origen del proyecto

iCesDuck nace a partir del trabajo de **mi propia tesis**, desarrollado en la **Universidad Veracruzana** para obtener el grado de **Ingeniero en Electrónica y Comunicaciones**. Forma parte del proyecto titulado **“Diseño de un sistema SCADA para el laboratorio de control con herramientas libres”**, donde esta placa corresponde al módulo de cómputo y expansión FPGA del sistema.

En paralelo al trabajo de titulación, iCesDuck surge también con la intención de ofrecer una **herramienta libre** que permita procesar código **Verilog** y **VHDL** e interpretarlo directamente sobre una tarjeta con **módulos especializados para control**, apoyada por un entorno de cómputo dedicado para el **procesamiento** y su **presentación gráfica**. De esta forma, la plataforma busca acercar el diseño digital y los sistemas SCADA a laboratorios, aprendizaje autodidacta y proyectos de investigación sin depender de soluciones propietarias.

> El proyecto se encuentra todavía en fase de **experimentación y crecimiento**: hay secciones de hardware, firmware y documentación que siguen puliéndose. La publicación en este repositorio busca que otras personas puedan **probarlo, replicarlo, adaptarlo y mejorar lo existente**, manteniendo vivo el espíritu original del trabajo de tesis.

---

## Estado del proyecto

- **05-09-2024** - **Nuevo**

> Se estructura el projecto (documentación y hardware), se maquila y ensambla correctamente. En pruebas rápidas se verifican los reguladores de 3.3 V y 1.2 V y se comprueba con osciloscopio el reloj dedicado, obteniendo una señal de CLK estable a 48 MHz. Sobre el núcleo FPGA se cargan demos de compuertas lógicas para validar la operatividad de los pines de E/S, con carga del bitstream y respuesta de salidas satisfactorias. Por falta de cores para SPI e I²C aún no se evalúan los módulos DAC/ADC, quedando su validación pendiente. El almacenamiento del archivo .bin en la EEPROM presenta comportamiento inestable, por lo que actualmente es necesario recargarlo cada vez que la tarjeta se desenergiza. Se adapta el código en C originalmente escrito para Raspberry Pi 3B al modelo 4B y se simplifica la instalación de dependencias para la compilación y carga del .bin.

- **XX-XX-XXXX** - **En proceso**

> Esperena a una nueva actualizacion...

---

## Arquitectura

El proyecto se compone de diversos elementos que, al unificarse, dan forma a la placa **iCesDuck**. Como se mencionó anteriormente, el objetivo es construir un sistema electrónico capaz de generar señales de control mediante la **FPGA**; sin embargo, esta tarjeta por sí sola no está pensada para ser programada desde cualquier equipo de cómputo, sino para **embebirse directamente en una Raspberry Pi 4B** a través de sus pines **GPIO**.  

Bajo este enfoque, la Raspberry Pi actúa como entorno de cómputo principal (síntesis, carga y supervisión), mientras que iCesDuck concentra la lógica programable, la adaptación de señales/datos y la actuación sobre el entorno mediante sus salidas digitales y analógicas.

- ### Raspberry Pi 4B

  La Raspberry Pi 4B es el sistema de cómputo principal del proyecto, basada en un procesador **ARM** y equipada con un conjunto de pines **GPIO** que permiten interactuar directamente con el mundo exterior.  

  En esta arquitectura, los GPIO son el enlace crítico entre la Raspberry y la placa **iCesDuck**, ya que a través de ellos se establece la comunicación con la **memoria de configuración de la FPGA** y con la **EEPROM** encargada de resguardar el archivo cargado (bitstream). De esta forma, la Raspberry Pi no solo ejecuta las herramientas de síntesis y carga, sino que también controla y supervisa el estado de la lógica implementada en la FPGA.

  Esto se logra estableciendo una interfaz directa entre la Raspberry Pi y la FPGA **Lattice iCE40UP5K**. Esta FPGA es compatible con la [herramienta de síntesis APIO](https://github.com/FPGAwars/apio), la cual permite escribir y sintetizar diseños en **Verilog** utilizando únicamente herramientas libres, generando como resultado un archivo de configuración (**bitstream**).

<p align="center">
  <img src="docs/img/icesduck_front.png" alt="Apio" width="420">
</p>

  En el flujo de trabajo de iCesDuck, ese bitstream no se envía tal cual: primero se convierte a un **vector en hexadecimal**, y posteriormente la Raspberry Pi lo transmite mediante **SPI** hacia la FPGA y/o hacia la **EEPROM**, que es la encargada de almacenar la configuración para que pueda recuperarse al encender el sistema. [Ver archivo fuente `loader.c`](firmware/src/loader.c).

  > Esto se toma de inspiracion sobre un projecto encontrado dentro de un repositorio de Github, aplicado a una placa llamada **UpDuino V1.0** y una **Raspberry Pi 3B** (actualmente el repositorio no lo encuentro por ningun lado, pero aclaro que esta idea inicialmente no es mia, y doy todos los creditos a quien lo implemento primero)

  En el proceso de carga del bitstream, la **Raspberry Pi 4B** utiliza la librería **bcm2835** para controlar directamente los GPIO conectados a la FPGA **Lattice iCE40UP5K**. Los pines se emplean de la siguiente forma: **SDO** envía los datos, **SCLK** genera el reloj, **CSN** funciona como chip–select (activo en bajo), **CRESETB** realiza el reset de la FPGA y **CDONE** reporta si la configuración ha finalizado correctamente.

<p align="center">
  <img src="docs/img/icesduck_front.png" alt="iCesDuck – Pin-SPI" width="420">
</p>
  
  El código se divide en dos partes principales. Primero, el archivo de bitstream **hardware.bin** (generado por la herramienta de síntesis, por ejemplo [APIO](https://github.com/FPGAwars/apio)) se convierte a un arreglo en C (**bitmap[]**), donde cada byte queda representado en formato hexadecimal. Después, la Raspberry Pi reinicia la FPGA, activa **CSN** y envía el contenido de **bitmap[ ]** byte a byte mediante **bit–banging** sobre **SDO** y **SCLK**, mientras supervisa la línea `CDONE`: si esta pasa a nivel alto durante la transmisión, la configuración se considera exitosa; si nunca se eleva, se reporta un error.








---

## Funcionamiento

---

## Ejemplos/Demos

---

## Creditos

---


