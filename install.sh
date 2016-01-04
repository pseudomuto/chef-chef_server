#!/bin/bash
set -euo pipefail
IFS=$'\n\t'
set +v

RED=`tput setaf 1`
GREEN=`tput setaf 2`
RESET=`tput sgr0`

function echo_error() {
  echo "${RED}$1${RESET}"
}

function echo_status() {
  echo "${GREEN}$1${RESET}"
}

if [[ $(/usr/bin/id -u) -ne 0 ]]; then
  echo_error "This script must be run as root"
  exit 1
fi

function install_apt_packages() {
  echo_status "Updating apt..."
  apt-get update

  echo_status "Installing required packages..."
  apt-get install -y curl wget
}

function install_chef() {
  echo_status "Installing chef..."
  curl -L https://www.chef.io/chef/install.sh | bash
  mkdir -p /var/chef/cache /var/chef/cookbooks
}

function download_and_untar_cookbook() {
  echo_status "Downloading cookbook from $1..."
  wget -qO- "$1" | tar xvzC /var/chef/cookbooks
}

function download_cookbooks() {
  for dep in chef-server chef-ingredient yum-chef yum apt-chef apt packagecloud hostsfile; do
    download_and_untar_cookbook "https://supermarket.chef.io/cookbooks/${dep}/download"
  done

  download_and_untar_cookbook "https://github.com/sweeperio/chef-chef_server/tarball/master"
  rm -rf /var/chef/cookbooks/chef_server
  mv /var/chef/cookbooks/sweeperio-chef-chef_server* /var/chef/cookbooks/chef_server
}

function welcome() {
  if [ ! -f /tmp/chef-setup/data.yml ]; then
    echo_error "File '/tmp/chef-setup/data.yml' was not found."
    echo_error "Script execution cancelled. No actions were taken."
    exit 1
  fi

  echo_status "**************************************************"
  echo_status " Let's Install and Setup a Chef Server!           "
  echo_status "**************************************************"
  echo
  echo "In order to run this script, you need to have /tmp/chef-setup/data.yml"
  echo "correctly configured."
  echo

  read -p "Are you ready to begin? (y/N): " choice
  if [[ ! $choice =~ ^[Yy]$ ]]; then
    echo_error "Script execution cancelled. No actions taken."
    exit 1
  fi
  echo
}

function setup_chef_server() {
  echo_status "Creating your chef server..."
  chef-solo -o "recipe[chef_server]"
}

# "main" function
welcome
install_apt_packages
install_chef
download_cookbooks
setup_chef_server

echo_status "All done!"
echo_status "Grab your files from /tmp/chef-setup"
