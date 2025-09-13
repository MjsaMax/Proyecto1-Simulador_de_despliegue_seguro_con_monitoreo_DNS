# Makefile inicial

# Ayuda / Debug
.PHONY: help
help: ## Mostrar los targets disponibles
	@echo "Make targets:"
	@grep -E '^[a-zA-Z0-9_\-]+:.*?##' $(MAKEFILE_LIST) | \
		awk 'BEGIN{FS=":.*?##"}{printf "  \033[36m%-22s\033[0m %s\n", $$1, $$2}'


# Variables
DNS_SCRIPT = src/check_dns.sh
HTTP_SCRIPT = src/main.sh
TEST = tests/network_checks.bats

# Target por defecto
.PHONY: all
all: test


.PHONY: dns-check 
dns-check: ## Ejecuta el script de DNS
	@bash $(DNS_SCRIPT)

.PHONY: http-check 
http-check: ## Ejecuta el script de HTTP
	@bash $(HTTP_SCRIPT)


.PHONY: test 
test: ## Corre pruebas con Bats
	@bats $(TEST)
