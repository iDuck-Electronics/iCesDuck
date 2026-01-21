#include ".tempHex.c"

#include <stdio.h>
#include <stdlib.h>

#include <bcm2835.h>

#define SDO     RPI_BPLUS_GPIO_J8_35
#define SCLK    RPI_BPLUS_GPIO_J8_36
#define CSN     RPI_BPLUS_GPIO_J8_37
#define SDI     RPI_BPLUS_GPIO_J8_38
#define CRESETB RPI_BPLUS_GPIO_J8_40
#define CDONE   RPI_BPLUS_GPIO_J8_15

const char *nombre_archivo_entrada = "hardware.bin";
const char *nombre_archivo_salida = ".tempHex.c";

void convertir_binario_a_c(const char *nombre_archivo_entrada, const char *nombre_archivo_salida) {
    FILE *bFile = fopen(nombre_archivo_entrada, "rb");
    FILE *hFile = fopen(nombre_archivo_salida, "w");
    if (bFile == NULL || hFile == NULL) {
        perror("Error al abrir el archivo");
        return;
    }
    fseek(bFile, 0, SEEK_END);
    long n = ftell(bFile);
    fseek(bFile, 0, SEEK_SET);
    unsigned char *bData = (unsigned char *)malloc(n * sizeof(unsigned char));
    if (bData == NULL) {
        perror("Error de asignación de memoria");
        fclose(bFile);
        fclose(hFile);
        return;
    }
    fread(bData, sizeof(unsigned char), n, bFile);
    fprintf(hFile, "char bitmap[] = {");
    fprintf(hFile, "0x%02x", bData[0]);
    for (int i = 1; i < n; i++) {
        fprintf(hFile, ", 0x%02x", bData[i]);
    }
    fprintf(hFile, "};");
    free(bData);
    fclose(bFile);
    fclose(hFile);
}

void assert_sdo() {
    bcm2835_gpio_write(SDO, HIGH);
}

void dessert_sdo() {
    bcm2835_gpio_write(SDO, LOW);
}

void assert_sclk() {
    bcm2835_gpio_write(SCLK, HIGH);
}

void dessert_sclk() {
    bcm2835_gpio_write(SCLK, LOW);
}

void sendbyte(char data) {
    unsigned char temp;
    int i;
    temp = data;
    for (i = 0; i < 8; i++) {
        if ((temp & 128) > 0)
            assert_sdo();
        else
            dessert_sdo();
        assert_sclk();
        dessert_sclk();
        temp = temp << 1;
    }
}

void assert_ss() {
    bcm2835_gpio_write(CSN, LOW);
}

void dessert_ss() {
    bcm2835_gpio_write(CSN, HIGH);
}

void init_spi() {
    bcm2835_gpio_fsel(CSN, BCM2835_GPIO_FSEL_OUTP);
    bcm2835_gpio_fsel(SCLK, BCM2835_GPIO_FSEL_OUTP);
    bcm2835_gpio_fsel(CRESETB, BCM2835_GPIO_FSEL_OUTP);
    bcm2835_gpio_fsel(SDO, BCM2835_GPIO_FSEL_OUTP);
    bcm2835_gpio_fsel(SDI, BCM2835_GPIO_FSEL_INPT);
}

void config() {
    int i;
    init_spi();
    printf("El programa está en ejecución!\n");
    assert_ss();
    char pdone = 0;
    bcm2835_gpio_write(CRESETB, LOW);
    bcm2835_delay(10);
    while (bcm2835_gpio_lev(CDONE) == HIGH) {};
    printf("CDONE está bajo!\n");
    bcm2835_gpio_write(CRESETB, HIGH);
    delay(2000);
    bcm2835_delay(1);
    for (i = 0; i < 200000; i++) {
        if (i < sizeof(bitmap)) {
            sendbyte(bitmap[i]);
        } else {
            sendbyte(0);
        }
        if ((pdone == 0) && (bcm2835_gpio_lev(CDONE) == HIGH)) {
            printf("¡CDONE es Alto! Fin de la Configuración!\n");
            pdone = 1;
            break;
        }
    }
    if (pdone == 0) {
        printf("¡CDONE está Bajo! Error de Configuración!\n");
    }
    dessert_ss();
}

int main(int argc, char **argv) {
    convertir_binario_a_c(nombre_archivo_entrada, nombre_archivo_salida);
    printf("Conversión completada.\n");

    if (!bcm2835_init()) {
        printf("Problemas al iniciar BCM2835...\n");
        return 1;
    } else {
        config();
    }

    return 0;
}

// Codigo de conversion y carga por SPI para FPGA-LATTICE-iCE40UP5K.
// Mediante GPIO de una Raspberry Pi 4B.

