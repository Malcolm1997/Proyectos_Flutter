/*
 * main/main.c - ORDEN DE INICIO CORREGIDO
 */
#include "freertos/FreeRTOS.h"
#include "freertos/task.h"
#include "esp_log.h"
#include "nvs_flash.h"
#include "nvs.h"

#include "bsp/esp-bsp.h" 
#include "esp_lvgl_port.h"

#include "ui.h"            
#include "app_wifi.h"  
#include "app_mqtt.h"  
#include "app_sntp.h"  
#include "ui_ctrl.h"   

static const char *TAG = "APP_MAIN";

void app_main(void)
{
    // 1. Inicializar NVS
    esp_err_t err = nvs_flash_init();
    if (err == ESP_ERR_NVS_NO_FREE_PAGES || err == ESP_ERR_NVS_NEW_VERSION_FOUND) {
        ESP_ERROR_CHECK(nvs_flash_erase());
        err = nvs_flash_init();
    }
    ESP_ERROR_CHECK(err);

    // Asegurar niveles de log para que se vean mensajes de conexión/aprovisionamiento
    ESP_LOGI(TAG, "Configurando niveles de log para APP_MAIN y APP_WIFI...");
    esp_log_level_set(TAG, ESP_LOG_INFO);
    esp_log_level_set("APP_WIFI", ESP_LOG_INFO);
    esp_log_level_set("UI_CTRL", ESP_LOG_INFO);

    // 2. Inicializar Conectividad (Sin bloquear)
    ESP_LOGI(TAG, "Iniciando WiFi y SNTP...");
    app_wifi_init();
    app_sntp_init();

    // 3. Inicializar Pantalla + LVGL
    ESP_LOGI(TAG, "Arrancando Hardware Gráfico...");
    bsp_display_start();     
    bsp_display_backlight_on(); 

    // 4. Cargar UI de EEZ Studio (CREAR LOS OBJETOS)
    ESP_LOGI(TAG, "Cargando Interfaz...");
    bsp_display_lock(0);
        ui_init(); 
    bsp_display_unlock();

    // 5. Inicializar Estado de la UI (OCULTAR ICONOS)
    // ¡AHORA SÍ! Como ui_init ya corrió, los objetos existen y se pueden ocultar.
    ui_ctrl_init();

    // 6. Arrancar Lógica de Red 
    ESP_LOGI(TAG, "Arrancando servicios de red...");
    app_wifi_start(); 
    app_mqtt_start(); 

    ESP_LOGI(TAG, "Sistema listo. Entrando en bucle principal...");

    // 7. Bucle Principal
    while (1) {
        ui_ctrl_update_clock(); 
        vTaskDelay(pdMS_TO_TICKS(1000));
    }
}