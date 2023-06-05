#!/bin/bash

docker compose down -v || true
rm -rf .env || true

rm -rf zookeeper/zookeeper_jaas.conf || true

rm -rf kafka/client_zookeeper_jaas.conf || true
rm -rf kafka/krb5.conf || true
rm -rf kafka/*.keytab || true

rm -rf kafka-gui/application.yml || true

rm -rf CAElasticsearch/ca.key || true
rm -rf CAElasticsearch/ca.crt || true
rm -rf CAElasticsearch/ca.srl || true

rm -rf CAForClientKafka/ca.key || true
rm -rf CAForClientKafka/ca.crt || true
rm -rf CAForClientKafka/ca.srl || true

rm -rf CAForNginx/ca.key || true
rm -rf CAForNginx/ca.crt || true
rm -rf CAForNginx/ca.srl || true

rm -rf CAZooKeeperAndBetweenKafka/ca.key || true
rm -rf CAZooKeeperAndBetweenKafka/ca.crt || true
rm -rf CAZooKeeperAndBetweenKafka/ca.srl || true

rm -rf elasticsearch/cert/ || true

rm -rf fluentd/cert/ || true

rm -rf grafana/cert/ || true

rm -rf kafka/cert/ || true
rm -rf kafka/keystore/ || true

rm -rf kafka-gui/cert/ || true
rm -rf kafka-gui/keystore/ || true

rm -rf zookeeper/cert/ || true
rm -rf zookeeper/keystore/ || true

rm -rf nginx/cert/ || true

rm -rf clients/ || true