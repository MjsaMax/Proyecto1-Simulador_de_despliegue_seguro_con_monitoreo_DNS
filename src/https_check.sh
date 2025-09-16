#!/usr/bin/env bash
#Este script analiz el TLS/HTTPS de un dominio para verificar qeu
# la conexión segura se establezca correctamente

set -euo pipefail
trap "echo 'Proceso interrumpido por el usuario.'; exit 1" SIGINT SIGTERM

if [ $# -eq 0 ]; then
    echo "Error: No se proporcionó un dominio." >&2
    echo "Uso: $0 <dominio.com>" >&2
    exit 1
fi

readonly DOMAIN="$1"
echo "Analizando HTTPS/TLS para ${DOMAIN} usando openssl"
echo "[Paso 1/2] Verificando DNS..."

if src/check_dns.sh "$DOMAIN" > /dev/null; then
    echo "DNS OK. El dominio '${DOMAIN}' es resoluble."
    echo "[Paso 2/2] Realizando handshake TLS..."
    # Obtener información TLS
    tls_info=$(echo "Q" | openssl s_client -connect "${DOMAIN}:443" -servername "${DOMAIN}" 2>&1)

    #Validamos si la conexión fue exitosa
    if echo "${tls_info}" | grep -q "Verify return code: 0 (ok)"; then
        echo "Handshake TLS exitoso para ${DOMAIN}."

        # Extraemos información específica de protocol y cipher
        summary_line=$(echo "${tls_info}" | grep '^New,')
        protocol=$(echo "${summary_line}" | awk -F, '{print $2}' | xargs) 
        cipher=$(echo "${summary_line}" | awk -F'Cipher is ' '{print $2}' | xargs)


        echo "Protocolo: ${protocol}"
        echo "Cifrado: ${cipher}"
        exit 0
    else
        echo "ALERTA: Falló el handshake TLS para ${DOMAIN}."
        echo " - Puede deberse a un certificado expirado, inválido o un problema de red." >&2
        echo -e "\n --Salida completa de OpenSSL --- \n${tls_info}\n-----"
        exit 1      
    fi 
else
    echo "Fallo de DNS. No se puede continuar con el análisis TLS." >&2
    exit 1
fi 