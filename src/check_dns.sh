#!/bin/bash

# -----------------------------------------------------------------------------
# Script: check_dns.sh
# Descripción: Realiza una consulta DNS y extrae la dirección IP del registro A.
# Uso: DNS_SERVER="8.8.8.8" ./src/check_dns.sh google.com
# -----------------------------------------------------------------------------

# 1. Modo estricto para un script robusto
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
readonly DNS_SERVER_TO_USE="${DNS_SERVER:-1.1.1.1}"

# 5. Ejecutar la consulta, procesar la salida y mostrar el resultado
echo "--- Consultando el dominio '$DOMAIN_TO_CHECK' usando el servidor DNS '$DNS_SERVER_TO_USE' ---"

# Ejecutamos el pipeline para obtener la IP
#   - dig ...        : Realiza la consulta DNS.
#   - grep -E '\sA\s' : Filtra las líneas que contienen un registro A (con espacios para ser preciso).
#   - awk '{print $NF}' : De las líneas filtradas, imprime ($print) el último campo ($NF).
IP_ADDRESS=$(dig "@${DNS_SERVER_TO_USE}" "${DOMAIN_TO_CHECK}" | grep -E '\sA\s' | awk '{print $NF}')

# Validamos si obtuvimos una IP
if [ -z "$IP_ADDRESS" ]; then
    echo "No se pudo obtener la dirección IP para '$DOMAIN_TO_CHECK'."
    exit 1
else
    echo "La IP de '$DOMAIN_TO_CHECK' es: $IP_ADDRESS"
fi