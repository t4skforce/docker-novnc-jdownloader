#!/bin/bash
set -e

if [ ! -d "${HOME}/.jd" ]; then
  mkdir -p "${HOME}/.jd"
fi

if [ ! -d "${HOME}/Downloads" ]; then
  mkdir -p "${HOME}/Downloads"
fi

cd "${HOME}/.jd"

if [ ! -f "JDownloader.jar" ]; then
  echo "Downloading Jdownloader"
  wget --quiet -O JDownloader.jar http://installer.jdownloader.org/JDownloader.jar
  if [ $? -ne 0 ]; then
    echo "Cannot download Jdownloader!"
    exit 2
  fi
fi

java -jar JDownloader.jar "$@"
