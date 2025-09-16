#!/bin/bash

# -----------------------------------------------------------------------------
# Script: check_dns.sh
# Descripción: Realiza una consulta DNS y extrae la IP final, siguiendo CNAMEs si es necesario.
# Uso: DNS_SERVER="8.8.8.8" ./src/check_dns.sh www.google.com
# -----------------------------------------------------------------------------

# Modo estricto para un script robusto
set -euo pipefail

# Validar que se recibió un argumento (el dominio)
if [ $# -eq 0 ]; then
    echo "Error: No se proporcionó un dominio."
    echo "Uso: $0 <dominio.com>"
    exit 1
fi

readonly DOMAIN_TO_CHECK="$1"
readonly DNS_SERVER_TO_USE="${DNS_SERVER:-1.1.1.1}"
readonly OUTPUT_DIR="out/dns_checks"
mkdir -p "${OUTPUT_DIR}"
readonly OUTPUT_FILE="${OUTPUT_DIR}/result_${DOMAIN_TO_CHECK//\//_}.txt" # Reemplaza / en el nombre

# Ejecutar la consulta y procesar la salida
echo "--- Consultando el dominio '$DOMAIN_TO_CHECK' usando el servidor DNS '$DNS_SERVER_TO_USE' ---"

# NUEVA LÓGICA MEJORADA:
#   - dig +noall +answer: Muestra solo la sección de respuesta, que contiene CNAMEs y el A final.
#   - grep -E '\sA\s': Filtra solo las líneas que son registros A.
#   - awk '{print $NF}': Imprime el último campo de la línea, que es la IP.
#   - tail -n1: Se asegura de que solo obtengamos una IP si el dominio tiene varias.
FINAL_IP=$(dig "@${DNS_SERVER_TO_USE}" "${DOMAIN_TO_CHECK}" +noall +answer | grep -E '\sA\s' | awk '{print $NF}' | tail -n1)


# Validamos si obtuvimos una IP
if [ -z "$FINAL_IP" ]; then
    RESULT_MESSAGE="No se pudo obtener la dirección IP final para '$DOMAIN_TO_CHECK'. Puede ser un dominio inválido o no tener registro A."
    echo "$RESULT_MESSAGE" | tee "${OUTPUT_FILE}"
    exit 1
else
    RESULT_MESSAGE="La IP de '$DOMAIN_TO_CHECK' es: $FINAL_IP"
    echo "$RESULT_MESSAGE" | tee "${OUTPUT_FILE}"
    echo "Evidencia guardada en: ${OUTPUT_FILE}"
fi