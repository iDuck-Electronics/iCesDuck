# iCesDuck

<p align="center">
  <img
    src="docs/assets/images/ICD-IMG_01.png"
    alt="iCesDuck — Plataforma FPGA para Raspberry Pi 4B"
    width="720"
  >
</p>

<p align="center">
  <strong>Plataforma FPGA de código abierto para Raspberry Pi 4B</strong><br>
  Síntesis, programación y supervisión de lógica digital en una arquitectura compacta, modular y orientada a la experimentación.
</p>

---

## Descripción general

**iCesDuck** es una placa de desarrollo basada en la FPGA **Lattice iCE40UP5K**, diseñada para trasladar proyectos escritos en **Verilog** y **VHDL** desde la simulación HDL hasta su ejecución en hardware real.

La **Raspberry Pi 4B** funciona como sistema anfitrión y entorno principal de trabajo: realiza la síntesis, genera el bitstream, programa la FPGA y supervisa el comportamiento de la plataforma. Esta integración permite desarrollar, probar y depurar diseños digitales sin depender de herramientas propietarias o programadores externos especializados.

La placa incorpora recursos para trabajar con señales digitales y mixtas, entre ellos:

- FPGA programable **Lattice iCE40UP5K**.
- Convertidores **ADC** y **DAC**.
- Adaptadores de nivel lógico.
- Memoria de configuración.
- Reloj de **48 MHz**.
- Comunicación mediante **SPI**, **I²C** y **UART**.
- Conector **FFC/FPC** para expansión y acceso a señales externas.
- Conector GPIO espejo compatible con Raspberry Pi 4B.

<p align="center">
  <img
    src="docs/assets/images/ICD-IMG_02.png"
    alt="Vista frontal y posterior de la placa iCesDuck"
    width="560"
  >
</p>

> **Objetivo del proyecto:** ofrecer una plataforma abierta y documentada para aprender, investigar y prototipar sistemas digitales con FPGA, utilizando la Raspberry Pi como unidad de desarrollo, programación y supervisión.

---

## Características principales

| Característica | Especificación |
|---|---|
| **FPGA** | Lattice iCE40UP5K |
| **Capacidad lógica** | 5,280 LUTs |
| **Memoria interna** | 128 KB de SRAM |
| **Compatibilidad** | Raspberry Pi 4B |
| **Nivel lógico principal** | 3.3 V |
| **Interfaces** | SPI, I²C y UART |
| **Conversión de señales** | ADC y DAC integrados |
| **Reloj** | 48 MHz |
| **Lenguajes HDL** | Verilog y VHDL |
| **Toolchain** | APIO, Yosys, nextpnr e IceStorm |
| **Expansión** | GPIO espejo y conector FFC/FPC |

---

## Aplicaciones

- **Educación:** laboratorios de sistemas digitales, FPGA, arquitectura de computadores y electrónica embebida.
- **Investigación:** validación de controladores, interfaces digitales y lógica de propósito específico.
- **Prototipado:** pruebas funcionales antes de migrar un diseño a otra FPGA o a una solución dedicada.
- **Depuración HDL:** ejecución de testbench, comparación de resultados y validación en hardware real.
- **Señales mixtas:** adquisición, procesamiento y generación de señales mediante ADC, DAC y adaptadores de nivel.

---

## Navegación del repositorio

El repositorio se divide por áreas para separar el diseño físico, el software, la lógica HDL, las pruebas y la documentación.

| Área | Contenido |
|---|---|
| [`hardware/`](hardware/) | Revisiones del PCB, fuentes de EasyEDA, archivos de fabricación, exportaciones y validaciones. |
| [`software/`](software/) | Herramientas ejecutadas en Raspberry Pi, incluido el cargador de la FPGA. |
| [`hdl/`](hdl/) | Diseños Verilog/VHDL, restricciones, testbench y bitstreams. |
| [`examples/`](examples/) | Ejemplos funcionales y proyectos demostrativos. |
| [`tests/`](tests/) | Pruebas de hardware, software y lógica HDL. |
| [`docs/`](docs/) | Arquitectura, instalación, protocolos, hardware, red y recursos técnicos. |

### Revisiones de hardware

| Revisión | Estado | Ubicación |
|---|---|---|
| **V1.A1** | Primera revisión funcional con errores identificados | [`hardware/boards/v1-a1/`](hardware/boards/v1-a1/) |
| **V2.A1** | Revisión en desarrollo | [`hardware/boards/v2-a1/`](hardware/boards/v2-a1/) |

---

## Estado del proyecto

| Fecha | Versión | Estado | Notas |
|---|---|---|---|
| **05-03-2025** | **V1.A1** | Funcional | Placa ensamblada, FPGA programada correctamente, reguladores de 3.3 V y 1.2 V estables y reloj de 48 MHz validado. ADC y DAC pendientes de validación completa. |
| **17-09-2025** | **V1.A1** | Fallo identificado | Se detectó un cruce incorrecto en líneas de comunicación relacionadas con la memoria de configuración y los GPIO de la Raspberry Pi 4B. La FPGA puede programarse directamente, pero no conserva la configuración después de un reinicio. |
| **Planificada: 03-08-2026** | **V2.A1** | En desarrollo | Corrección de líneas de comunicación, revisión de SPI, I²C y UART, ampliación de documentación y preparación de nuevos ejemplos funcionales. |

---

## Arquitectura del sistema

iCesDuck utiliza una arquitectura **host-dispositivo**:

- **Raspberry Pi 4B:** sintetiza el diseño HDL, genera el bitstream, controla la carga de la FPGA, supervisa señales de estado y registra resultados.
- **iCesDuck:** ejecuta la lógica programada, administra las interfaces de entrada/salida y proporciona acceso a los bloques ADC, DAC, memoria, reloj y expansión.

La interfaz **SPI** se utiliza principalmente para la configuración de la FPGA. Las interfaces **UART** e **I²C** quedan disponibles para comunicación, control de periféricos y transferencia de datos durante la ejecución.

### Componentes principales

#### Raspberry Pi 4B

La Raspberry Pi proporciona:

- Entorno de desarrollo y compilación.
- Síntesis de Verilog y VHDL.
- Generación del archivo `hardware.bin`.
- Programación de la FPGA.
- Supervisión de señales como `CDONE`.
- Registro y depuración en tiempo real.

#### FPGA Lattice iCE40UP5K

La FPGA proporciona:

- 5,280 LUTs para lógica combinacional y secuencial.
- 128 KB de SRAM.
- Multiplicadores embebidos.
- PLL para generación y ajuste de frecuencias.
- Compatibilidad con herramientas de síntesis de código abierto.

---

## Flujo de trabajo

1. **Diseño HDL:** el usuario desarrolla el proyecto en Verilog o VHDL.
2. **Síntesis:** APIO, Yosys y nextpnr procesan el diseño.
3. **Generación:** se produce el bitstream `hardware.bin`.
4. **Carga:** la Raspberry Pi transmite el bitstream hacia la FPGA mediante SPI.
5. **Ejecución:** la FPGA implementa la lógica programada.
6. **Supervisión:** la Raspberry Pi verifica señales de estado y registra resultados.

Este flujo facilita ciclos rápidos de diseño, prueba, corrección y validación sobre hardware real.

---

## Visión del proyecto

iCesDuck nace con el propósito de acercar el desarrollo con FPGA a estudiantes, investigadores y profesionales mediante una plataforma abierta, accesible y reproducible.

El proyecto busca reducir la separación entre la simulación HDL y la implementación física, integrando en una sola plataforma la síntesis, la programación, la supervisión y el acceso a señales digitales y mixtas.

Actualmente, iCesDuck se encuentra en una etapa de **maduración técnica**. Las revisiones de hardware, el software de carga, los ejemplos y la documentación continúan evolucionando conforme se validan nuevos bloques y se corrigen los problemas identificados en versiones anteriores.

---

## Contribuciones

Las contribuciones pueden incluir:

- Reportes de errores.
- Validación de nuevas revisiones de hardware.
- Mejoras en el cargador de la FPGA.
- Ejemplos Verilog o VHDL.
- Testbench y pruebas automatizadas.
- Correcciones y ampliaciones de documentación.

Antes de realizar cambios importantes, revisa la estructura del repositorio y procura mantener separadas las áreas de hardware, software, HDL, pruebas y documentación.

---

## Agradecimientos

- **FPGAwars**, por APIO y su ecosistema de herramientas.
- **Clifford Wolf**, por IceStorm y Yosys.
- **YosysHQ**, por nextpnr y herramientas relacionadas.
- Comunidad de hardware y software de código abierto.

---

## Recursos externos

- [Lattice Semiconductor](https://www.latticesemi.com/)
- [APIO](https://github.com/FPGAwars/apio)
- [Project IceStorm](https://github.com/YosysHQ/icestorm)
- [Yosys](https://github.com/YosysHQ/yosys)
- [nextpnr](https://github.com/YosysHQ/nextpnr)
- [Documentación de GPIO de Raspberry Pi](https://www.raspberrypi.com/documentation/computers/raspberry-pi.html)

---

## Licencia

Este proyecto se distribuye bajo una licencia abierta. Consulta el archivo [`LICENSE`](LICENSE) para conocer sus términos y condiciones.

---

<p align="center">
  <strong>iCesDuck</strong><br>
  FPGA · Raspberry Pi · Verilog · VHDL · Open Source
</p>
