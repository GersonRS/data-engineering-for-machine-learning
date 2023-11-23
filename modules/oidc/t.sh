#!/bin/bash

function error_exit() {
  echo "$1" 1>&2
  exit 1
}

function check_deps() {
  test -f $(which jq) || error_exit "jq command not detected in path, please install it"
}

function parse_input() {
  # jq reads from stdin so we don't have to set up any inputs, but let's validate the outputs
  eval "$(jq -r '@sh "export CERT=\(.cert)"')"
  if [[ -z "${CERT}" ]]; then export CERT=none; fi
}

function produce_output() {
  fingerprint=$(echo -e "$CERT" | openssl x509 -noout -fingerprint -sha1)
  jq -n --arg fingerprint "$fingerprint" '{"fingerprint":$fingerprint}'
}

check_deps
parse_input
produce_output
