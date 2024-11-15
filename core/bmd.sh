#!/bin/bash

set -e
# set -x

DATE=$(date +'%Y-%m-%dT%H:%M:%S%z')
bmd_root=".bmd"
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

_install() {
  if [[ -z ${BMD_CONFIG_DIR} ]]; then
    err "Oops ... Please set BMD_CONFIG_DIR environment variable"
    exit 1
  fi
  if [[ ! -d "${BMD_CONFIG_DIR}" && ! -d "${HOME}/.bmd" ]]; then
    err "Oops ... Your BMD config file is not found"
  fi
  info "Installing package .. "
}

# Available commands `install`, `update`, `remove`, `help`
_help() {
  echo "bmd [command] [options]"
  echo "init: bmd init command is used to initialize bmd tool
  [--global | glob | global | -g] ==> Initialize in users scope
  [directory]                     ==> Initialize in give Directory"
}

_init() {
  if [[ "${#}" -eq 0 ]]; then
    err "Looks like you dont know how to use this ..."
    _help
    exit 1
  fi

  shift # Shifting to not get functions name
  local arguments=("${@}")
  local install_dir="${PWD}"

  # Parsing the arguments to function
  for ((i = 0; i < ${#arguments[@]}; i++)); do
    case "${arguments[i]}" in
    --global | -g | global | glob)
      install_dir="${HOME}"
      break
      ;;
    *)
      if [[ ! -d "${arguments[i]}" ]]; then
        err "Provided directory does not exists"
        exit 1
      fi
      install_dir="${arguments[i]}"
      ;;
    esac
  done

  # Ensure install_dir is set
  if [[ -z "${install_dir}" ]]; then
    err "Installation directory could not be determined."
    _help
    exit 1
  fi

  info "Directory to install -> ${install_dir}"
  install_dir="$(realpath "${install_dir}")"
  info "Directory is ${install_dir}"
  local current_bmd_root="${install_dir}/${bmd_root}"
  mkdir -p "${current_bmd_root}"
  echo "[]" >"${current_bmd_root}/bmd.json"
  echo "export BMD_CONFIG_DIR=${current_bmd_root}" >>"${HOME}/.bashrc"
  if [[ -f "${HOME}/.bashrc" ]]; then
    source "${HOME}/.bashrc"
  fi
}

start_bmd() {
  if [[ "${#}" -eq 0 ]]; then
    err "No command options was provided"
    _help
    exit 1
  fi

  local command=$1

  case $command in
  help | -h | --help)
    _help
    ;;
  init)
    _init "$@"
    ;;
  install)
    _install "$@"
    ;;
  *)
    err "Some wrong command goes ..."
    _help
    ;;
  esac
}

start_bmd "${@}"
