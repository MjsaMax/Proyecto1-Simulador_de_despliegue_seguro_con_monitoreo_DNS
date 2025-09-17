#!/usr/bin/env bats

load '../libs/bats-support/load'
load '../libs/bats-assert/load'


TARGET_HOST_VALID="google.com"
TARGET_HOST_INVALID="noexistedominiodeprueebaproyecto1.com"
TARGET_HOST_HTTP_200="example.com"   # Devuelve 200
TARGET_HOST_HTTP_404="https://google.com/una-pagina-que-no-existe"  # Genera 404
TARGET_HOST_HTTPS_VALID="github.com"
TARGET_HOST_HTTPS_INVALID="expired.badssl.com" # Certificado inválido



@test "http_check() devuelve 200 para un dominio válido" {
    run ./src/http_check.sh "$TARGET_HOST_HTTP_200"
    assert_success
    assert_output --partial ": 200"
}

@test "http_check() devuelve 404 para dominio con error" {
    run ./src/http_check.sh "$TARGET_HOST_HTTP_404"
    assert_failure
    assert_output --partial "'404'."
}

@test "http_check() falla si DNS no resuelve" {
    run ./src/http_check.sh "$TARGET_HOST_INVALID"
    assert_failure
    assert_output --partial "Fallo de DNS"
}

@test "analyze_https() debe encontrar información de TLS para un sitio seguro" {
  run ./src/https_check.sh "$TARGET_HOST_HTTPS_VALID"
  assert_success
  assert_output --partial "Protocolo:"
  assert_output --partial "Cifrado:"
}

@test "analyze_https() no debe encontrar información de TLS para un sitio inseguro" {
  run ./src/https_check.sh "$TARGET_HOST_HTTPS_INVALID"
  assert_failure
  assert_output --partial "Falló el handshake TLS"
}

@test "dns_check() debe resolver un dominio válido" {
    export DNS_SERVER="8.8.8.8"
    run ./src/check_dns.sh "$TARGET_HOST_VALID"
    assert_success
    assert_output --partial "La IP de '$TARGET_HOST_VALID'"
}

@test "dns_check() debe fallar para un dominio inválido" {
    export DNS_SERVER="8.8.8.8"
    run ./src/check_dns.sh "$TARGET_HOST_INVALID"
    assert_failure
    assert_output --partial "No se pudo obtener la dirección IP"
}