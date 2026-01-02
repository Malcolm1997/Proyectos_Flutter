/*
 * main/app/app_mqtt.c - Con integración de UI
 */
#include "app_mqtt.h"
#include "bsp/esp-bsp.h"
#include "esp_event.h"
#include "esp_log.h"
#include "esp_netif.h"
#include "esp_system.h"
#include "esp_wifi.h"
#include "mqtt_client.h"
#include "nvs_flash.h"
#include <stddef.h>
#include <stdint.h>
#include <stdio.h>
#include <string.h>

#include "ui_ctrl.h" // <--- IMPORTANTE

static const char *TAG = "APP_MQTT";
static esp_mqtt_client_handle_t client = NULL;

// AJUSTA TU IP DE NUEVO SI ES NECESARIO
#define MQTT_BROKER_URI "mqtt://192.168.100.107"
#define MQTT_TOPIC_CMD "texel/PS/101-112/A9zL2/status"
#define MQTT_TOPIC_EXIST "texel/PS/101-112/A9zL2/existo"

static void mqtt_event_handler(void *handler_args, esp_event_base_t base,
                               int32_t event_id, void *event_data) {
  switch ((esp_mqtt_event_id_t)event_id) {
  case MQTT_EVENT_CONNECTED:
    ESP_LOGI(TAG, "Conectado al Broker!");
    esp_mqtt_client_subscribe(client, MQTT_TOPIC_CMD, 0);
    esp_mqtt_client_publish(client, MQTT_TOPIC_CMD, "Online", 0, 1, 1);
    // Publicar existencia para registro en App (Retained)
    esp_mqtt_client_publish(client, MQTT_TOPIC_EXIST, "true", 0, 1, 1);

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

void app_mqtt_start(void) {
  esp_mqtt_client_config_t mqtt_cfg = {
      .broker.address.uri = MQTT_BROKER_URI,
      .session.last_will.topic = MQTT_TOPIC_CMD,
      .session.last_will.msg = "Offline",
      .session.last_will.qos = 1,
      .session.last_will.retain = 1,
      .session.keepalive = 10,
  };
  client = esp_mqtt_client_init(&mqtt_cfg);
  esp_mqtt_client_register_event(client, ESP_EVENT_ANY_ID, mqtt_event_handler,
                                 NULL);
  esp_mqtt_client_start(client);
}