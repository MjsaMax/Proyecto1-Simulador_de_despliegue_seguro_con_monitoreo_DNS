#!/bin/bash

# -----------------------------------------------------------------------------
# Script: check_dns.sh
# Descripción: Realiza una consulta DNS a un dominio específico.
# Uso: DNS_SERVER="8.8.8.8" ./src/check_dns.sh google.com
# -----------------------------------------------------------------------------

# 1. Modo estricto para un script robusto
#    -e: termina el script si un comando falla
#    -u: termina si se usa una variable no definida
#    -o pipefail: la tubería falla si cualquier comando en ella falla
set -euo pipefail

# 2. Validar que se recibió un argumento (el dominio)
if [ $# -eq 0 ]; then
    echo "Error: No se proporcionó un dominio."
    echo "Uso: $0 <dominio.com>"
    exit 1
fi

# 3. Asignar los argumentos a variables claras
readonly DOMAIN_TO_CHECK="$1"

# 4. Validar y usar la variable de entorno DNS_SERVER
#    Si la variable DNS_SERVER está vacía o no está definida, usa "1.1.1.1" por defecto.
readonly DNS_SERVER_TO_USE="${DNS_SERVER:-1.1.1.1}"

# 5. Ejecutar la consulta DNS y mostrar la salida
echo "--- Consultando el dominio '$DOMAIN_TO_CHECK' usando el servidor DNS '$DNS_SERVER_TO_USE' ---"
dig "@${DNS_SERVER_TO_USE}" "${DOMAIN_TO_CHECK}"