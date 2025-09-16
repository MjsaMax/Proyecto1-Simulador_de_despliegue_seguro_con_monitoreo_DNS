#!/bin/bash
#
# ESTE ES UN SCRIPT SIMULADOR (MOCK) PARA DESARROLLO
#Lo reemplazaré cuando DNS suba su rama a develop

set -e # Salir si un comando falla

readonly DOMAIN_TO_CHECK="$1"

# Simulo el comportamientoq ue necesito
if [ "${DOMAIN_TO_CHECK}" == "google.com" ]; then
    # Caso de ÉXITO
    echo "8.8.8.8" # Imprimo una IP de prueba
    exit 0       # Sale con código 0 (éxito)
elif [ "${DOMAIN_TO_CHECK}" == "expired.badssl.com" ]; then
    # Otro caso de ÉXITO para mis pruebas de TLS
    echo "104.154.89.105"
    exit 0
else
    # Caso de FALLO 
    echo "Error: Dominio no encontrado (simulado)." >&2 # Mensaje de error
    exit 1                                            # Sale con código 1 (fallo)
fi