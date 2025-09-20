# Makefile inicial

# Ayuda / Debug
.PHONY: help
help: ## Mostrar los targets disponibles
	@echo "Make targets:"
	@grep -E '^[a-zA-Z0-9_\-]+:.*?##' $(MAKEFILE_LIST) | \
		awk 'BEGIN{FS=":.*?##"}{printf "  \033[36m%-22s\033[0m %s\n", $$1, $$2}'

# Variables (scripts y test)
DNS_SCRIPT = src/check_dns.sh
HTTP_SCRIPT = src/http_check.sh
HTTPS_SCRIPT = src/https_check.sh
TEST = tests/

# Variables para distribución
PACKAGE = proyecto
VERSION = 1.0
DIST_DIR = dist
DIST_FILE = $(DIST_DIR)/$(PACKAGE)-$(VERSION).tar.gz
LOG_DIR = $(DIST_DIR)/logs

# Target por defecto
.PHONY: all
all: test

.PHONY: instalar-dependencias
instalar-dependencias: ## Instala dependencias (Bats + librerías)
	@echo "Instalando Bats globalmente con apt..."
	sudo apt install bats
	@echo "Clonando librerías para los tests"
	git clone https://github.com/bats-core/bats-core.git libs/bats-core || true
	git clone https://github.com/bats-core/bats-support.git libs/bats-support || true
	git clone https://github.com/bats-core/bats-assert.git libs/bats-assert || true

.PHONY: test 
test: ## Corre pruebas con Bats y genera log
	@mkdir -p $(LOG_DIR)
	@echo "Ejecutando tests..." | tee $(LOG_DIR)/tests.log
	@bats $(TEST) 2>&1 | tee -a $(LOG_DIR)/tests.log

.PHONY: dns-check
dns-check: ## Ejecuta el script de DNS y genera log
	@mkdir -p $(LOG_DIR)
	@echo "Chequeo DNS para $(DOMAIN)" | tee $(LOG_DIR)/dns_check.log
	@DNS_SERVER=$(DNS_SERVER) bash $(DNS_SCRIPT) $(DOMAIN) 2>&1 | tee -a $(LOG_DIR)/dns_check.log

# HTTP check
.PHONY: http-check
http-check: ## Ejecuta chequeo HTTP y genera log
	@mkdir -p $(LOG_DIR)
	@echo "Chequeo HTTP para $(DOMAIN)" | tee $(LOG_DIR)/http_check.log
	@bash $(HTTP_SCRIPT) $(DOMAIN) 2>&1 | tee -a $(LOG_DIR)/http_check.log

# HTTPS/TLS check
.PHONY: https-check
https-check: ## Ejecuta chequeo HTTPS/TLS y genera log
	@mkdir -p $(LOG_DIR)
	@echo "Chequeo HTTPS/TLS para $(DOMAIN)" | tee $(LOG_DIR)/https_check.log
	@bash $(HTTPS_SCRIPT) $(DOMAIN) 2>&1 | tee -a $(LOG_DIR)/https_check.log

# Empaquetado reproducible con log
.PHONY: dist
dist: ## Genera un paquete reproducible y registra log
	@mkdir -p $(DIST_DIR) $(LOG_DIR)
	@echo "Iniciando empaquetado: $(DIST_FILE)" | tee $(LOG_DIR)/dist.log
	@tar --exclude="$(DIST_DIR)" \
	     --exclude="out" \
	     -czf $(DIST_FILE) \
	     Makefile README.md docs libs src systemd tests 2>&1 | tee -a $(LOG_DIR)/dist.log
	@echo "Paquete creado en $(DIST_FILE)" | tee -a $(LOG_DIR)/dist.log

.PHONY: clean
clean: ## Limpieza segura de "out/" y "dist/"
	@echo "Eliminando directorios de salida..."
	@rm -rf out/ $(DIST_DIR) 
	@echo "Directorio 'out/' y '$(DIST_DIR)/' eliminados."

