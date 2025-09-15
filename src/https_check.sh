#!/usr/bin/env bash
set -euo pipefail

# ANÁLISIS DE TLS/HTTPS
if [ $# -eq 0 ]; then
    echo "Error en analyze_https: No se proporcionó un host." >&2
    exit 1
fi

host="$1"
echo "Analizando HTTPS/TLS para ${host}"

# Obtener información TLS
tls_info=$(curl -sv "https://${host}" -o /dev/null 2>&1 | grep "TLSv")

if [[ -n "$tls_info" ]]; then
    echo "Información de TLS encontrada: ${tls_info}"
    exit 0
else
    echo "No se pudo obtener información de TLS."
    exit 1
fi