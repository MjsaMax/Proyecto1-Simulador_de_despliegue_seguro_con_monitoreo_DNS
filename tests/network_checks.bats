#!/usr/bin/env bats

load '../libs/bats-support/load'
load '../libs/bats-assert/load'


TARGET_HOST_VALID="google.com"
TARGET_HOST_INVALID="noexistedominiodeprueebaproyecto1.com"
TARGET_HOST_HTTPS="github.com"


@test "check_http() debe ser exitoso para un sitio válido" {

  run ./src/http_check.sh "$TARGET_HOST_VALID"
  assert_success
  assert_output --partial "El chequeo pasó."
}

@test "check_http() debe fallar para un dominio inválido" {
  run ./src/http_check.sh "$TARGET_HOST_INVALID"
  
  assert_failure
}

@test "analyze_https() debe encontrar información de TLS para un sitio seguro" {
  run ./src/https_check.sh "$TARGET_HOST_HTTPS"
  
  assert_success
  assert_output --partial "Información de TLS encontrada"
}

@test "dns_check() debe resolver un dominio válido" {
    export DNS_SERVER="8.8.8.8"
    run ./src/check_dns.sh "$TARGET_HOST_VALID"
    assert_success
    assert_output --partial "La IP de '${TARGET_HOST_VALID}'"
}

@test "dns_check() debe fallar para un dominio inválido" {
    export DNS_SERVER="8.8.8.8"
    run ./src/check_dns.sh "$TARGET_HOST_INVALID"
    assert_failure
    assert_output --partial "No se pudo obtener la dirección IP final"
}
