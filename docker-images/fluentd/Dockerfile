FROM fluentd:v1.16.0-debian-1.0

USER root

RUN /bin/bash -c 'gem install fluent-plugin-elasticsearch --no-document --version 5.2.4 \
                  && gem install fluent-plugin-kafka --no-document --version 0.18.1'

USER fluent