#!/bin/bash

# -----------------------------------------------------------------------------
# Script: check_dns.sh
# Descripción: Realiza una consulta DNS y extrae la IP final, siguiendo CNAMEs si es necesario.
# Uso: DNS_SERVER="8.8.8.8" ./src/check_dns.sh www.google.com
# -----------------------------------------------------------------------------

set -euo pipefail

# --- Función de limpieza y comando trap ---
cleanup() {
  # Esta función se ejecutará cuando el script termine.
  echo "--- Script de verificación DNS finalizado ---"
}
trap cleanup EXIT

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
readonly OUTPUT_FILE="${OUTPUT_DIR}/result_${DOMAIN_TO_CHECK//\//_}.txt" 

# Ejecutar la consulta y procesar la salida
echo "--- Consultando el dominio '$DOMAIN_TO_CHECK' usando el servidor DNS '$DNS_SERVER_TO_USE' ---"

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