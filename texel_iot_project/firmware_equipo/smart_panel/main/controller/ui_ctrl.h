/*
 * main/app/ui_ctrl.h
 * Controlador de la Interfaz de Usuario
 */
#pragma once
#include <stdbool.h>

#ifdef __cplusplus
extern "C" {
#endif

// Inicializa el estado base de la UI (iconos apagados, etc.)
void ui_ctrl_init(void);

// Actualiza el texto del reloj con la hora del sistema
void ui_ctrl_update_clock(void);

// Cambia el estado visual del ícono de WiFi
void ui_ctrl_set_wifi_state(bool connected);

// Cambia el estado visual del ícono de MQTT (Nube)
void ui_ctrl_set_mqtt_state(bool connected);

#ifdef __cplusplus
}
#endif