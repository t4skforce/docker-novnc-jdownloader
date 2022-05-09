FROM t4skforce/docker-novnc:latest

ARG BUILD_DATE="2022-05-09T15:19:55Z"

RUN set -xe && \
    apt-get update -y && \
    apt-get install -y --no-install-recommends default-jre && \
    rm -rf /var/lib/apt/lists && \
    export JAVA_HOME=$(cd /usr/lib/jvm/*openjdk* ; pwd) && echo "JAVA_HOME=$JAVA_HOME" >> /etc/environment && \
    export PATH=$JAVA_HOME/bin:$PATH && echo "PATH=$PATH" >> /etc/environment && \
    find /usr/share/applications/ -type f -not -name 'tint2.desktop' -delete

COPY ./templates/. /
