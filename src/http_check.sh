#!/usr/bin/env bash
#Este script verificará el código de estado HTTP,
#dependiendo del chequeo DNS prvio

#Salir en caso de error y manejo de interrupciones 
set -euo pipefail
trap "echo 'Proceso interrumpido por el usuario.'; exit 1" SIGINT SIGTERM

# CHEQUEO DE ESTADO HTTP
if [ $# -eq 0 ]; then
    echo "Error: No se proporcionó un host." >&2
    echo "Uso: $0 <dominio.com>" >&2
    exit 1
fi
readonly URL="$1"
# Extraer solo el dominio, sin http:// ni ruta
readonly DOMAIN=$(echo "$URL" | sed -E 's|https?://([^/]+)/?.*|\1|')

echo "Verificando HTTP para $URL"
echo "[Paso 1/2] Verificando DNS..."
if IP_ADDRESS=$(src/check_dns.sh "$DOMAIN"); then
    echo "DNS OK. La IP de '${DOMAIN}' es: ${IP_ADDRESS}"

    echo "[Paso 2/2] Verificando código de estado HTTP..."
    http_code=$(curl -sL -o /dev/null -w "%{http_code}" "$URL")

    # Validar resultado
    if [[ "$http_code" == "200" || "$http_code" == "301" ]]; then
        echo "Chequeo HTTP exitoso. Código obtenido: ${http_code} (OK)."
        exit 0
    else
        echo "ALERTA: Chequeo HTTP falló. Se obtuvo '${http_code}'." >&2
        exit 1
    fi
else
    #para cuando el DNS da un código de error 1
    echo "Fallo de DNS. No se puede continuar con el chequeo HTTP." >&2
    exit 1
fi

