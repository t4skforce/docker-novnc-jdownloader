FROM golang:1.14-buster AS easy-novnc-build
WORKDIR /src
RUN set -xe && \
    go mod init build && \
    go get github.com/geek1011/easy-novnc@v1.1.0 && \
    go build -o /bin/easy-novnc github.com/geek1011/easy-novnc

FROM debian:buster-slim

ENV HOME=/data \
    PUID=1000 \
    PGID=1000

RUN set -xe && \
    apt-get update -y && \
    apt-get install -y --no-install-recommends openbox obconf tint2 feh papirus-icon-theme arc-theme tigervnc-standalone-server supervisor cron && \
    rm -rf /var/lib/apt/lists && \
    mkdir -p /usr/share/desktop-directories

RUN set -xe && \
    apt-get update -y && \
    apt-get install -y --no-install-recommends terminator nano wget curl openssh-client rsync ca-certificates xdg-utils htop tar xzip gzip bzip2 zip unzip fonts-dejavu fonts-liberation2 && \
    rm -rf /var/lib/apt/lists

RUN set -xe && \
    apt-get update -y && \
    apt-get install -y --no-install-recommends nginx-light gettext-base apache2-utils && \
    rm -r /etc/nginx/nginx.conf && \
    rm -rf /var/lib/apt/lists

COPY cronjobs /etc/cron.d/
RUN set -xe && \
    chmod 0644 /etc/cron.d/cronjobs

COPY docker-entrypoint.sh /usr/bin/docker-entrypoint.sh
COPY --from=easy-novnc-build /bin/easy-novnc /usr/local/bin/
COPY menu.xml /etc/xdg/openbox/
COPY rc.xml /etc/xdg/openbox/
COPY tint2rc /etc/
COPY wallpaper.jpg /etc/
COPY supervisord.conf /etc/
COPY nginx.conf.template /etc/nginx/
COPY auth.sh /usr/bin/basic_auth

RUN groupadd --gid ${PUID} app && \
    useradd --home-dir ${HOME} --shell /bin/bash --uid ${PUID} --gid ${PUID} app && \
    mkdir -p ${HOME}

RUN set -xe && \
    mkdir -p /usr/share/man/man1 && \
    apt-get update -y && \
    apt-get install -y --no-install-recommends default-jre && \
    rm -rf /var/lib/apt/lists && \
    export JAVA_HOME=$(cd /usr/lib/jvm/*openjdk* ; pwd) && echo "JAVA_HOME=$JAVA_HOME" >> /etc/environment && \
    export PATH=$JAVA_HOME/bin:$PATH && echo "PATH=$PATH" >> /etc/environment

COPY jdownloader.sh /usr/bin/jdownloader
COPY app.desktop /usr/share/applications/

WORKDIR ${HOME}
VOLUME ${HOME}

EXPOSE 80 443
ENTRYPOINT [ "docker-entrypoint.sh" ]
CMD []
