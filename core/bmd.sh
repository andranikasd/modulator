#!/bin/bash

set -e
# set -x

DATE=$(date +'%Y-%m-%dT%H:%M:%S%z')
bmd_root=".bmd"
declare -A COLORS

COLORS[info]='\033[0;37m'
COLORS[warning]='\033[0;33m'
COLORS[error]='\033[1;31m'
COLORS[time]='\033[0;34m'
COLORS[reset]='\033[0m'

info() {
  if [ "$#" -eq 0 ]; then
    echo -e "${COLORS[error]}[$(date +'%Y-%m-%dT%H:%M:%S%z')]: [ERROR] The function 'info' requires a message argument. ${COLORS[reset]}" >&2 && exit 1
  fi

  echo -e "${COLORS[time]}${DATE}${COLORS[reset]} |${COLORS[info]} INFO ${COLORS[reset]}| ${1}"
}

warn() {
  if [ "$#" -eq 0 ]; then
    echo -e "${COLORS[error]}[$(date +'%Y-%m-%dT%H:%M:%S%z')]: [ERROR] The function 'warn' requires a message argument. ${COLORS[reset]}" >&2 && exit 1
  fi

  echo -e "${COLORS[time]}${DATE}${COLORS[reset]} |${COLORS[warning]} WARNING ${COLORS[reset]}| ${1}"
}

err() {
  if [ "$#" -eq 0 ]; then
    echo -e "${COLORS[error]}[$(date +'%Y-%m-%dT%H:%M:%S%z')]: [ERROR] The function 'err' requires a message argument. ${COLORS[reset]}" >&2 && exit 1
  fi

  echo -e "${COLORS[time]}${DATE}${COLORS[reset]} |${COLORS[error]} ERROR ${COLORS[reset]}| ${1}"
}

_install() {
  if [[ ! -d "${PWD}/${bmd_root}" ]]; then
    err "BMD is not configured for current dir, to install module for global scope please use -g flag"
    exit
  fi
  shift # Remove the function name from arguments
  local arguments=("${@}")

  for ((i = 0; i < ${#arguments[@]}; i++)); do
    case "${arguments[i]}" in
    --global | -g | global | glob)
      if [[ ! -d "${HOME}/${bmd_root}" ]]; then
        err "BMD is not configured for user scope. Please Initialize bmd again"
        _help
      fi
      break
      ;;
    *)
      if [[ ! -d "${arguments[i]}" ]]; then
        err "Oops specified argument does not exist."
        _help
        exit 1
      fi
      ;;
    esac
  done
}

lex() {

}
# Generic function to wrap all bmd config file operations in it
# Arguments:
#   file_path: bmd config file path (Required)
#   command: `add`, `update`, `remove`, `check`: Operations available for bmd config (Required)
#   arguments: `module-name`, `module-path` or `module-url`, `cversion` (Current version), `nversion` (New version)
#
parser() {
  local tokens = ()
  shift ## Shifting $1 function name argument
  local arguments=("${@}")


}

_help() {
  echo "==============================================================="
  echo "                         BMD Tool Help                        "
  echo "==============================================================="
  echo "Usage: bmd [command] [options]"
  echo ""
  echo "Commands:"
  echo "  init     Initialize the BMD tool in the current directory or globally."
  echo "           Options:"
  echo "             --global | -g     Initialize BMD in the user's home directory."
  echo "             [directory]       Specify a directory for initialization."
  echo ""
  echo "  install  Ensure BMD is initialized in the appropriate scope."
  echo ""
  echo "  help     Display this help message."
  echo ""
  echo "Examples:"
  echo "  bmd init --global            Initialize BMD globally."
  echo "  bmd init /path/to/directory  Initialize BMD in the specified directory."
  echo "  bmd install                  Check if BMD is properly initialized."
  echo "==============================================================="
}

_init() {
  if [[ "${#}" -eq 0 ]]; then
    err "No options provided for initialization."
    _help
    exit 1
  fi

  shift # Remove the function name from arguments
  local arguments=("${@}")
  local install_dir="${PWD}"

  for ((i = 0; i < ${#arguments[@]}; i++)); do
    case "${arguments[i]}" in
    --global | -g | global | glob)
      install_dir="${HOME}"
      break
      ;;
    *)
      if [[ ! -d "${arguments[i]}" ]]; then
        err "The specified directory '${arguments[i]}' does not exist. Please provide a valid directory."
        exit 1
      fi
      install_dir="${arguments[i]}"
      ;;
    esac
  done

  if [[ -z "${install_dir}" ]]; then
    err "Unable to determine the installation directory."
    _help
    exit 1
  fi

  info "Initializing BMD in directory: ${install_dir}"
  install_dir="$(realpath "${install_dir}")"
  info "Resolved directory path: ${install_dir}"
  local current_bmd_root="${install_dir}/${bmd_root}"
  mkdir -p "${current_bmd_root}"
  echo "[]" >"${current_bmd_root}/bmd.json"
  info "BMD successfully initialized at: ${current_bmd_root}"
}

start_bmd() {
  if [[ "${#}" -eq 0 ]]; then
    err "No command provided! Use 'bmd help' to view available commands."
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
    err "Invalid command: '${command}'. Please use 'bmd help' for valid options."
    _help
    ;;
  esac
}

start_bmd "${@}"
