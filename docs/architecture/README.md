#### Flujo de programación

El proceso de carga del diseño en la FPGA consta de tres etapas:

  #### Inclusión de dependencias

  El programa requiere dos inclusiones fundamentales:

  ```C
  #include ".tempHex.c"      // Vector hexadecimal del bitstream
  #include <bcm2835.h>       // Control de GPIO
  ```

  **`.tempHex.c`**: Archivo generado por `convertir_binario_a_c()` que contiene el vector `bitmap[]` con los datos del bitstream en formato hexadecimal. **`bcm2835.h`**: Librería de bajo nivel que proporciona mapeo de pines GPIO y funciones de acceso directo

  #### Variables de almacenamiento

  En esta sección se definen las rutas de los archivos de entrada y salida para el proceso de conversión:
  
  ```C
  const char *nombre_archivo_entrada = "hardware.bin";
  const char *nombre_archivo_salida  = ".tempHex.c";
  ```
  
  Estas constantes permiten identificar el bitstream generado por APIO y especificar dónde almacenar el archivo intermedio C. Este diseño facilita cambios de rutas sin modificación del código fuente principal.

  #### Conversión del bitstream binario a código C

  Etapa fundamental que transforma el archivo binario del bitstream en un vector C compilable. La función `convertir_binario_a_c()` realiza esta conversión de forma automática:

  <p align="center">
  <img src="Documents/Images/Drawing/CTRL-Bin_Hex.png" alt="Flujo de conversión de bitstream binario a código C" width="280">
  </p>

  ```C
  void convertir_binario_a_c(const char *nombre_archivo_entrada,
                             const char *nombre_archivo_salida);
  ```
  El algoritmo implementa los siguientes pasos:

  1. **Lectura binaria**: Abre `hardware.bin` en modo lectura binaria.
  2. **Iteración**: Recorre cada byte del fichero secuencialmente.
  3. **Conversión hexadecimal**: Transforma cada valor a notación hexadecimal (`0xXX`).
  4. **Generación de vector**: Construye el vector `bitmap[]` completo con todos los bytes.
  5. **Cierre de ficheros**: Finaliza la operación cerrando ambos ficheros.

  El resultado es un fichero C que contiene el bitstream en formato adecuado para inclusión directa en el código fuente, dentro de este archivo se genera la siguiente estructura:
  El resultado es un fichero C que contiene el bitstream como un array de bytes, listo para inclusión directa en el código fuente. Ejemplo del contenido generado:

  ```c
  char bitmap[] = { 0x00, 0xAF, 0x10, ... };
  ```

  El fichero (por ejemplo `.tempHex.c`) se incorpora con `#include ".tempHex.c"` y proporciona `bitmap` y su longitud. El firmware transmite estos bytes por SPI (bit-banging) desde la Raspberry Pi hacia la FPGA usando los pines GPIO definidos; opcionalmente puede almacenarse en la EEPROM para persistencia.

  #### Mapeo de pines GPIO

  La interfaz SPI utiliza seis líneas GPIO del conector J8 de Raspberry Pi:
  
  ```C
  #define SDO     RPI_BPLUS_GPIO_J8_35    // Serial Data Out (MOSI)
  #define SCLK    RPI_BPLUS_GPIO_J8_36    // Serial Clock
  #define CSN     RPI_BPLUS_GPIO_J8_37    // Chip Select Negado
  #define SDI     RPI_BPLUS_GPIO_J8_38    // Serial Data In (MISO)
  #define CRESETB RPI_BPLUS_GPIO_J8_40    // Config Reset (activo bajo)
  #define CDONE   RPI_BPLUS_GPIO_J8_15    // Config Done (entrada)
  ```

  | Nombre | Pin J8 | Dirección | Descripción |
  |---|---|---|---|
  | **SDO** | 35 | Salida | Transmisión de datos → FPGA |
  | **SCLK** | 36 | Salida | Reloj de serialización |
  | **CSN** | 37 | Salida | Chip-Select (0 = activo) |
  | **SDI** | 38 | Entrada | Recepción de datos ← FPGA |
  | **CRESETB** | 40 | Salida | Reset de configuración (0 = reset) |
  | **CDONE** | 15 | Entrada | Indicador de carga completada |
  
  #### Operaciones de línea

  El firmware implementa funciones de manipulación de bajo nivel para cada señal:
  
  ```C
  void assert_sdo();      // Establecer SDO = 1
  void dessert_sdo();     // Establecer SDO = 0
  void assert_sclk();     // Establecer SCLK = 1
  void dessert_sclk();    // Establecer SCLK = 0
  void assert_ss();       // Establecer CSN = 0 (chip seleccionado)
  void dessert_ss();      // Establecer CSN = 1 (chip deseleccionado)
  void sendbyte(char data);  // Transmitir byte completo
  ```

  Estas funciones abstraen el control de GPIO, permitiendo la serialización sincronizada del bitstream.

  #### Compilación y ejecución

  El código fuente se compila enlazando contra la librería **bcm2835**:

  ```bash
  gcc -Wall -O2 iDuck-RP-Upload.c -o iDuck-RP-Upload -lbcm2835
  ```

  Flags utilizados:
  - `-Wall`: Habilita todos los warnings del compilador
  - `-O2`: Optimización de nivel 2 (rendimiento)
  - `-lbcm2835`: Enlace con la librería bcm2835

  La ejecución requiere privilegios de root para acceso directo a memoria GPIO:

  ```bash
  sudo ./iDuck-RP-Upload
  ```

  > **Importante**: El acceso a GPIO requiere ejecución con `sudo`. Se recomienda configurar el usuario dentro del grupo `gpio` para evitar esta requering en futuras ejecuciones.
  