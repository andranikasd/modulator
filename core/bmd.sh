#!/bin/bash

set -e
# set -x

DATE=$(date +'%Y-%m-%dT%H:%M:%S%z')
bmd_root=".modules"
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

# Available commands `install`, `update`, `remove`, `help`
_help() {
  echo "bmd [command] [options]"
}

_init() {
  if [[ "${#}" -le 1 ]]; then
    err "Looks like you dont know how to use this ..."
    _help
    exit 1
  fi

  shift # Shifting to not get functions name
  local arguments=("${@}")

  # Parsing the arguments to function
  for ((i = 0; i < ${#arguments[@]}; i++)); do
    case "${arguments[i]}" in
    --global)
      init_global
      return
      ;;
    *)
      local project_dir="${arguments[i]}"
      init_local "${project_dir}"
      ;;
    esac

  done
}

init_global() {
  info "Running global module installation ..."
}

init_local() {
  local install_dir=$1
  info "Running local module installation ..."
  info "Directory to install -> ${install_dir}"
}

clone_git_repo() {
  # ---------------------------------
  # Clones git repository by given url
  # Globals:
  #   modules_directory: The directory where we are putting used modules
  # Arguments:
  #   url: $1 -> Url of git repository
  #   name: $2 -> Name of the module to use
  # Returns:
  # ---------------------------------
  if [[ $# -lt 2 ]]; then
    err "The repository url and module name must be provider" && exit 1
  fi

  if [[ ! $(command -v git) ]]; then
    err "Please make sure you have git installed" && exit 1
  fi
  local url=$1
  local module_name=$2

  mkdir -p .modules

  if ! output=$(git clone "${url}" "${modules_directory}/${module_name}" 2>&1); then
    err_code=$?
    err "${output}"
    err "Something went wrong with git clone. Exiting with code ${err_code}."
    exit ${err_code}
  fi
  info "Cloned ${1} for module named ${2}"
}

is_module_installed() {
  # ------------------------------
  # Checks if module was installed already. If yes returns it's version, if no returns 0
  # Globals:
  #   modules_directory: The directory where we are outting used modules and configs
  # Arguments:
  #   module: $1 -> Name of the module to check for
  # Rerurns:
  #   version if module is installed, 0 instead
  # ------------------------------
  if [[ $# -eq 0 ]]; then
    err "Module name is required to provide" && exit 1
  fi
  local module=$1

}

handle_user_input() {
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
  *)
    err "Some wrong command goes ..."
    _help
    ;;
  esac
}

handle_user_input "${@}"
