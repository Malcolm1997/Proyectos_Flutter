/*
 * main/app/app_wifi.h
 */
#pragma once
#include "esp_err.h"

#ifdef __cplusplus
extern "C" {
#endif

// Inicializa estructuras internas (llamar una vez)
void app_wifi_init(void);

// Arranca la lógica: o conecta directo o enciende el Bluetooth
void app_wifi_start(void);

#ifdef __cplusplus
}
#endif