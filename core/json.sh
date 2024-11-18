#!/bin/bash

bmd_root=".bmd"
declare -A COLORS
declare -A modules
declare json_oneline

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

json_file="/home/codeex/Public/modulator/core/bmd.json"
JSON_parse "${json_file}"
