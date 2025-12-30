cmake_minimum_required(VERSION 3.5)
include($ENV{IDF_PATH}/tools/cmake/project.cmake)

# Se eliminó EXTRA_COMPONENT_DIRS porque ya no usamos componentes externos en esa carpeta

add_compile_options(-fdiagnostics-color=always 
                    -Wno-format 
                    -DLV_LVGL_H_INCLUDE_SIMPLE
                    -Wno-ignored-qualifiers
                    -Wno-unused-function
                    -Wno-unused-variable)

project(smart-panel)