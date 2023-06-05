#!/bin/bash

if [ ! -f .env ]; then

    # ------------------!!!EDIT!!!----------------

    LDAP_DOMAIN="example.com"
    CLIENT_ID="someserver"
    IP_KERBEROS_AND_KAFKA="172.20.11.2"

    # ------------------------------------------

    LDAP_DOMAIN_UPPER=${LDAP_DOMAIN^^}
    HOSTNAME=$(hostname)

    echo LDAP_DOMAIN=${LDAP_DOMAIN} >>.env
    echo CLIENT_ID=${CLIENT_ID} >>.env
    echo HOSTNAME=${HOSTNAME} >>.env
    echo LDAP_DOMAIN_UPPER=${LDAP_DOMAIN_UPPER} >>.env
    echo IP_KERBEROS_AND_KAFKA=${IP_KERBEROS_AND_KAFKA} >>.env

    cd kafka-client/ssl_sasl && LDAP_DOMAIN_UPPER=${LDAP_DOMAIN_UPPER} envsubst < krb5.conf.templ > krb5.conf && cd ../../

    docker compose up -d || true

else

    docker compose down || true
    docker compose up -d || true

fi
