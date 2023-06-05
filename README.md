# **Centralized Log**

## Description

An example of centralized collection and storage of logs from several sources. The project is divided into two parts: a server (centralized-log) and a client (client). The docker-images folder contains custom Fluentd and Fluent Bit Docker Image.

The client, using two Fluent Bit Docker Containers, collects logs and transfers them to a central server (or rather, transfers Kafka).

Kafka takes logs as JSON and adds them to a special topic. Then Fluentd Docker Containers take logs from a special topic and transfer them to Elasticsearch for long-term storage. With Fluentd, you can post-process logs. Through Dashboards Grafana you can monitor the logs.

Пример централизованного сбора и хранения логов с нескольких источников. Проект разбит на две части: сервер (centralized-log) и клиент (client). В папке docker-images хранятся custom Fluentd и Fluent Bit Docker Image.

Клиент с помощью двух Fluent Bit Docker Containers собирает логи и передает их на центральный сервер (а если точнее передает Kafka).

Kafka принимает логи в виде JSON и добавляет их в специальный topic. Затем Fluentd Docker Containers берут логи из специального topic и передают в Elasticsearch на долгое хранение. С помощью Fluentd можно делать постобработку logs. Через Dashboards Grafana Вы можете мониторить логи.

## Build Fluentd or Fluent Bit Docker Image

### Proxy
#### Docker (Debian)

```bash
mkdir -p /etc/systemd/system/docker.service.d

# set proxy
cat > /etc/systemd/system/docker.service.d/http-proxy.conf <<-EOF
[Service]
Environment="HTTP_PROXY=http://proxyuser:proxypass@192.168.20.4:8822/"
Environment="HTTPS_PROXY=http://proxyuser:proxypass@192.168.20.4:8822/"
Environment="NO_PROXY=localhost,127.0.0.1"
EOF

# restart docker
sudo systemctl daemon-reload
sudo systemctl restart docker

# check
systemctl show --property=Environment docker

```

#### APT (Docker image)
If you need to specify a proxy server (apt see docker-images/fluentd/Dockerfile or docker-images/fluent-bit/Dockerfile), then uncomment HTTP_PROXY (HTTPS_PROXY or/and NO_PROXY) and edit HTTP_PROXY (HTTPS_PROXY or/and NO_PROXY)

Если необходимо указать прокси сервер (apt see docker-images/fluentd/Dockerfile or docker-images/fluent-bit/Dockerfile), то раскомментируйте HTTP_PROXY (HTTPS_PROXY or/and NO_PROXY) и отредактируйте HTTP_PROXY (HTTPS_PROXY or/and NO_PROXY)

```bash
 #!/bin/bash

export HTTP_PROXY="http://proxyuser:proxypass@192.168.20.4:8822/"
export HTTPS_PROXY="http://proxyuser:proxypass@192.168.20.4:8822/"
export NO_PROXY="localhost,127.0.0.1"

REPO_IMAGE="chistousov"
...

```

### Build

```bash
# Fluentd
cd docker-images/fluentd
bash build_image.bash
# Fluent Bit
cd docker-images/fluent-bit
bash build_image.bash
```

# Getting Started

![centralized-log](centralized-log.jpg)

Requires Docker, Docker Compose, JDK 11(keytool), openssl, envsubst (apt install apache2-utils) on both server and client.

Требуется Docker, Docker Compose, JDK 11(keytool), openssl, envsubst (apt install apache2-utils) как на сервере, так и на клиенте.

**REALM is FOO.COM**

| Type                | DNS, Hostname           | IP            |
| -------------       | -------------           | ------------- |
| KDC                 | kerberos.kafka.logs.com | 192.168.0.101 |
| Kafka               | kafka.logs.com          | 192.168.0.101 |
| Kafka GUI (AKHQ.IO) | gui.kafka.logs.com      | 192.168.0.101 |
| Grafana             | logs.com                | 192.168.0.101 |
| client              | superclient             | 192.168.0.104 |


## Server

Go to the folder with the server

Переходим в папку с сервером

```bash
cd centralized-log
```

Edit the environment variables at the beginning of the start.bash file.
To find out the ip address, you can run ***ip a***.

Редактируем переменные окружения в начале файла start.bash.
Чтоб узнать ip адрес можно выполнить ***ip a***.
```bash

    # ------------------!!!EDIT!!!----------------

    # ldap and kerberos
    LDAP_ORGANISATION="MyOrg"
    LDAP_DOMAIN="foo.com"
    LDAP_BASE_DN="dc=foo,dc=com"
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
    IP_KERBEROS_AND_KAFKA="192.168.0.101"
    KAFKA_KEYSTORE_PASSWORD="2U7387r29tcK6"
    KAFKA_TRUSTSTORE_PASSWORD="37Q5xOb8hoasj"
    # PLAIN SASL
    KAFKA_ADMIN_SASL_PASSWORD="KLrOTUbatqsd6d2hswv"

    # kafka gui
    KAFKA_GUI_KEYSTORE_PASSWORD="elaWgSO4y4MlYS1hgYr"
    KAFKA_GUI_TRUSTSTORE_PASSWORD="QxdasgEJhHqSNEgXmtK"

    KAFKA_GUI_ADMIN_PASSWORD="qwerty"

    # ------------------------------------------
...
```

Run as root

Запускаем как root

```bash
bash start.bash
```

Adding a client

Добавляем клиента 

```bash
bash add_user.bash superclient
```

Copying files for the client

Копируем файлы для клиента

```
scp -r clients/superclient someuser@superclient:/tmp/
scp -r CAForClientKafka/ca.crt someuser@superclient:/tmp/
```

## Client

Go to client folder

Переходим в папку с клиентом

```bash
cd client
```
Copying files for the client

Копируем файлы для клиента

```bash
# mTLS
mv /tmp/superclient/superclient.key
mv /tmp/superclient/superclient.crt
mv /tmp/ca.crt
# kerberos 5
mv /tmp/superclient/superclient.keytab
```

Edit the environment variables at the beginning of the start.bash file.
To find out the ip address, you can run ***ip a***.

Редактируем переменные окружения в начале файла start.bash.
Чтоб узнать ip адрес можно выполнить ***ip a***.

```bash
    # ------------------!!!EDIT!!!----------------

    LDAP_DOMAIN="foo.com"
    CLIENT_ID="superclient"
    IP_KERBEROS_AND_KAFKA="192.168.0.104"

    # ------------------------------------------
...
```

Run as root

Запускаем как root

```bash
bash start.bash
```

## Check

DESCRIPTION OF THE IP ADDRESS OF logs.com IN THE FILE /etc/hosts.

ОПИСЫВАЕМ IP АДРЕС logs.com В ФАЙЛЕ /etc/hosts.

```bash
echo '192.168.0.101 logs.com' >> /etc/hosts
# check
ping logs.com
```

DESCRIPTION OF THE IP ADDRESS OF THE superclient IN THE FILE /etc/hosts.

ОПИСЫВАЕМ IP АДРЕС superclient В ФАЙЛЕ /etc/hosts.

```bash
echo '192.168.0.104 superclient' >> /etc/hosts
# check
ping superclient
```

We send a test request to the client (test-log-nginx)

Отправляем тестовый запрос на клиента (test-log-nginx)

```bash
curl http://superclient:9567/
```

We go to the browser and request https://logs.com/.
Enter login admin and password admin. We change the password.

Заходим в браузер и запрашиваем https://logs.com/.
Вводим login admin и пароль admin. Меняем пароль.

![Configuration->Data-source](Configuration-Data-source.PNG)

Then click Elastic

Потом нажимаем Elastic
![Elastic Data Source](Elastic-Data-Source.PNG)

At the very bottom, click Test

В самом низу нажимаем Test
![Test Elastic Data Source](Test-El-Data-Source.PNG)

For our example (client -> docker-compose.yaml -> test-log-nginx):
- elasticsearch index = my-custom-group-apps.test-log-nginx-yyyy.MM.dd
- time field name = datetime_iso8601_with_timezone_offset
- app field JSON = my-custom-group-apps
- app_part field JSON (backend, frontend, db, etc.) = test-log-nginx
- env field JSON (develop, staging, prod, etc.) = prod
- hostname field JSON (server of source log) = superclient
- source field JSON (stdout, stderr) = stdout/stderr
- log field JSON = log app


## GUI Kafka (AKHQ.IO)

DESCRIBE IP ADDRESS gui.kafka.logs.com IN THE FILE /etc/hosts.

ОПИСЫВАЕМ IP АДРЕС gui.kafka.logs.com В ФАЙЛЕ /etc/hosts.

```bash
echo '192.168.0.101 gui.kafka.logs.com' >> /etc/hosts
# check
ping gui.kafka.logs.com
```

We go to the browser and request https://gui.kafka.logs.com/. We enter login admin, and see the password KAFKA_GUI_ADMIN_PASSWORD in start.bash.

Заходим в браузер и запрашиваем https://gui.kafka.logs.com/. Вводим login admin, а пароль посмотрите KAFKA_GUI_ADMIN_PASSWORD в start.bash.


## Stop

We stop containers with saving data (volume).

Останавливаем контейнеры с сохранением данных (volume).

```bash
bash stop.bash
```

## Stop and clean

We stop containers and delete all data (volume).

Останавливаем контейнеры и удаляем все данные(volume).

```bash
bash stop_and_clean.bash
```

## Debug

To debug kerberos (client or server):
```bash
export KRB5_TRACE=/dev/stdout
```

<hr>

## Backup and Restore from backup. SMB/CIFS (Advansed)

If you want to make periodic backups or you are transferring application data from one system to another system and want to restore data from a backup, then this section is for you.

Если Вы хотите делать переодические backup или Вы переносите данные приложения с одной системы
на другую систему и хотите восстановить данные с backup, то эта секция для Вас.

Create an SMB/CIFS share where you will store your backups.

Создайте SMB/CIFS share, где будите хранить backupЫ.

Uncomment (Расскоментируйте):
- services (containers \*restore\*, \*backup\*)
- volumes \*-backup-volume
- depends_on containers \*restore\*, \*backup\*

Edit volumes \*-backup-volume with the options you need.

Отредактируйте volumes \*-backup-volume с необходимыми параметрами для Вас.

BACKUP_CRON_EXPRESSION = when does the backup take place (cron).

BACKUP_CRON_EXPRESSION = когда происходит backup (cron).

<hr>

## Creators

Nikita Konstantinovich Chistousov 

chistousov.nik@yandex.ru

## License

MIT
