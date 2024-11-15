#!/bin/bash

###############################
# Echo wrapper to use as logger
###############################

DATE=$(date +'%Y-%m-%dT%H:%M:%S%z')
declare -A COLORS

COLORS[info]='\033[0;37m'
COLORS[warrning]='\033[0;33m'
COLORS[error]='\033[1;31m'
COLORS[time]='\033[0;34m'
COLORS[reset]='\033[0m'


info() {
  if [ "$#" -eq 0 ]; then
    echo -e "${COLORS[error]}[$(date +'%Y-%m-%dT%H:%M:%S%z')]: function info() requires arguments(str) ${COLORS[reset]}" >&2 && exit 1
  fi

  echo -e "${COLORS[time]}${DATE}${COLORS[reset]} |${COLORS[info]}INFO${COLORS[reset]}| ${1}"
}

warn() {
  if [ "$#" -eq 0 ]; then
    echo -e "${COLORS[error]}[$(date +'%Y-%m-%dT%H:%M:%S%z')]: function warn() requires arguments(str) ${COLORS[reset]}" >&2 && exit 1
  fi

  echo -e "${COLORS[time]}${DATE}${COLORS[reset]} |${COLORS[warrning]}WARN${COLORS[reset]}| ${1}"
}

err() {
  if [ "$#" -eq 0 ]; then
    echo -e "${COLORS[error]}[$(date +'%Y-%m-%dT%H:%M:%S%z')]: function err() requires arguments(str) ${COLORS[reset]}" >&2 && exit 1
  fi

  echo -e "${COLORS[time]}${DATE}${COLORS[reset]} |${COLORS[error]}ERROR${COLORS[reset]}| ${1}"
}
