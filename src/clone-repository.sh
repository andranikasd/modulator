#!/bin/bash
set -e
#####################################
# Clone modules from Git Repositories
# Globals:
#   modules_directory: The directory where we are putting installed modules
# Arguments:
# Returns: 
#
#####################################

source ./utils/logger.sh

modules_directory=".modules"

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
  mkdir -p .modules

  if ! output=$(git clone "${1}" "${modules_directory}/${2}" 2>&1); then
    err_code=$?
    err "Something went wrong with git clone. Exiting with code ${err_code}. ${output}"
    exit ${err_code}
  fi
 
}


clone_git_repo "https://github.com/andranikasd/dotfiles" dotfiles
