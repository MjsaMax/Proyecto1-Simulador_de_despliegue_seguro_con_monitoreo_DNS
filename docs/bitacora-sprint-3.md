# Bitácora de Trabajo - Sprint [N]

**Fecha:** [DD de Mes de YYYY]

## Sección: Estudiante [Serrano Max, Davila Aaron, Poma Walter] ([Área/Responsabilidad])

### 1. Objetivo del Sprint
- El objetivo principal del sprint es generar software reproducible mediante el empaquetamiento del proyecto en un archivo tar.gz.

### 2. Módulos / Scripts Trabajados
- Las partes trabajados estan commiteadas respectivamente, un resumen rápido es que se centro en crear logs y el archivo repoducible proyecto01.tar.gz

### 3. Comandos Ejecutados
# Listar todos los comandos relevantes ejecutados en este sprint
make dist
make test
make instalar-dependencias
make dns-check DOMAIN=example.com 
make http-check DOMAIN=example.com
make https-check DOMAIN=example.com

### 4. Salida de Logs / Resultados Relevantes

#### 4.1 dns-check
Ejemplo de salida:
Ejecutando DNS check para example.com con servidor 8.8.8.8
[OK] El dominio 'example.com' es resoluble.
IP obtenida: 93.184.216.34

#### 4.2 http-check
Ejemplo de salida:
Verificando HTTP para example.com
[Paso 1/1] Chequeo del código de estado HTTP...
Código obtenido: 200 (OK)

#### 4.3 https-check
Ejemplo de salida:
Analizando HTTPS/TLS para example.com
[Paso 1/2] Verificando DNS...
DNS OK. IP: 93.184.216.34
[Paso 2/2] Realizando handshake TLS...
Handshake exitoso.
Protocolo: TLSv1.3
Cifrado: TLS_AES_256_GCM_SHA384

Cada target genera su propio log: dns_check.log, http_check.log, https_check.log, dist.log.

### 5. Errores Presentados
- Algunos logs no se generaban correctamente por permisos de escritura en `dist/logs`, se solucionó creando la carpeta previamente.

### 6. Decisiones Tomadas
1. Se centralizaron los logs en `dist/logs` para facilitar la trazabilidad.
2. Se implementó un empaquetado reproducible excluyendo carpetas temporales (`out/` y `dist/` interna) para evitar inconsistencias.

### 7. Empaquetado Reproducible
- Archivo generado: `dist/proyecto01-1.0.tar.gz`

### 8. Comentarios Adicionales
- El proyecto, así los videos apartir de este sprint se encuentran disponibles en docs/ el enlace es de onedrive/
