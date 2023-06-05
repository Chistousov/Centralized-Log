#!/bin/bash

if [ ! -f .env ]; then

    # ------------------!!!EDIT!!!----------------

    # ldap and kerberos
    LDAP_ORGANISATION="MyOrg"
    LDAP_DOMAIN="example.com"
    LDAP_BASE_DN="dc=example,dc=com"
    LDAP_ADMIN_PASSWORD="cSeqdFA19FcP8bgWHa"
    LDAP_CONFIG_PASSWORD="PXh9mgkhpzcuXads3In0"
    LDAP_READONLY_USER_PASSWORD="xX62PnQaTojV8oLf"

    # elastic
    ELASTICSEARCH_CLUSTER_NAME="centralized-log-elastic-custom-cluster"
    ELASTIC_PASSWORD="kTBi6P5fsTD03CpJads"

    # grafana
    GRAFANA_OSS_SERVER_URL="https://logs.com/"
    GRAFANA_OSS_POSTGRES_PASSWORD="e1NbZODLlQasdz"

    # confluent
    REPOSITORY="confluentinc"
    CONFLUENT_DOCKER_TAG="7.2.1"
    SSL_CIPHER_SUITES="TLS_AES_256_GCM_SHA384,TLS_CHACHA20_POLY1305_SHA256,TLS_AES_128_GCM_SHA256,TLS_ECDHE_ECDSA_WITH_AES_256_GCM_SHA384,TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384,TLS_ECDHE_ECDSA_WITH_CHACHA20_POLY1305_SHA256,TLS_ECDHE_RSA_WITH_CHACHA20_POLY1305_SHA256,TLS_ECDHE_ECDSA_WITH_AES_128_GCM_SHA256,TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256"

    # zookeeper confluent
    ZOOKEEPER_KEYSTORE_PASSWORD="eLZfvW44fklZjpPwLasdr"
    ZOOKEEPER_SASL_PASSWORD="XjsfdhM71Jvnxv"
    ZOOKEEPER_TRUSTSTORE_PASSWORD="Jd4ipjwqaNgrjkYnztbf"

    # kafka confluent
    IP_KERBEROS_AND_KAFKA="172.20.13.77"
    KAFKA_KEYSTORE_PASSWORD="2U7387r29tcK6"
    KAFKA_TRUSTSTORE_PASSWORD="37Q5xOb8hoasj"
    # PLAIN SASL
    KAFKA_ADMIN_SASL_PASSWORD="KLrOTUbatqsd6d2hswv"

    # kafka gui
    KAFKA_GUI_KEYSTORE_PASSWORD="elaWgSO4y4MlYS1hgYr"
    KAFKA_GUI_TRUSTSTORE_PASSWORD="QxdasgEJhHqSNEgXmtK"

    KAFKA_GUI_ADMIN_PASSWORD="qwerty"

    # ------------------------------------------

    # elastic
    ELASTICSEARCH_LICENSE="basic"
    ELASTICSEARCH_STACK_VERSION="8.6.0"

    # ldap
    LDAP_DOMAIN_UPPER=${LDAP_DOMAIN^^}
    ENCRYPTION_TYPE_1="aes256-cts-hmac-sha1-96"

    echo LDAP_ORGANISATION=${LDAP_ORGANISATION} >>.env
    echo LDAP_DOMAIN=${LDAP_DOMAIN} >>.env
    echo LDAP_BASE_DN=${LDAP_BASE_DN} >>.env
    echo LDAP_ADMIN_PASSWORD=${LDAP_ADMIN_PASSWORD} >>.env
    echo LDAP_CONFIG_PASSWORD=${LDAP_CONFIG_PASSWORD} >>.env
    echo LDAP_READONLY_USER_PASSWORD=${LDAP_READONLY_USER_PASSWORD} >>.env

    echo ELASTICSEARCH_CLUSTER_NAME=${ELASTICSEARCH_CLUSTER_NAME} >>.env
    echo ELASTIC_PASSWORD=${ELASTIC_PASSWORD} >>.env
    echo ELASTICSEARCH_LICENSE=${ELASTICSEARCH_LICENSE} >>.env
    echo ELASTICSEARCH_STACK_VERSION=${ELASTICSEARCH_STACK_VERSION} >>.env

    echo GRAFANA_OSS_POSTGRES_PASSWORD=${GRAFANA_OSS_POSTGRES_PASSWORD} >>.env
    echo GRAFANA_OSS_SERVER_URL=${GRAFANA_OSS_SERVER_URL} >>.env

    echo REPOSITORY=${REPOSITORY} >>.env
    echo CONFLUENT_DOCKER_TAG=${CONFLUENT_DOCKER_TAG} >>.env
    echo SSL_CIPHER_SUITES=${SSL_CIPHER_SUITES} >>.env

    echo ZOOKEEPER_KEYSTORE_PASSWORD=${ZOOKEEPER_KEYSTORE_PASSWORD} >>.env
    echo ZOOKEEPER_SASL_PASSWORD=${ZOOKEEPER_SASL_PASSWORD} >>.env
    echo ZOOKEEPER_TRUSTSTORE_PASSWORD=${ZOOKEEPER_TRUSTSTORE_PASSWORD} >>.env

    echo IP_KERBEROS_AND_KAFKA=${IP_KERBEROS_AND_KAFKA} >>.env
    echo KAFKA_KEYSTORE_PASSWORD=${KAFKA_KEYSTORE_PASSWORD} >>.env
    echo KAFKA_TRUSTSTORE_PASSWORD=${KAFKA_TRUSTSTORE_PASSWORD} >>.env
    echo KAFKA_ADMIN_SASL_PASSWORD=${KAFKA_ADMIN_SASL_PASSWORD} >>.env

    echo KAFKA_GUI_KEYSTORE_PASSWORD=${KAFKA_GUI_KEYSTORE_PASSWORD} >>.env
    echo KAFKA_GUI_TRUSTSTORE_PASSWORD=${KAFKA_GUI_TRUSTSTORE_PASSWORD} >>.env

    # pass для admin bcript
    KAFKA_GUI_ADMIN_PASSWORD_HASH=$(htpasswd -bnBC 10 '' ${KAFKA_GUI_ADMIN_PASSWORD} | tr -d ':\n' | sed 's/$2y/$2a/')

    echo KAFKA_GUI_ADMIN_PASSWORD=${KAFKA_GUI_ADMIN_PASSWORD} >>.env

    echo LDAP_DOMAIN_UPPER=${LDAP_DOMAIN_UPPER} >>.env
    echo ENCRYPTION_TYPE_1=${ENCRYPTION_TYPE_1} >>.env

    # CA for Elasticsearch
    cd CAElasticsearch && sh generate_CA.sh && cd ../

    # grafana generation certs
    cd grafana && bash generate_cert.bash && cd ../

    # CA for kafka inter-broker communication
    cd CAZooKeeperAndBetweenKafka && sh generate_CA.sh && cd ../

    # elasticsearch generation certs
    cd elasticsearch && bash generate_cert.bash && cd ../

    # fluentd generation certs
    cd fluentd && bash generate_cert.bash && cd ../

    # zookeeper set admin pass
    cd zookeeper && ZOOKEEPER_SASL_PASSWORD=${ZOOKEEPER_SASL_PASSWORD} envsubst < zookeeper_jaas.conf.templ >zookeeper_jaas.conf && cd ../
    # zookeeper generation certs
    cd zookeeper && bash generate_cert_and_keystore.bash && cd ../

    # CA for connect clients to kafka
    cd CAForClientKafka && sh generate_CA.sh && cd ../

    # for connect to zookeeper
    cd kafka && ZOOKEEPER_SASL_PASSWORD=${ZOOKEEPER_SASL_PASSWORD} envsubst < client_zookeeper_jaas.conf.templ > client_zookeeper_jaas.conf && cd ../
    # kafka kdc service
    cd kafka && LDAP_DOMAIN_UPPER=${LDAP_DOMAIN_UPPER} envsubst < krb5.conf.templ > krb5.conf && cd ../
    # kafka generation certs
    cd kafka && bash generate_cert_and_keystore.bash && cd ../

    # connect to kafka
    cd kafka-gui && KAFKA_GUI_KEYSTORE_PASSWORD=${KAFKA_GUI_KEYSTORE_PASSWORD} KAFKA_GUI_TRUSTSTORE_PASSWORD=${KAFKA_GUI_TRUSTSTORE_PASSWORD} KAFKA_ADMIN_SASL_PASSWORD=${KAFKA_ADMIN_SASL_PASSWORD} KAFKA_GUI_ADMIN_PASSWORD_HASH=${KAFKA_GUI_ADMIN_PASSWORD_HASH} envsubst < application.yml.templ > application.yml && cd ../
    cd kafka-gui && bash generate_cert.bash && cd ../

    cd CAForNginx && sh generate_CA.sh && cd ../
    cd nginx && bash generate_cert.bash && cd ../

    docker compose up -d --wait --no-recreate centralized-log-kafka-kdc

    keytabs=(kafka.logs.com)
    if [ -f kafka/${keytabs[-1]}.keytab ]; then
        echo "keytab ${keytabs[-1]} is exists"
    else
        for i in "${keytabs[@]}"; do
            echo "Create service KDC kafka/${i}@${LDAP_DOMAIN_UPPER}"
            docker exec centralized-log-kafka-kdc kadmin.local -q "addprinc -randkey kafka/${i}@${LDAP_DOMAIN_UPPER}"
            echo "Done kafka/${i}@${LDAP_DOMAIN_UPPER}"
            echo "Create service keytab ${i}.keytab"
            docker exec centralized-log-kafka-kdc kadmin.local -q "ktadd -k /${i}.keytab kafka/${i}@${LDAP_DOMAIN_UPPER}"
            echo "Done ${i}.keytab"
            echo "Copy local ${i}"
            docker cp centralized-log-kafka-kdc:/${i}.keytab kafka/${i}.keytab
            echo "Done ${i}"
            chown 1005:1005 kafka/${i}.keytab
        done
    fi

    mkdir -p clients

    chmod u+x restore-backup.sh
    docker compose up -d --no-recreate

else

    docker compose down || true
    docker compose up -d || true

fi
