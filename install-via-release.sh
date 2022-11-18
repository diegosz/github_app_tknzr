#!/bin/bash
#
# This script downloads a binary release of `github_app_tknzr` into the current working directory adding execution bit.
# After that, the binary is moved to /usr/local/bin.
#
# Usage:
#
# Define the environmental variable INSTALL_RELEASE_TOKEN with the installation token and pass the
# desired version number with -v flag. If 'latest' is passed as version, the latest version is
# installed.
#
# For example: env INSTALL_RELEASE_TOKEN="ghs_XXX" bash ./install-via-release.sh -v latest
#
# The INSTALL_RELEASE_TOKEN needs the be generated using a GitHub App with the following
# permissions:
#
# - Repository Contents: Read
# - Repository Metadata: Read
# - Repository Packages: Read
# - Repository Single File: Read Path: install-via-release.sh
#
# https://docs.github.com/en/rest/releases/assets#get-a-release-asset

VERSION=

function usage() {
  echo "usage: $0 -v VERSION" >&2
}

function get_arch() {
  case "$(uname -m)" in
  aarch64 | arm64)
    echo "arm64"
    ;;
  x86_64)
    echo "amd64"
    ;;
  *)
    echo "Currently $(uname -m) isn't supported. PR is welcome." >&2
    exit 1
    ;;
  esac
}

function get_os() {
  case "$(uname -s)" in
  Linux)
    echo linux
    ;;
  Darwin)
    echo darwin
    ;;
  *)
    echo "Currently $(uname -s) isn't supported. PR is welcome." >&2
    exit 1
    ;;
  esac
}

while getopts hv: OPT; do
  case $OPT in
  v)
    VERSION=$OPTARG
    ;;
  * | h)
    usage
    exit 1
    ;;
  esac
done

if [ -z "${VERSION}" ]; then
  echo "Please specify VERSION via -v" >&2
  echo
  usage
  exit 1
fi

BASE_URL="https://github.com/diegosz/github_app_tknzr/releases/download/${VERSION}"
URL="${BASE_URL}/github_app_tknzr_${VERSION}_$(get_os)_$(get_arch).tar.gz"

shift $((OPTIND - 1))

DIR=$(mktemp -d)
trap "rm -rf '${DIR}'" EXIT 1 2 3 15

pushd $DIR > /dev/null
echo "Downloading ${URL} into ${DIR}" >&2
  curl --fail -sSL -O "${URL}"
  if [ $? -ne 0 ]; then
    echo "Unable to download via Github Releases" >&2
    exit 1
  fi
popd > /dev/null

FN="$(basename ${URL})"
tar xvf "${DIR}/${FN}" github_app_tknzr || exit 1

