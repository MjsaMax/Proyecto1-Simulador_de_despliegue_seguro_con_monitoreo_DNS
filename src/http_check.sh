#!/usr/bin/env bash
set -euo pipefail

# CHEQUEO DE ESTADO HTTP
if [ $# -eq 0 ]; then
    echo "Error: No se proporcionó un host." >&2
    exit 1
fi

host="$1"
echo "Verificando HTTP para ${host}"

#Obtener código HTTP
http_code=$(curl -sL -o /dev/null -w "%{http_code}" "http://${host}")

echo "El código obtenido fue: ${http_code}"

# Validar resultado
if [[ "$http_code" == "200" || "$http_code" == "301" ]]; then
    echo "El chequeo pasó."
    exit 0
else
    echo "El chequeo falló."
    exit 1
fi

