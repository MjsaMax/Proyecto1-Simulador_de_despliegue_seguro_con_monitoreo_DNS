#!/usr/bin/env bats

load '../libs/bats-support/load'
load '../libs/bats-assert/load'

source src/main.sh

TARGET_HOST_VALID="google.com"
TARGET_HOST_INVALID="noexistedominiodeprueebaproyecto1.com"
TARGET_HOST_HTTPS="github.com"


@test "check_http() debe ser exitoso para un sitio válido" {

    run check_http "$TARGET_HOST_VALID"
    assert_success
    assert_output --partial "El chequeo pasó."
}

@test "check_http() debe fallar para un dominio inválido" {
  run check_http "$TARGET_HOST_INVALID"
  
  assert_failure
}

@test "analyze_https() debe encontrar información de TLS para un sitio seguro" {
  run analyze_https "$TARGET_HOST_HTTPS"
  
  assert_success
  assert_output --partial "Información de TLS encontrada"
}