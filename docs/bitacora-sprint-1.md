# Bitácora de Trabajo - Sprint 1

**Fecha:** 12 de Septiembre de 2025
**Integrante:** Aarón Davila 

---

### **Tarea: Creación de Script para Verificación de DNS**

#### **1. Creación de la Estructura y el Script Inicial**

Se creó la estructura de directorios requerida (`src`, `docs`, `out`, etc.) según las especificaciones del proyecto.

Posteriormente, se desarrolló el script `src/check_dns.sh` con la siguiente funcionalidad base:
* Uso de `set -euo pipefail` para un manejo de errores robusto.
* Validación de argumentos para asegurar que se pase un dominio.
* Uso de la variable de entorno `DNS_SERVER` para parametrizar el servidor DNS a consultar.

**Comando de prueba:**
```bash
DNS_SERVER="8.8.8.8" ./src/check_dns.sh google.com
