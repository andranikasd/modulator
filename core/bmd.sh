#!/bin/bash

set -e
set -x

bmd_root=".bmd"
declare json_oneline
declare -A modules
declare BMD_DIR
declare mode
declare json_file

declare -A COLORS
COLORS[info]='\033[0;37m'
COLORS[warning]='\033[0;33m'
COLORS[error]='\033[1;31m'
COLORS[time]='\033[0;34m'
COLORS[reset]='\033[0m'

info() {
  [[ $# -eq 0 ]] && {
    echo -e "${COLORS[error]}$(date +'%Y-%m-%dT%H:%M:%S%z'): [ERROR] 'info' requires a message.${COLORS[reset]}" >&2
    exit 1
  }
  echo -e "${COLORS[time]}$(date +'%Y-%m-%dT%H:%M:%S%z')${COLORS[reset]} |${COLORS[info]} INFO ${COLORS[reset]}| $1"
}

warn() {
  [[ $# -eq 0 ]] && {
    echo -e "${COLORS[error]}$(date +'%Y-%m-%dT%H:%M:%S%z'): [ERROR] 'warn' requires a message.${COLORS[reset]}" >&2
    exit 1
  }
  echo -e "${COLORS[time]}$(date +'%Y-%m-%dT%H:%M:%S%z')${COLORS[reset]} |${COLORS[warning]} WARNING ${COLORS[reset]}| $1"
}

err() {
  [[ $# -eq 0 ]] && {
    echo -e "${COLORS[error]}$(date +'%Y-%m-%dT%H:%M:%S%z'): [ERROR] 'err' requires a message.${COLORS[reset]}" >&2
    exit 1
  }
  echo -e "${COLORS[time]}$(date +'%Y-%m-%dT%H:%M:%S%z')${COLORS[reset]} |${COLORS[error]} ERROR ${COLORS[reset]}| $1"
}

JSON_parse_array() {
  local objects_array
  objects_array=$(echo "${json_oneline}" | sed -e 's/^\[\(.*\)\]$/\1/' | sed 's/},/}\n/g')
  while IFS= read -r object; do
    JSON_parse_module "${object}"
  done <<<"${objects_array}"
}

JSON_parse_module() {
  local object="$1"
  local name source version path
  name=$(echo "${object}" | grep -o '"name": *"[^"]*"' | sed 's/"name": *"\([^"]*\)"/\1/')
  source=$(echo "${object}" | grep -o '"source": *"[^"]*"' | sed 's/"source": *"\([^"]*\)"/\1/')
  version=$(echo "${object}" | grep -o '"version": *"[^"]*"' | sed 's/"version": *"\([^"]*\)"/\1/')
  path=$(echo "${object}" | grep -o '"path": *"[^"]*"' | sed 's/"path": *"\([^"]*\)"/\1/')

  modules["$name.source"]="$source"
  modules["$name.version"]="$version"
  modules["$name.path"]="$path"
}

module_read() {
  local module_name="$1"
  local property="$2"
  echo "${modules["$module_name.$property"]}"
}

module_write() {
  local file="$1"
  echo "[" >"${file}"
  local printed_modules=""
  for key in "${!modules[@]}"; do
    local name=${key%%.*}
    if [[ ! $printed_modules =~ $name ]]; then
      echo "  {" >>"${file}"
      echo "    \"name\": \"$name\"," >>"${file}"
      echo "    \"source\": \"${modules["$name.source"]}\"," >>"${file}"
      echo "    \"version\": \"${modules["$name.version"]}\"," >>"${file}"
      echo "    \"path\": \"${modules["$name.path"]}\"" >>"${file}"
      echo "  }," >>"${file}"
      printed_modules+="$name "
    fi
  done
  sed -i '$ s/,$//' "${file}"
  echo "]" >>"${file}"
}

JSON_parse() {
  local file="${1}"
  json_oneline=""
  if [ ! -f "${file}" ]; then
    err "JSON file '${file}' not found."
    exit 1
  fi
  while IFS= read -r line; do
    json_oneline+="${line}"
  done <"${file}"
  JSON_parse_array
}

check_module_exists() {
  local module_name=$1
  if [[ -n "${modules["$module_name.source"]}" || -n "${modules["$module_name.version"]}" || -n "${modules["$module_name.path"]}" ]]; then
    info "Module '${module_name}' exists."
    return 0
  else
    warn "Module '${module_name}' does not exist."
    return 1
  fi
}

install_cmd() {
  if [[ ! -d "${PWD}/${bmd_root}" && ! "$*" =~ "--global" ]]; then
    err "BMD is not configured for the current directory. Use the --global flag for global scope."
    exit 1
  fi

  shift
  local arguments=("${@}")
  local module_url module_name

  # Parse arguments
  for ((i = 0; i < ${#arguments[@]}; i++)); do
    case "${arguments[i]}" in
    --global | -g)
      mode="global"
      if [[ ! -d "${HOME}/${bmd_root}" ]]; then
        err "BMD is not configured for global scope. Please initialize BMD with 'bmd init --global'."
        exit 1
      fi
      json_file="${HOME}/${bmd_root}/bmd.json"
      ;;
    *)
      if [[ -z "$module_url" ]]; then
        module_url="${arguments[i]}"
      elif [[ -z "$module_name" ]]; then
        module_name="${arguments[i]}"
      else
        err "Unexpected argument: ${arguments[i]}"
        exit 1
      fi
      ;;
    esac
  done

  # Default to local mode if not specified
  if [[ -z "$mode" ]]; then
    mode="local"
    json_file="${PWD}/${bmd_root}/bmd.json"
  fi

  # Ensure the JSON file exists
  if [[ ! -f "$json_file" ]]; then
    err "BMD configuration file '$json_file' not found. Please initialize BMD first."
    exit 1
  fi

  # Parse the JSON file and check for module existence
  JSON_parse "$json_file"
  if check_module_exists "$module_name"; then
    err "Module '$module_name' is already installed."
    exit 1
  fi

  # Add module details
  modules["$module_name.source"]="$module_url"
  modules["$module_name.version"]="1.0.0"
  modules["$module_name.path"]="${BMD_DIR:-$PWD}/$module_name"
  mkdir -p "${modules["$module_name.path"]}"

  # Write updated JSON to file
  module_write "$json_file"
  info "Module '$module_name' installed and configuration updated."
}

_help() {
  echo "==============================================================="
  echo "                         BMD Tool Help                        "
  echo "==============================================================="
  echo "Usage: bmd [command] [options]"
  echo ""
  echo "Commands:"
  echo "  init     Initialize the BMD tool in the current directory or globally."
  echo "  install  Install a module in the appropriate scope."
  echo "  help     Display this help message."
  echo ""
}

_init() {
  if [[ "${#}" -eq 0 ]]; then
    err "No options provided for initialization."
    _help
    exit 1
  fi

  shift
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
  mkdir -p "${install_dir}/${bmd_root}"
  echo "[]" >"${install_dir}/${bmd_root}/bmd.json"
  info "BMD successfully initialized at: ${install_dir}/${bmd_root}"
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
  install | i | inst)
    install_cmd "$@"
    ;;
  *)
    err "Invalid command: '${command}'. Please use 'bmd help' for valid options."
    _help
    ;;
  esac
}

start_bmd "${@}"

