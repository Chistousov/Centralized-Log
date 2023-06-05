FROM debian:11.6 AS get-dep

USER root

RUN /bin/bash -c 'if ! [ -z "HTTP_PROXY" ]; then echo Acquire::http::proxy \"$HTTP_PROXY\"\; >> /etc/apt/apt.conf.d/10proxy ; fi \
                  && if ! [ -z "HTTPS_PROXY" ]; then echo Acquire::https::proxy \"$HTTPS_PROXY\"\; >> /etc/apt/apt.conf.d/10proxy ; fi \
                  && if ! [ -z "NO_PROXY" ]; then echo Acquire::no::proxy \"$NO_PROXY\"\; >> /etc/apt/apt.conf.d/10proxy ; fi \
                  && cat /etc/apt/apt.conf.d/10proxy \
                  && apt update --fix-missing \
                  && apt --download-only --assume-yes install krb5-user libsasl2-modules-gssapi-mit'

# .deg
RUN mkdir -p /dpkg/var/lib/dpkg/status.d/ && \
    for deb in /var/cache/apt/archives/*.deb; do \
        package_name=$(dpkg-deb -I ${deb} | awk '/^ Package: .*$/ {print $2}'); \ 
        echo "Process: ${package_name}"; \
        dpkg --ctrl-tarfile $deb | tar -Oxf - ./control > /dpkg/var/lib/dpkg/status.d/${package_name}; \
        dpkg --extract $deb /dpkg || exit 10; \
    done

# Remove unnecessary files extracted from deb packages like man pages and docs etc.
RUN find /dpkg/ -type d -empty -delete && \
    rm -r /dpkg/usr/share/doc/

FROM fluent/fluent-bit:2.0.10

# Copy the libraries from the extractor stage into root
COPY --from=get-dep /dpkg /

# Now copy the static shell into base image.
COPY --from=get-dep /bin/sh /bin/sh