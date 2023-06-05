#!/bin/sh

echo "generate CA Elasticsearch"

if [ ! -f ca.crt ];
then
    # generating a key for a CA
    # генерация ключа для CA
    openssl genrsa -out ca.key 4096
    
    # generating a certificate for a CA
    # формирование сертификата для CA
    openssl req -x509 -new -nodes -sha512 -days 999999 \
    -subj "/C=RU/ST=Stavropol region/L=Stavropol/O=Some ORG/OU=Some dep/CN=some cn Elasticsearch" \
    -key ca.key \
    -out ca.crt
else
    echo "CA Elasticsearch is exists"
fi
