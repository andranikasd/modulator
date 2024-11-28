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
  echo -e "${COLORS[time]}$(date +'%Y-%m-%dT%H:%M:%S%z')${COLORS[reset]} |${COLORS[info]} INFO ${COLORS[reset]}| $1"
}

warn() {
  echo -e "${COLORS[time]}$(date +'%Y-%m-%dT%H:%M:%S%z')${COLORS[reset]} |${COLORS[warning]} WARNING ${COLORS[reset]}| $1"
}

err() {
  echo -e "${COLORS[time]}$(date +'%Y-%m-%dT%H:%M:%S%z')${COLORS[reset]} |${COLORS[error]} ERROR ${COLORS[reset]}| $1" >&2
  exit 1
}

validate_required_commands() {
  local required=("git" "find" "cp" "ln")
  for cmd in "${required[@]}"; do
    if ! command -v "$cmd" &>/dev/null; then
      err "Required command '$cmd' is missing. Please install it and try again."
    fi
  done
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
  if [[ ! -f "${file}" ]]; then
    err "JSON file '${file}' not found."
  fi
  while IFS= read -r line; do
    json_oneline+="${line}"
  done <"${file}"
  JSON_parse_array
}

check_module_exists() {
  local module_name=$1
  [[ -n "${modules["$module_name.source"]}" ]] && return 0 || return 1
}

install_cmd() {
  shift
  local arguments=("${@}")
  local module_url module_name

  for ((i = 0; i < ${#arguments[@]}; i++)); do
    case "${arguments[i]}" in
    --global | -g)
      mode="global"
      if [[ ! -d "${HOME}/${bmd_root}" ]]; then
        err "Global scope is not initialized. Run 'bmd init --global' first."
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
      fi
      ;;
    esac
  done

  if [[ -z "$mode" ]]; then
    mode="local"
    json_file="${PWD}/${bmd_root}/bmd.json"
  fi

  if [[ ! -f "$json_file" ]]; then
    err "Configuration file '$json_file' not found. Please initialize BMD first."
  fi

  JSON_parse "$json_file"
  if check_module_exists "$module_name"; then
    err "Module '$module_name' is already installed."
  fi

  install_module "$module_url" "$module_name"
}

install_module() {
  local module_url=$1
  local module_name=$2
  local module_version=${3:-v1.0.0}

  validate_required_commands

  local module_dir="${BMD_DIR:-$PWD}/.bmd/$module_name"
  local version_dir="${module_dir}/${module_version}"

  modules["$module_name.source"]="$module_url"
  modules["$module_name.version"]="$module_version"
  modules["$module_name.path"]="$version_dir"

  mkdir -p "$version_dir"

  local temp_dir
  temp_dir=$(mktemp -d)

  git clone --depth 1 "$module_url" "$temp_dir" >/dev/null 2>&1 || {
    err "Failed to clone repository from $module_url."
  }

  local shell_scripts
  shell_scripts=$(find "$temp_dir" -name "*.sh" -type f)
  [[ -z "$shell_scripts" ]] && {
    err "No shell scripts found in repository."
  }

  for script in $shell_scripts; do
    cp "$script" "$version_dir/"
  done

  local module_sh="${version_dir}/module.sh"
  {
    echo "#!/bin/bash"
    echo "for script in \"\$(dirname \"\${BASH_SOURCE[0]}\")\"/*.sh; do"
    echo "  [[ -f \"\$script\" && \"\$script\" != \"\${BASH_SOURCE[0]}\" ]] && source \"\$script\""
    echo "done"
  } >"$module_sh"
  chmod +x "$module_sh"

  ln -snf "$version_dir" "$module_dir/current"

  rm -rf "$temp_dir"

  module_write "$json_file"
  info "Module '$module_name' installed successfully."
}

_help() {
  echo "Usage: bmd [command] [options]"
  echo "Commands:"
  echo "  init       Initialize BMD in the current or global scope."
  echo "  install    Install a module."
  echo "  help       Display help information."
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

remove_cmd() {
  shift
  local arguments=("${@}")
  local module_name

  # Parse arguments
  for ((i = 0; i < ${#arguments[@]}; i++)); do
    case "${arguments[i]}" in
    --global | -g)
      mode="global"
      if [[ ! -d "${HOME}/${bmd_root}" ]]; then
        err "Global scope is not initialized. Run 'bmd init --global' first."
      fi
      json_file="${HOME}/${bmd_root}/bmd.json"
      ;;
    *)
      if [[ -z "$module_name" ]]; then
        module_name="${arguments[i]}"
      else
        err "Unexpected argument: ${arguments[i]}"
      fi
      ;;
    esac
  done

  if [[ -z "$mode" ]]; then
    mode="local"
    json_file="${PWD}/${bmd_root}/bmd.json"
  fi

  if [[ -z "$module_name" ]]; then
    err "Module name is required. Usage: bmd remove [--global] <module_name>"
  fi

  # Ensure the JSON file exists
  if [[ ! -f "$json_file" ]]; then
    err "BMD configuration file '$json_file' not found. Please initialize BMD first."
  fi

  # Parse the JSON file and check for module existence
  JSON_parse "$json_file"
  if ! check_module_exists "$module_name"; then
    err "Module '$module_name' is not installed."
  fi

  # Get module path
  local module_path="${modules["$module_name.path"]}"
  local module_dir
  module_dir=$(dirname "$module_path")

  # Remove the module files
  if [[ -d "$module_dir" ]]; then
    info "Removing module files from $module_dir"
    rm -rf "$module_dir"
  fi

  # Update the JSON configuration
  unset modules["$module_name.source"]
  unset modules["$module_name.version"]
  unset modules["$module_name.path"]

  module_write "$json_file"
  info "Module '$module_name' has been successfully removed."
}

start_bmd() {
  case $1 in
  help | -h | --help)
    _help
    ;;
  init)
    _init "$@"
    ;;
  install | i | inst)
    install_cmd "$@"
    ;;
  remove | rm | uninstall)
    remove_cmd "$@"
    ;;
  *)
    err "Invalid command '$1'."
    ;;
  esac
}

start_bmd "$@"
