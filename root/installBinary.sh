#!/bin/bash

. /plex-common.sh

addVarToConf "version" "${TAG}"
addVarToConf "plex_build" "${PLEX_BUILD}"
addVarToConf "plex_distro" "${PLEX_DISTRO}"

if [ ! -z "${URL}" ]; then
  echo "Attempting to install from URL: ${URL}"
  installFromRawUrl "${URL}"
elif [ "${TAG}" != "beta" ] && [ "${TAG}" != "public" ]; then
  getVersionInfo "${TAG}" "" remoteVersion remoteFile

  if [ -z "${remoteVersion}" ] || [ -z "${remoteFile}" ]; then
    echo "Could not get install version"
    exit 1
  fi
  
  echo "Attempting to install: ${remoteVersion}"
  installFromUrl "${remoteFile}"
fi

# Add to crontab
if crontab -l 2> /dev/null; then
  echo "$(echo '*/1 * * * * /etc/services.d/plex/sync'; crontab -l)" | crontab -
else
  echo '*/1 * * * * /etc/services.d/plex/sync' | crontab -
fi

# Start cron
service cron start
