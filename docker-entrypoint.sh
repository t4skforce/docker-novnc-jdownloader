#!/bin/bash
set -e

PUID=${PUID:-1000}
PGID=${PGID:-1000}
groupmod -o -g "$PGID" app
usermod -o -u "$PUID" app

# check permissions
if [ ! "$(stat -c %u $HOME)" = "$PUID" ]; then
    echo "Change in ownership detected, please be patient while we chown existing files"
  	echo "This could take some time"
  	chown app:app -R $HOME
fi
if [ ! "$(stat -c %u /dev/stdout)" = "$PUID" ]; then
  chown app:app /dev/stdout
fi


# nginx setup
if [ ! -d "$HOME/.cert/nginx.key" ]; then
  echo "creating self signed certificate $HOME/.cert/nginx.crt"
  mkdir -p $HOME/.cert
  openssl req -new -newkey rsa:4096 -days 3650 -nodes -x509 \
    -subj "/C=US/ST=Denial/L=Springfield/O=Dis/CN=${HOSTNAME}" \
    -keyout "$HOME/.cert/nginx.key" -out "$HOME/.cert/nginx.crt"
fi

if [ ! -z "$USERNAME" ]; then
  if [ ! -f "$HOME/.htpasswd" ]; then
    touch "$HOME/.htpasswd"
  fi
  htpasswd -db "$HOME/.htpasswd" $USERNAME $PASSWORD
fi
if [ -f "$HOME/.htpasswd" ]; then
  export NGINX_AUTH="auth_basic \"Administrator’s Area\";auth_basic_user_file $HOME/.htpasswd;"
fi
envsubst '${HOME},${NGINX_AUTH}' < /etc/nginx/nginx.conf.template > /etc/nginx/nginx.conf
unset NGINX_AUTH

# setup for openbox
if [ ! -d "$HOME/.config/openbox" ]; then
  mkdir -p $HOME/.config/openbox
fi
if [ ! -f "$HOME/.config/openbox/rc.xml" ]; then
  cp /etc/xdg/openbox/rc.xml $HOME/.config/openbox/rc.xml
  chown app:app $HOME/.config/openbox/rc.xml
fi
if [ ! -f "$HOME/.config/openbox/autostart" ]; then
  touch $HOME/.config/openbox/autostart
  chmod +x $HOME/.config/openbox/autostart
  chown app:app $HOME/.config/openbox/autostart
fi
# menu bar
if ! grep -q tint2 "$HOME/.config/openbox/autostart"; then
  echo '(sleep 1s && tint2) &' >> $HOME/.config/openbox/autostart
fi
if [ ! -f "$HOME/.config/tint2/tint2rc" ]; then
  mkdir -p $HOME/.config/tint2
  cp /etc/tint2rc $HOME/.config/tint2/tint2rc
fi

# wallpaper
if ! grep -q feh "$HOME/.config/openbox/autostart"; then
  echo '(sleep 1s && while true; do feh --bg-fill /etc/wallpaper.jpg; sleep 1m; done) &' >> $HOME/.config/openbox/autostart
fi

echo "
-------------------------------------
User uid:    $(id -u app)
User gid:    $(id -g app)
-------------------------------------
"

exec supervisord "$@"
