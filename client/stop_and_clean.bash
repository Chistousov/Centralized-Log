#!/bin/bash

docker compose down -v || true
rm -rf .env || true

rm -rf kafka-client/ssl_sasl/*.key || true
rm -rf kafka-client/ssl_sasl/*.crt || true
rm -rf kafka-client/ssl_sasl/*.keytab || true
rm -rf kafka-client/ssl_sasl/*.csr || true
rm -rf kafka-client/ssl_sasl/v3-*.ext || true
rm -rf kafka-client/ssl_sasl/ca.crt || true
rm -rf kafka-client/ssl_sasl/krb5.conf || true