# Bitácora de Trabajo - Sprint 1

**Fecha:** 16 de Septiembre de 2025


---

## Sección: Estudiante 2 - Walter (HTTP/TLS y Señales)

Este sprint se centró en robustecer los scripts de chequeo, implementar un análisis TLS profundo y asegurar el manejo de errores y señales.

### 1. Desarrollo del Script http_check.sh

Se creó un script para verificar el código de estado HTTP de un dominio, dependiendo de una validación DNS previa.

* **Comando Ejecutado:**
    ```bash
    ./src/http_check.sh google.com
    ```

* **Salida Relevante:**
    ```text
    Verificando HTTP para google.com
    [Paso 1/2] Verificando DNS...
    DNS OK. La IP de 'google.com' es: 8.8.8.8
    [Paso 2/2] Verificando código de estado HTTP...
    Chequeo HTTP exitoso. Código obtenido: 200 (OK).
    ```
    *Comentario: La salida confirma que la dependencia de DNS funciona y que la captura del código de estado con curl es exitosa.*

* **Decisiones:**
    1.  Se utilizó `curl -sL -o /dev/null -w "%{http_code}"` para obtener únicamente el código de estado, ignorando el cuerpo de la respuesta para mayor eficiencia.
    2.  Se implementó una dependencia del script `check_dns.sh`. El chequeo HTTP no se ejecuta si la validación DNS falla primero.

### 2. Desarrollo y Depuración de https_check.sh

El objetivo era analizar el handshake TLS usando openssl. Durante el desarrollo, se encontró un problema crítico donde dominios válidos como google.com fallaban la verificación.

* **Problema Inicial:** El script reportaba un fallo de handshake para google.com.

* **Comando de Depuración:**
    Se modificó temporalmente el script para imprimir la salida completa de openssl y diagnosticar el problema.
    ```bash
    # ...
    else
        echo "ALERTA: Falló el handshake TLS para ${DOMAIN}." >&2
        # Se añadió esta línea para ver la salida completa:
        echo -e "\n --Salida completa de OpenSSL --- \n${tls_info}\n-----"
        exit 1
    fi
    ```

* **Salida de Depuración:**
    ```text
    ALERTA: Falló el handshake TLS para google.com.
    
    --- Salida Completa de OpenSSL ---
    ...
    New, TLSv1.3, Cipher is TLS_AES_256_GCM_SHA384
    ...
    Verify return code: 0 (ok)
    ---
    ```
    *Comentario: La depuración de mi archivo https_check.sh reveló dos cosas clave: 1) La línea de éxito era `Verify return code: 0 (ok)` (con 'V' mayúscula). 2) La información del protocolo y cifrado estaba en una línea que comenzaba con `New,...`.*

* **Decisiones Post-Depuración:**
    1.  **Corregir el grep:** Se cambió la búsqueda de "verify..." a "Verify..." para que coincidiera con la salida real.
    2.  **Adaptar el Parsing:** Se descartó el método awk que buscaba "Protocol :" y "Cipher :". En su lugar, se implementó una nueva lógica para parsear la línea que empieza con "New," y así extraer los datos correctamente. Esto hace el script resiliente a diferentes formatos de salida de openssl.

### 3. Pruebas de Casos de Fallo
Se validó que el script maneja correctamente los escenarios de error esperados.

* **Comando para Fallo de TLS:**
    ```bash
    ./src/https_check.sh expired.badssl.com
    ```

* **Salida:**
    ```text
    Analizando HTTPS/TLS para expired.badssl.com usando openssl
    [Paso 1/2] Verificando DNS...
    DNS OK. El dominio 'expired.badssl.com' es resoluble.
    [Paso 2/2] Realizando handshake TLS...
    ALERTA: Falló el handshake TLS para expired.badssl.com.
    - Puede deberse a un certificado expirado, inválido o un problema de red.
    ```
    *Comentario: El script detecta correctamente un certificado inválido.*

* **Comando para Fallo de DNS:**
    ```bash
    ./src/https_check.sh dominio-inventado123.com
    ```

* **Salida:**
    ```text
    Analizando HTTPS/TLS para dominio-inventado123.com usando openssl
    [Paso 1/2] Verificando DNS...
    Error: Dominio no encontrado (simulado).
    Fallo de DNS. No se puede continuar con el análisis TLS.

### Implementación de Trap y Set

Se aseguró que todos los scripts fueran robustos ante errores y interrupciones del usuario, cumpliendo con los requisitos del sprint.

* **Comando de Prueba (Simulando Interrupción):**
    Se ejecutó un script con una pausa (Ctrl + C).
    ```bash
    $ ./src/https_check.sh google.com
    Analizando HTTPS/TLS para google.com usando openssl
    [Paso 1/2] Verificando DNS...
    DNS OK. El dominio 'google.com' es resoluble.
    [Paso 2/2] Realizando handshake TLS...
    ^CProceso interrumpido por el usuario.
    ```
* **Salida:**
    El script no terminó abruptamente, sino que mostró el mensaje definido en la cláusula trap.

* **Decisiones:**
    1.  Se incluyó "set -euo pipefail" al inicio de todos los scripts para garantizar que fallen de manera inmediata y predecible ante un error o una variable no definida.
    2.  Se implementó "trap "..." SIGINT SIGTERM" para capturar las señales de interrupción y terminación, permitiendo una limpieza o un mensaje de salida adecuado.

### 5. Análisis de Trazas y Sockets de Red

Para un diagnóstico más profundo, se utilizaron herramientas de análisis de red para inspeccionar la comunicación a bajo nivel.

* **Comando para Trazas HTTP:**
    ```bash
    # Se usa -v para ver el intercambio de encabezados.
    curl -v http://www.google.com -o /dev/null
    ```

* **Salida (Recortada):**
    ```text
    > GET / HTTP/1.1
    > Host: www.google.com
    > User-Agent: curl/8.5.0
    > Accept: */*
    < HTTP/1.1 200 OK
    < Date: Wed, 17 Sep 2025 00:16:39 GMT
    < Expires: -1
    < Cache-Control: private, max-age=0
    ```
    *Comentario: La traza permite observar la petición exacta que se envía (">") y la respuesta del servidor ("<"), incluyendo el código 200.*

* **Comando para Sockets:**
    ```bash
    # Se usó ss para verificar el estado de la conexión TCP durante la ejecución de curl.
    ss -tpn | grep 'curl'
    ```
* **Decisión:**
    Se decidió incluir el análisis con curl -v y ss como parte del diagnóstico para cumplir con el requisito de demostrar un entendimiento completo de la pila de red, desde la conexión del socket hasta los encabezados de la aplicación.

## Sección: Estudiante 3 - Serrano Max (MAKEFILE y bats)

Este sprint se enfocó en robustecer los tests Bats, mejorar la cobertura de HTTP/TLS y se aseguró la correcta instalación de dependencias.

- `http_check.sh` para códigos 200 y 404 y dominios inválidos 
  - Antes solo se verificaban dominios válidos con código 200; los 404 o dominios no resolubles quedaban sin evaluar.  
  - Para eso se modificaron los tests en Bats para capturar correctamente todos los códigos HTTP usando `curl -sL -o /dev/null -w "%{http_code}"` y se añadieron casos de 404 y dominios inválidos.

- Tests de TLS con `https_check.sh` (dominio con y sin certificado)  
  - Debido a que algunos dominios podían no tener TLS o tener certificados inválidos; antes no se verificaban estos escenarios.  
  - Lo que se hizo fue que se añadieron tests que ejecutan `https_check.sh` contra dominios con TLS válido y sin TLS, validando handshake exitoso o fallo de certificado.

- Actualización de targets de Bats y tests de DNS 
  - La estructura previa dificultaba identificar qué pruebas fallaban o pasaban y la cobertura de DNS estaba incompleta.  
  - Se reorganizaron los targets y se añadieron mensajes descriptivos, incluyendo casos de DNS válidos e inválidos, para mostrar claramente los resultados de cada escenario.

