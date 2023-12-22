#!/usr/bin/env bash
set -e

GREEN="$(tput setaf 2)"
YELLOW="$(tput setaf 2)"
NC="$(tput sgr0)"

if [[ "$#" == 0 ]]; then
  echo "${GREEN}Usage${NC}: $0 [man]..."
  echo "All converted man pages will be saved to the current directory"
  exit 0
fi

ensure_installed() {
  local -r tool=$1
  if ! which "${tool}" &>/dev/null; then
    echo -e "Could not find ${GREEN}${tool}${NC} in the PATH:\n$2"
    exit 1
  fi
}

# Ensure the required tools are installed
ensure_installed manbook "
You going to need to install ${GREEN}manbook${NC}, which you do by using: ${YELLOW}gem install manbook${NC}
More info can be found here: ${YELLOW}https://github.com/nerab/manbook${NC}"
ensure_installed pandoc "\nYou need ${GREEN}pandoc${NC}, best to try your package manager"

# Create a temporary directory
TMP_DIR="$(mktemp -d)"

# Loop over all command line arguments and convert them
for arg in "$@"; do
  man_page_file="$(basename "${arg}")"
  man_page=${man_page_file%%.*}
  man_tmp_dir="${TMP_DIR}/$(basename "$(mktemp -ud)")"
  mkdir "${man_tmp_dir}"
  manbook "${arg}" --output "${man_tmp_dir}"
  pandoc --metadata title="${man_page}" "${man_tmp_dir}"/*.html -o ./"${man_page}".epub
  echo "${arg}"
done

rm -rf "${TMP_DIR}"
