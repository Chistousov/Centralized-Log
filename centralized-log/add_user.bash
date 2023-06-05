#!/bin/bash


if [[ -n $1 ]]; then
    
    source .env
    
    mkdir -p clients/$1
    
    cd clients/$1
    
    openssl genrsa -out $1.key 4096
    
    # Request for Certification (CSR)
    # запрос на сертификацию (CSR)
    openssl req -sha512 -new \
    -subj "/C=RU/ST=Stavropol region/L=Stavropol/O=Some ORG/OU=Some dep/CN=$1" \
    -key $1.key \
    -out $1.csr
    
    # v3 extension for the certificate
    # расширение v3 для сертификата
        cat >v3-$1.ext <<-EOF
authorityKeyIdentifier=keyid,issuer
basicConstraints=CA:FALSE
keyUsage = digitalSignature, nonRepudiation, keyEncipherment, dataEncipherment
extendedKeyUsage = clientAuth
subjectAltName = @alt_names
[alt_names]
DNS.1=$1
EOF
    # certificate generation
    # генерация сертификата
    openssl x509 -req -sha512 -days 999999 \
    -extfile v3-$1.ext \
    -CA ../../CAForClientKafka/ca.crt -CAkey ../../CAForClientKafka/ca.key -CAcreateserial \
    -in $1.csr \
    -out $1.crt
    
    user="$1@${LDAP_DOMAIN_UPPER}"
    
    echo "Create user KDC ${user}"
    docker exec -it centralized-log-kafka-kdc kadmin.local -q "addprinc -randkey ${user}"
    echo "Done ${user}"

    echo "Create keytab ${1}.keytab"
    docker exec -it centralized-log-kafka-kdc kadmin.local -q "ktadd -k /${1}.keytab ${user}"
    echo "Done ${1}.keytab"
    
    echo "Copy local ${1}"
    docker cp centralized-log-kafka-kdc:/${1}.keytab ${1}.keytab
    echo "Done ${1}"

    echo '--------------keytab--------------'
    realpath ${1}.keytab
    echo '----------------------------------'
    
else
    
    echo "Invalid args. Example: bash add_user.bash testuser"
fi