#!/usr/bin/env bash
set -euo pipefail

check_http() {
    local host="$1"
    echo "Verficando HTTP para ${host}"
    local http_code=$(curl -sL -o /dev/null -w "%{http_code}" "http://${host}")
    echo "El código obtenido fue: ${http_code}"

    if [[ "$http_code" == "200" || "$http_code" == "301" ]]; then
        echo "El chequeo pasó."
        return 0
    else
        echo "El chequo falló."
        return 1
    fi
}

analyze_https(){
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

main(){
    local target_host="google.com"
    echo "Iniciando Simulador de Despliegue"
    check_http "$target_host" 
    analyze_https "$target_host"
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main
fi