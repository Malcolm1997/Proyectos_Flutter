# 🧰 Backend IoT - Servidor MQTT (Mosquitto)

Este directorio contiene la infraestructura necesaria para desplegar el Broker MQTT en el servidor local (Raspberry Pi). Utilizamos **Docker** para mantener el entorno aislado, limpio y fácil de replicar.

## 📂 Estructura de Directorios en la Raspberry Pi

Aunque en este proyecto local guardamos la configuración ("la receta"), en la Raspberry Pi (el servidor de producción) la estructura de carpetas física es la siguiente:

```text
/home/pi/texel-iot/          <-- Carpeta Raíz del Proyecto en RPi
│
└── backend/                 <-- Contexto de Docker
    │
    ├── docker-compose.yml   <-- Orquestador del contenedor
    │
    ├── config/
    │   └── mosquitto.conf   <-- Archivo de configuración (Permisos/Puertos)
    │
    ├── data/                <-- Persistencia (Base de datos de mensajes retenidos)
    │
    └── log/                 <-- Registros del sistema
        └── mosquitto.log    <-- Archivo vital para depuración (debug)