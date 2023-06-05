#!/bin/bash

users=(zookeeper1 zookeeper2 zookeeper3)

mkdir -p cert
mkdir -p keystore

echo 'generate cert for zookeeper'

source ../.env

for i in "${users[@]}"; do

    echo ${i}

    cd cert

    if [ ! -f centralized-log-kafka-$i.crt ]; then

        # закрытый ключ
        openssl genrsa -out centralized-log-kafka-$i.key 4096

        # запрос на сертификацию (CSR)
        openssl req -sha512 -new \
            -subj "/C=RU/ST=Stavropol region/L=Stavropol/O=Some ORG/OU=Some dep/CN=centralized-log-kafka-$i" \
            -key centralized-log-kafka-$i.key \
            -out centralized-log-kafka-$i.csr

        # расширение v3 для сертификата
        cat >v3-$i.ext <<-EOF
authorityKeyIdentifier=keyid,issuer
basicConstraints=CA:FALSE
keyUsage = digitalSignature, nonRepudiation, keyEncipherment, dataEncipherment
extendedKeyUsage = serverAuth,clientAuth
subjectAltName = @alt_names
[alt_names]
DNS.1=centralized-log-kafka-$i
DNS.2=centralized-log-kafka-$i.centralized-log_app-network
DNS.3=localhost
IP.4=127.0.0.1
EOF

        # генерация сертификата
        openssl x509 -req -sha512 -days 999999 \
            -extfile v3-$i.ext \
            -CA ../../CAZooKeeperAndBetweenKafka/ca.crt -CAkey ../../CAZooKeeperAndBetweenKafka/ca.key -CAcreateserial \
            -in centralized-log-kafka-$i.csr \
            -out centralized-log-kafka-$i.crt

    else

        echo "centralized-log-kafka-${i}.crt is exists"

    fi

    cd ../

    # Генерация keystore для ZooKeeper

    cd keystore

    if [ ! -f centralized-log-kafka-$i.truststore.p12 ]; then

        # контейнер с закрытым ключом открытым сертификатом и доп. сертификатами
        openssl pkcs12 \
            -export \
            -name serverCert \
            -in ../cert/centralized-log-kafka-$i.crt \
            -inkey ../cert/centralized-log-kafka-$i.key \
            -certfile ../../CAZooKeeperAndBetweenKafka/ca.crt \
            -CAfile ../../CAZooKeeperAndBetweenKafka/ca.crt \
            -out centralized-log-kafka-$i.keystore.p12 \
            -passout pass:${ZOOKEEPER_KEYSTORE_PASSWORD}

        #контейнер для доверенных сертификатов
        keytool -importcert \
            -keystore centralized-log-kafka-$i.truststore.p12 \
            -storepass ${ZOOKEEPER_TRUSTSTORE_PASSWORD} \
            -alias serverCATrust \
            -file ../../CAZooKeeperAndBetweenKafka/ca.crt \
            -noprompt

        chown 1005:1005 centralized-log-kafka-$i*    

    else

        echo "centralized-log-kafka-${i}.truststore.p12 is exists"

    fi

    cd ../

done

echo 'Done'
