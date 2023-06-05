#!/bin/bash

users=(centralized-log-fluentd1 centralized-log-fluentd2)

mkdir -p cert

echo 'generate cert for fluentd'

for i in "${users[@]}"; do
    echo ${i}

    cd cert

    if [ ! -f $i-kafka.crt ]; then
        # закрытый ключ
        openssl genrsa -out $i-kafka.key 4096

        # запрос на сертификацию (CSR)
        openssl req -sha512 -new \
            -subj "/C=RU/ST=Stavropol region/L=Stavropol/O=Some ORG/OU=Some dep/CN=$i" \
            -key $i-kafka.key \
            -out $i-kafka.csr

        # расширение v3 для сертификата
        cat >v3-$i-kafka.ext <<-EOF
authorityKeyIdentifier=keyid,issuer
basicConstraints=CA:FALSE
keyUsage = digitalSignature, nonRepudiation, keyEncipherment, dataEncipherment
extendedKeyUsage = serverAuth,clientAuth
subjectAltName = @alt_names
[alt_names]
DNS.1=$i
DNS.2=$i.centralized-log-main_app-network
DNS.3=localhost
IP.4=127.0.0.1
EOF

        #генерация сертификата
        openssl x509 -req -sha512 -days 999999 \
            -extfile v3-$i-kafka.ext \
            -CA ../../CAZooKeeperAndBetweenKafka/ca.crt -CAkey ../../CAZooKeeperAndBetweenKafka/ca.key -CAcreateserial \
            -in $i-kafka.csr \
            -out $i-kafka.crt

        chown 1005:1005 $i-kafka*

    else

        echo "$i-kafka.crt is exists"

    fi

    if [ ! -f $i-elasticsearch.crt ]; then
        # закрытый ключ
        openssl genrsa -out $i-elasticsearch.key 4096

        # запрос на сертификацию (CSR)
        openssl req -sha512 -new \
            -subj "/C=RU/ST=Stavropol region/L=Stavropol/O=Some ORG/OU=Some dep/CN=$i" \
            -key $i-elasticsearch.key \
            -out $i-elasticsearch.csr

        # расширение v3 для сертификата
        cat >v3-$i-elasticsearch.ext <<-EOF
authorityKeyIdentifier=keyid,issuer
basicConstraints=CA:FALSE
keyUsage = digitalSignature, nonRepudiation, keyEncipherment, dataEncipherment
extendedKeyUsage = serverAuth,clientAuth
subjectAltName = @alt_names
[alt_names]
DNS.1=$i
DNS.2=$i.centralized-log-main_app-network
DNS.3=localhost
IP.4=127.0.0.1
EOF

        #генерация сертификата
        openssl x509 -req -sha512 -days 999999 \
            -extfile v3-$i-elasticsearch.ext \
            -CA ../../CAElasticsearch/ca.crt -CAkey ../../CAElasticsearch/ca.key -CAcreateserial \
            -in $i-elasticsearch.csr \
            -out $i-elasticsearch.crt

        chown 1005:1005 $i-elasticsearch*

    else

        echo "$i-elasticsearch.crt is exists"

    fi

    cd ../

done
