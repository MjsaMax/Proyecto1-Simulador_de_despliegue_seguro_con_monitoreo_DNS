# Makefile inicial

# Ayuda / Debug
.PHONY: help
help: ## Mostrar los targets disponibles
	@echo "Make targets:"
	@grep -E '^[a-zA-Z0-9_\-]+:.*?##' $(MAKEFILE_LIST) | \
		awk 'BEGIN{FS=":.*?##"}{printf "  \033[36m%-22s\033[0m %s\n", $$1, $$2}'


# Variables
DNS_SCRIPT = src/check_dns.sh
HTTP_SCRIPT = src/http_check.sh
TEST = tests/


# Target por defecto
.PHONY: all
all: test

.PHONY: dns-check 
dns-check: ## Ejecuta el script de DNS
	@DNS_SERVER=$(DNS_SERVER) bash $(DNS_SCRIPT) $(DOMAIN)

# HTTP check
.PHONY: http-check
http-check: ## Ejecuta chequeo HTTP
	@bash $(HTTP_SCRIPT) http $(DOMAIN)

# HTTPS/TLS check
.PHONY: https-check
https-check: ## Ejecuta chequeo HTTPS/TLS
	@bash $(HTTP_SCRIPT) https $(DOMAIN)


.PHONY: test 
test: ## Corre pruebas con Bats
	@bats $(TEST)
