/*
 * main/app/ui_ctrl.c - Iconos Ocultos + Debug Reloj
 */
#include <time.h>
#include <stdio.h>
#include "esp_log.h"
#include "bsp/esp-bsp.h"   
#include "lvgl.h"
#include "ui_ctrl.h"

// Includes de tu interfaz
#include "ui.h"      
#include "screens.h" //

static const char *TAG = "UI_CTRL";

/* Función auxiliar: Ocultar si inactivo, Mostrar si activo */
static void set_icon_visual_state(lv_obj_t *obj, bool active)
{
    if (obj == NULL) return; 

    bsp_display_lock(0);
    if (active) {
        // CONECTADO: Quitar bandera "HIDDEN" para que se vea
        lv_obj_clear_flag(obj, LV_OBJ_FLAG_HIDDEN);
        
        // Restaurar opacidad por si acaso
        lv_obj_set_style_img_recolor_opa(obj, LV_OPA_0, 0); 
        lv_obj_set_style_img_opa(obj, LV_OPA_COVER, 0);    
    } else {
        // DESCONECTADO: Poner bandera "HIDDEN" para que desaparezca
        lv_obj_add_flag(obj, LV_OBJ_FLAG_HIDDEN);
    }
    bsp_display_unlock();
}

void ui_ctrl_init(void)
{
    ESP_LOGI(TAG, "UI Ctrl Init: Ocultando iconos por defecto...");
    // Al arrancar, ocultamos los iconos hasta que conecten
    ui_ctrl_set_wifi_state(false);
    ui_ctrl_set_mqtt_state(false);
}

void ui_ctrl_update_clock(void)
{
    time_t now;
    struct tm timeinfo;
    time(&now);
    localtime_r(&now, &timeinfo);

    // Si el año < 2024, SNTP no sincronizó o falló. No actualizamos.
    if (timeinfo.tm_year < (2024 - 1900)) return; 

    char time_str[16];
    snprintf(time_str, sizeof(time_str), "%02d:%02d", timeinfo.tm_hour, timeinfo.tm_min);

    bsp_display_lock(0);
        if (objects.lbl_clock != NULL) { 
            // Si el objeto existe, actualizamos el texto
            lv_label_set_text(objects.lbl_clock, time_str);
        } else {
            // ¡OJO! Si ves este error en el monitor, es que EEZ no creó el objeto
            ESP_LOGE(TAG, "ERROR CRÍTICO: objects.lbl_clock es NULL. Revisa ui.c");
        }
    bsp_display_unlock();
}

void ui_ctrl_set_wifi_state(bool connected)
{
    if (objects.icon_wifi) {
        set_icon_visual_state(objects.icon_wifi, connected);
    }
}

void ui_ctrl_set_mqtt_state(bool connected)
{
    // Usamos 'icon_mqtt' como aparece en tu screens.h
    if (objects.icon_mqtt) {
        set_icon_visual_state(objects.icon_mqtt, connected);
    }
}