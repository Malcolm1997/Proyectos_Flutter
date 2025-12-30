/*
 * main/app/app_mqtt.c - Con integración de UI
 */
#include <stdio.h>
#include <stdint.h>
#include <stddef.h>
#include <string.h>
#include "esp_wifi.h"
#include "esp_system.h"
#include "nvs_flash.h"
#include "esp_event.h"
#include "esp_netif.h"
#include "esp_log.h"
#include "mqtt_client.h"
#include "bsp/esp-bsp.h" 
#include "app_mqtt.h"

#include "ui_ctrl.h" // <--- IMPORTANTE

static const char *TAG = "APP_MQTT";
static esp_mqtt_client_handle_t client = NULL;

// AJUSTA TU IP DE NUEVO SI ES NECESARIO
#define MQTT_BROKER_URI "mqtt://192.168.100.107" 
#define MQTT_TOPIC_CMD  "texel/panel/led"

static void mqtt_event_handler(void *handler_args, esp_event_base_t base, int32_t event_id, void *event_data)
{
    switch ((esp_mqtt_event_id_t)event_id) {
    case MQTT_EVENT_CONNECTED:
        ESP_LOGI(TAG, "Conectado al Broker!");
        esp_mqtt_client_subscribe(client, MQTT_TOPIC_CMD, 0);
        
        // AVISO A LA UI: MOSTRAR NUBE
        ui_ctrl_set_mqtt_state(true);
        break;

    case MQTT_EVENT_DISCONNECTED:
        ESP_LOGW(TAG, "Desconectado del Broker");
        
        // AVISO A LA UI: OCULTAR NUBE
        ui_ctrl_set_mqtt_state(false);
        break;
        
    case MQTT_EVENT_DATA:
        // Procesar datos (igual que antes)
        break;
    default:
        break;
    }
}

void app_mqtt_start(void)
{
    esp_mqtt_client_config_t mqtt_cfg = {
        .broker.address.uri = MQTT_BROKER_URI,
    };
    client = esp_mqtt_client_init(&mqtt_cfg);
    esp_mqtt_client_register_event(client, ESP_EVENT_ANY_ID, mqtt_event_handler, NULL);
    esp_mqtt_client_start(client);
}