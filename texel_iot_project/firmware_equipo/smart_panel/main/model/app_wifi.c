/*
 * main/model/app_wifi.c - Gestión de WiFi con Seguridad y UI
 */
#include <string.h>
#include <freertos/FreeRTOS.h>
#include <freertos/task.h>
#include <freertos/event_groups.h>
#include <esp_log.h>
#include <esp_wifi.h>
#include <esp_event.h>
#include <nvs_flash.h>
#include <wifi_provisioning/manager.h>
#include <wifi_provisioning/scheme_ble.h>

#include "app_wifi.h"
#include "ui_ctrl.h" // Controlador para actualizar la interfaz (MVC)

static const char *TAG = "APP_WIFI";

/* Genera el nombre del dispositivo: PROV_XXXXXX */
static void get_device_service_name(char *service_name, size_t max)
{
    uint8_t eth_mac[6];
    const char *ssid_prefix = "TXL_";
    esp_wifi_get_mac(WIFI_IF_STA, eth_mac);
    snprintf(service_name, max, "%s%02X%02X%02X",
             ssid_prefix, eth_mac[3], eth_mac[4], eth_mac[5]);
}

/* Manejador de eventos de WiFi e IP (Actualiza la UI) */
static void event_handler(void* arg, esp_event_base_t event_base,
                          int32_t event_id, void* event_data)
{
    if (event_base == WIFI_EVENT && event_id == WIFI_EVENT_STA_START) {
        esp_wifi_connect();
    } else if (event_base == WIFI_EVENT && event_id == WIFI_EVENT_STA_DISCONNECTED) {
        ESP_LOGI(TAG, "Desconectado. Reintentando...");
        
        // MVC: Avisamos a la Vista que oculte los iconos
        ui_ctrl_set_wifi_state(false);
        ui_ctrl_set_mqtt_state(false); 
        
        esp_wifi_connect();
    } else if (event_base == IP_EVENT && event_id == IP_EVENT_STA_GOT_IP) {
        ip_event_got_ip_t* event = (ip_event_got_ip_t*) event_data;
        ESP_LOGI(TAG, "Conectado! IP: " IPSTR, IP2STR(&event->ip_info.ip));
        
        // MVC: Avisamos a la Vista que muestre el icono de WiFi
        ui_ctrl_set_wifi_state(true); 
    }
}

/* Manejador de eventos de Aprovisionamiento (Logs) */
static void wifi_prov_event_handler(void *arg, esp_event_base_t event_base,
                                    int32_t event_id, void *event_data)
{
    if (event_base == WIFI_PROV_EVENT) {
        switch (event_id) {
            case WIFI_PROV_START:
                ESP_LOGI(TAG, "Aprovisionamiento Iniciado");
                break;
            case WIFI_PROV_CRED_RECV: {
                wifi_sta_config_t *wifi_sta_cfg = (wifi_sta_config_t *)event_data;
                ESP_LOGI(TAG, "Recibidas credenciales WiFi: SSID='%s'", (const char *) wifi_sta_cfg->ssid);
                break;
            }
            case WIFI_PROV_CRED_FAIL:
                ESP_LOGE(TAG, "Error de autenticación WiFi");
                break;
            case WIFI_PROV_CRED_SUCCESS:
                ESP_LOGI(TAG, "Aprovisionamiento Exitoso");
                break;
            case WIFI_PROV_END:
                wifi_prov_mgr_deinit();
                break;
            default:
                break;
        }
    }
}

void app_wifi_init(void)
{
    // Inicialización básica de red
    ESP_ERROR_CHECK(esp_netif_init());
    ESP_ERROR_CHECK(esp_event_loop_create_default());
    esp_netif_create_default_wifi_sta();

    wifi_init_config_t cfg = WIFI_INIT_CONFIG_DEFAULT();
    ESP_ERROR_CHECK(esp_wifi_init(&cfg));

    // Registro de eventos
    ESP_ERROR_CHECK(esp_event_handler_register(WIFI_PROV_EVENT, ESP_EVENT_ANY_ID, &wifi_prov_event_handler, NULL));
    ESP_ERROR_CHECK(esp_event_handler_register(WIFI_EVENT, ESP_EVENT_ANY_ID, &event_handler, NULL));
    ESP_ERROR_CHECK(esp_event_handler_register(IP_EVENT, IP_EVENT_STA_GOT_IP, &event_handler, NULL));
}

void app_wifi_start(void)
{
    // Configuración del Gestor (Usando BLE)
    wifi_prov_mgr_config_t config = {
        .scheme = wifi_prov_scheme_ble,
        .scheme_event_handler = WIFI_PROV_SCHEME_BLE_EVENT_HANDLER_FREE_BTDM
    };

    ESP_ERROR_CHECK(wifi_prov_mgr_init(config));

    bool provisioned = false;
    ESP_ERROR_CHECK(wifi_prov_mgr_is_provisioned(&provisioned));

    if (!provisioned) {
        ESP_LOGI(TAG, "Sin WiFi. Iniciando modo Aprovisionamiento (BLE)...");
        
        char service_name[12];
        get_device_service_name(service_name, sizeof(service_name));

        // --- CONFIGURACIÓN DE SEGURIDAD (Igual al ejemplo oficial) ---
        // Usamos Seguridad 1 (Intercambio de claves seguro)
        wifi_prov_security_t security = WIFI_PROV_SECURITY_1;

        // Proof of Possession (PoP): La contraseña para configurar el equipo.
        // Debe coincidir con lo que envíe la App Móvil.
        const char *pop = "abcd1234"; 

        // Iniciamos el servicio
        // Pasamos 'pop' como parámetro de seguridad
        ESP_ERROR_CHECK(wifi_prov_mgr_start_provisioning(security, pop, service_name, NULL));
        
        ESP_LOGW(TAG, ">>> ABRE TU APP Y BUSCA: %s (PoP: %s) <<<", service_name, pop);
    } else {
        ESP_LOGI(TAG, "Credenciales WiFi encontradas. Conectando...");
        
        // Liberamos memoria del gestor porque ya no lo necesitamos
        wifi_prov_mgr_deinit();
        
        ESP_ERROR_CHECK(esp_wifi_set_mode(WIFI_MODE_STA));
        ESP_ERROR_CHECK(esp_wifi_start());
    }
}