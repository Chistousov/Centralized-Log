#!/bin/bash

users=(kafka1 kafka2 kafka3)

mkdir -p cert
mkdir -p keystore

echo 'generate cert for kafka'

source ../.env

for i in "${users[@]}"; do
    echo ${i}

    cd cert

    if [ ! -f centralized-log-$i-internal.crt ]; then
        # private key
        # закрытый ключ
        openssl genrsa -out centralized-log-$i-internal.key 4096

        # Request for Certification (CSR)
        # запрос на сертификацию (CSR)
        openssl req -sha512 -new \
            -subj "/C=RU/ST=Stavropol region/L=Stavropol/O=Some ORG/OU=Some dep/CN=centralized-log-$i" \
            -key centralized-log-$i-internal.key \
            -out centralized-log-$i-internal.csr

        # v3 extension for the certificate
        # расширение v3 для сертификата
        cat >v3-$i-internal.ext <<-EOF
authorityKeyIdentifier=keyid,issuer
basicConstraints=CA:FALSE
keyUsage = digitalSignature, nonRepudiation, keyEncipherment, dataEncipherment
extendedKeyUsage = serverAuth,clientAuth
subjectAltName = @alt_names
[alt_names]
DNS.1=centralized-log-$i
DNS.2=localhost
IP.3=127.0.0.1
EOF
        # certificate generation
        # генерация сертификата
        openssl x509 -req -sha512 -days 999999 \
            -extfile v3-$i-internal.ext \
            -CA ../../CAZooKeeperAndBetweenKafka/ca.crt -CAkey ../../CAZooKeeperAndBetweenKafka/ca.key -CAcreateserial \
            -in centralized-log-$i-internal.csr \
            -out centralized-log-$i-internal.crt

    else
        echo "centralized-log-${i}-internal.crt is exists"
    fi
    cd ../

    # keystore generation
    # генерация keystore
    cd keystore

    if [ ! -f centralized-log-$i-internal.truststore.p12 ]; then

        # container with private key, public certificate and additional certificates
        # контейнер с закрытым ключом открытым сертификатом и доп. сертификатами
        openssl pkcs12 \
            -export \
            -name serverCert \
            -in ../cert/centralized-log-$i-internal.crt \
            -inkey ../cert/centralized-log-$i-internal.key \
            -certfile ../../CAZooKeeperAndBetweenKafka/ca.crt \
            -CAfile ../../CAZooKeeperAndBetweenKafka/ca.crt \
            -out centralized-log-$i-internal.keystore.p12 \
            -passout pass:${KAFKA_KEYSTORE_PASSWORD}

        # container for trusted certificates
        # контейнер для доверенных сертификатов
        keytool -importcert \
            -keystore centralized-log-$i-internal.truststore.p12 \
            -storepass ${KAFKA_TRUSTSTORE_PASSWORD} \
            -alias serverCATrust \
            -file ../../CAZooKeeperAndBetweenKafka/ca.crt \
            -noprompt
        
        chown 1005:1005 centralized-log-$i*

    else
        echo "centralized-log-${i}-internal.truststore.p12 is exists"
    fi
    cd ../
done

echo 'kafka.logs.com'

cd cert

if [ ! -f kafka.logs.com.crt ]; then
    # private key
    # закрытый ключ
    openssl genrsa -out kafka.logs.com.key 4096

    # запрос на сертификацию (CSR)
    openssl req -sha512 -new \
        -subj "/C=RU/ST=Stavropol region/L=Stavropol/O=Some ORG/OU=Some dep/CN=kafka.logs.com" \
        -key kafka.logs.com.key \
        -out kafka.logs.com.csr

    # расширение v3 для сертификата
    cat >v3-$i-external.ext <<-EOF
authorityKeyIdentifier=keyid,issuer
basicConstraints=CA:FALSE
keyUsage = digitalSignature, nonRepudiation, keyEncipherment, dataEncipherment
extendedKeyUsage = serverAuth,clientAuth
subjectAltName = @alt_names
[alt_names]
DNS.1=kafka.logs.com
EOF

    #генерация сертификата
    openssl x509 -req -sha512 -days 999999 \
        -extfile v3-$i-external.ext \
        -CA ../../CAForClientKafka/ca.crt -CAkey ../../CAForClientKafka/ca.key -CAcreateserial \
        -in kafka.logs.com.csr \
        -out kafka.logs.com.crt

else

    echo "kafka.logs.com.crt is exists"

fi

cd ../

# Генерация keystore

cd keystore

if [ ! -f kafka.logs.com.truststore.p12 ]; then

    # контейнер с закрытым ключом открытым сертификатом и доп. сертификатами
    openssl pkcs12 \
        -export \
        -name serverCert \
        -in ../cert/kafka.logs.com.crt \
        -inkey ../cert/kafka.logs.com.key \
        -certfile ../../CAForClientKafka/ca.crt \
        -CAfile ../../CAForClientKafka/ca.crt \
        -out kafka.logs.com.keystore.p12 \
        -passout pass:${KAFKA_KEYSTORE_PASSWORD}

    #контейнер для доверенных сертификатов
    keytool -importcert \
        -keystore kafka.logs.com.truststore.p12 \
        -storepass ${KAFKA_TRUSTSTORE_PASSWORD} \
        -alias serverCATrust \
        -file ../../CAForClientKafka/ca.crt \
        -noprompt

    chown 1005:1005 kafka.logs.com*

else

    echo "kafka.logs.com.truststore.p12 is exists"

fi

cd ../

echo 'Done'
