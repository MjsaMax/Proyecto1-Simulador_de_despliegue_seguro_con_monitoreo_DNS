#!/usr/bin/env bash
set -euo pipefail

# CHEQUEO DE ESTADO HTTP
check_http() {
    if [ $# -eq 0 ]; then
        echo "Error en check_http: No se proporcionó un host." >&2
        return 1
    fi

    local host="$1"
    echo "Verificando HTTP para ${host}"

    local http_code=$(curl -sL -o /dev/null -w "%{http_code}" "http://${host}")

    echo "El código obtenido fue: ${http_code}"

    if [[ "$http_code" == "200" || "$http_code" == "301" ]]; then
        echo "El chequeo pasó."
        return 0
    else
        echo "El chequeo falló."
        return 1
    fi
}

# ANÁLISIS DE TLS/HTTPS

analyze_https(){
    if [ $# -eq 0 ]; then
        echo "Error en analyze_https: No se proporcionó un host." >&2
        return 1
    fi
    
    local host="$1"
    echo "Analizando HTTPS/TLS para ${host}"

    local tls_info=$(curl -sv "https://${host}" -o /dev/null 2>&1 | grep "TLSv")

    if [[ -n "$tls_info" ]]; then
        echo "Información de TLS encontrada: ${tls_info}"
        return 0
    else
        echo "No se pudo obtener información de TLS."
        return 1
    fi
}
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    case "$1" in
      http)  check_http "$2" ;;
      https) analyze_https "$2" ;;
      *) echo "Uso: $0 [http|https] dominio" ;;
    esac
fi

