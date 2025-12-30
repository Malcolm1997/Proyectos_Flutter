/*
 * main/app/app_sntp.c - Sincronización de Hora (Clean Version)
 */
#include <string.h>
#include <time.h>
#include <sys/time.h>
#include "esp_system.h"
#include "esp_log.h"
#include "esp_sntp.h"

static const char *TAG = "APP_SNTP";

/* Callback: Se ejecuta cuando la hora se actualiza correctamente */
void time_sync_notification_cb(struct timeval *tv)
{
    ESP_LOGI(TAG, "¡Hora sincronizada desde Internet!");
    
    // Imprimir la hora actual para confirmar
    time_t now;
    struct tm timeinfo;
    time(&now);
    localtime_r(&now, &timeinfo);
    
    char strftime_buf[64];
    strftime(strftime_buf, sizeof(strftime_buf), "%c", &timeinfo);
    ESP_LOGI(TAG, "Fecha/Hora Actual (Argentina): %s", strftime_buf);
}

void app_sntp_init(void)
{
    ESP_LOGI(TAG, "Iniciando servicio SNTP...");

    // 1. Configuración básica de SNTP
    esp_sntp_setoperatingmode(SNTP_OPMODE_POLL);
    
    // Usamos el pool global (el más rápido y fiable)
    esp_sntp_setservername(0, "pool.ntp.org");
    
    // Configuramos el callback para saber cuándo se actualizó
    esp_sntp_set_time_sync_notification_cb(time_sync_notification_cb);
    
    esp_sntp_init();

    // 2. Configurar Zona Horaria (Argentina: UTC-3)
    // El formato "ART3" significa: Nombre ART, Offset UTC+3 (positivo hacia el oeste en POSIX)
    // Si necesitas otra zona, cámbialo aquí.
    setenv("TZ", "ART3", 1);
    tzset();

    ESP_LOGI(TAG, "SNTP iniciado. Esperando conexión WiFi para sincronizar...");
}