#!/bin/bash

users=(centralized-log-elasticsearch1 centralized-log-elasticsearch2 centralized-log-elasticsearch3 centralized-log-elasticsearch4)

mkdir -p cert

echo 'generate cert for elasticsearch'

for i in "${users[@]}"; do
    echo ${i}

    cd cert

    if [ ! -f $i.crt ]; then
        # private key
        # закрытый ключ
        openssl genrsa -out $i.key 4096

        # Request for Certification (CSR)
        # запрос на сертификацию (CSR)
        openssl req -sha512 -new \
            -subj "/C=RU/ST=Stavropol region/L=Stavropol/O=Some ORG/OU=Some dep/CN=$i" \
            -key $i.key \
            -out $i.csr

        # v3 extension for the certificate
        # расширение v3 для сертификата
        cat >v3-$i.ext <<-EOF
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
        # certificate generation
        # генерация сертификата
        openssl x509 -req -sha512 -days 999999 \
            -extfile v3-$i.ext \
            -CA ../../CAElasticsearch/ca.crt -CAkey ../../CAElasticsearch/ca.key -CAcreateserial \
            -in $i.csr \
            -out $i.crt

        chown 1005:1005 $i*

    else
        echo "$i.crt is exists"
    fi
    cd ../
done
echo 'Done'
