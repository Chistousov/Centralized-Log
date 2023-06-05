#!/bin/bash

echo "generate centralized-log-kafka-gui"

mkdir -p cert
mkdir -p keystore

source ../.env

cd cert

if [ ! -f centralized-log-kafka-gui.crt ]; then

    # закрытый ключ
    openssl genrsa -out centralized-log-kafka-gui.key 4096

    # запрос на сертификацию (CSR)
    openssl req -sha512 -new \
        -subj "/C=RU/ST=Stavropol region/L=Stavropol/O=Some ORG/OU=Some dep/CN=centralized-log-kafka-gui" \
        -key centralized-log-kafka-gui.key \
        -out centralized-log-kafka-gui.csr

    # расширение v3 для сертификата
    cat >v3-centralized-log-kafka-gui.ext <<-EOF
authorityKeyIdentifier=keyid,issuer
basicConstraints=CA:FALSE
keyUsage = digitalSignature, nonRepudiation, keyEncipherment, dataEncipherment
extendedKeyUsage = serverAuth,clientAuth
subjectAltName = @alt_names
[alt_names]
DNS.1=centralized-log-kafka-gui
DNS.2=localhost
IP.3=127.0.0.1
EOF

    # генерация сертификата
    openssl x509 -req -sha512 -days 999999 \
        -extfile v3-centralized-log-kafka-gui.ext \
        -CA ../../CAZooKeeperAndBetweenKafka/ca.crt -CAkey ../../CAZooKeeperAndBetweenKafka/ca.key -CAcreateserial \
        -in centralized-log-kafka-gui.csr \
        -out centralized-log-kafka-gui.crt

else
    echo "centralized-log-kafka-gui.crt is exists"
fi

cd ../

cd keystore

if [ ! -f centralized-log-kafka-gui.truststore.p12 ]; then

    # контейнер с закрытым ключом открытым сертификатом и доп. сертификатами
    openssl pkcs12 \
        -export \
        -name serverCert \
        -in ../cert/centralized-log-kafka-gui.crt \
        -inkey ../cert/centralized-log-kafka-gui.key \
        -certfile ../../CAZooKeeperAndBetweenKafka/ca.crt \
        -CAfile ../../CAZooKeeperAndBetweenKafka/ca.crt \
        -out centralized-log-kafka-gui.keystore.p12 \
        -passout pass:${KAFKA_GUI_KEYSTORE_PASSWORD}

    #контейнер для доверенных сертификатов
    keytool -importcert \
        -keystore centralized-log-kafka-gui.truststore.p12 \
        -storepass ${KAFKA_GUI_TRUSTSTORE_PASSWORD} \
        -alias serverCATrust \
        -file ../../CAZooKeeperAndBetweenKafka/ca.crt \
        -noprompt

    chown 1005:1005 centralized-log-kafka-gui*

else
    echo "centralized-log-kafka-gui.truststore.p12 is exists"
fi

cd ../
