/*
 * main/app/app_mqtt.h
 */
#pragma once

#ifdef __cplusplus
extern "C" {
#endif

// Inicia y arranca el cliente MQTT
void app_mqtt_start(void);

// Publica un mensaje (útil para responder estado)
void app_mqtt_publish(const char *topic, const char *data);

#ifdef __cplusplus
}
#endif