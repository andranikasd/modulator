#!/bin/bash

#####################################
# Clone modules from Git Repositories
# Globals:
#   modules_directory: The directory where we are putting installed modules
# Arguments:
# Returns: 
#
#####################################
set -e

script_current_dir=$(dirname "${BASH_SOURCE[0]}")
modules_directory=".modules"

source "${script_current_dir}"/utils/logger.sh

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


is_module_installed dotfiles
# clone_git_repo "https://github.com/andranikasd/dotfiles" dotfiles
