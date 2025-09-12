#!/bin/bash

# -----------------------------------------------------------------------------
# Script: check_dns.sh
# Descripción: Realiza una consulta DNS y extrae la dirección IP del registro A.
# Uso: DNS_SERVER="8.8.8.8" ./src/check_dns.sh google.com
# -----------------------------------------------------------------------------

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

#!/bin/bash

# 5. Ejecutar la consulta, procesar la salida y mostrar/guardar el resultado
echo "--- Consultando el dominio '$DOMAIN_TO_CHECK' usando el servidor DNS '$DNS_SERVER_TO_USE' ---"

# Creamos un directorio para los resultados de DNS si no existe
readonly OUTPUT_DIR="out/dns_checks"
mkdir -p "${OUTPUT_DIR}"

# Definimos el nombre del archivo de salida
readonly OUTPUT_FILE="${OUTPUT_DIR}/result_${DOMAIN_TO_CHECK}.txt"

# Ejecutamos el pipeline para obtener la IP
IP_ADDRESS=$(dig "@${DNS_SERVER_TO_USE}" "${DOMAIN_TO_CHECK}" +short A | head -n 1) # Usamos +short para una salida más limpia y head por si devuelve múltiples IPs

# Validamos si obtuvimos una IP
if [ -z "$IP_ADDRESS" ]; then
    # Guardamos el error en el archivo de salida usando tee
    echo "No se pudo obtener la dirección IP para '$DOMAIN_TO_CHECK'." | tee "${OUTPUT_FILE}"
    exit 1
else
    RESULT_MESSAGE="La IP de '$DOMAIN_TO_CHECK' es: $IP_ADDRESS"
    
    echo "$RESULT_MESSAGE" | tee "${OUTPUT_FILE}"
    echo "Evidencia guardada en: ${OUTPUT_FILE}"
fi