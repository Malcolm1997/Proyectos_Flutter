# 1. Buscamos fuentes de la UI (ahora en view/ui)
file(GLOB_RECURSE UI_SOURCES "view/ui/*.c")

# 2. Buscamos fuentes (fonts y assets si son .c)
file(GLOB_RECURSE ASSET_SOURCES "view/fonts/*.c" "view/assets/*.c")

# 3. Registramos todo
idf_component_register(SRCS "main.c"
                            "model/app_wifi.c"
                            "model/app_sntp.c"
                            "model/app_mqtt.c"
                            "controller/ui_ctrl.c" # O ui_ctrl.c si no lo renombraste
                            ${UI_SOURCES}
                            ${ASSET_SOURCES}
                       INCLUDE_DIRS "." 
                                    "model" 
                                    "view/ui" 
                                    "controller")