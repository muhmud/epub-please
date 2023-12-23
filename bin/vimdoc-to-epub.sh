#!/usr/bin/env bash
set -e

SCRIPT_DIR="$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")"

YELLOW="$(tput setaf 2)"
GREEN="$(tput setaf 2)"
NC="$(tput sgr0)"

if [[ "$#" == 0 ]]; then
  echo "${GREEN}Usage${NC}: $0 [vimdoc]..."
  echo "All converted vimdoc manuals will be saved to the current directory"
  exit 0
fi

ensure_installed() {
  local -r tool=$1
  if ! which "${tool}" &>/dev/null; then
    echo -e "Could not find ${GREEN}${tool}${NC} in the PATH:\n$2"
    exit 1
  fi
}

if [[ -z "${EPUB_PLEASE_TREE_SITTER_VIMDOC}" ]] || [[ ! -d "${EPUB_PLEASE_TREE_SITTER_VIMDOC}" ]]; then
  echo "The ${GREEN}EPUB_PLEASE_TREE_SITTER_VIMDOC${NC} environment variable value is invalid

You need to clone this repo: ${YELLOW}https://github.com/neovim/tree-sitter-vimdoc.git${NC}
Then set the ${GREEN}EPUB_PLEASE_TREE_SITTER_VIMDOC${NC} environment variable to its location"
  exit 1
fi

ensure_installed tree-sitter "\nYou need the ${GREEN}tree-sitter${NC} CLI, best to try your package manager"
ensure_installed saxon "\nYou need ${GREEN}saxon{NC}, best to try your package manager"
ensure_installed pandoc "\nYou need ${GREEN}pandoc${NC}, best to try your package manager"

# Store the current directory
OUTPUT_DIR="${PWD}"

# Enter the tree-sitter-vimdoc directory
cd "${EPUB_PLEASE_TREE_SITTER_VIMDOC}"

# Create a temporary directory
TMP_DIR="$(mktemp -d)"

# Loop over all command line arguments and convert them
for arg in "$@"; do
  vimdoc_file="$(basename "${arg}")"
  vimdoc=${vimdoc_file%%.*}
  vimdoc_tmp_dir="${TMP_DIR}/$(basename "$(mktemp -ud)")"
  mkdir "${vimdoc_tmp_dir}"
  tree-sitter parse -x "${arg}" | sed '$d' > "${vimdoc_tmp_dir}"/"${vimdoc}.xml"
  saxon -s:"${vimdoc_tmp_dir}/${vimdoc}.xml" -xsl:"${SCRIPT_DIR}/vim-md.xslt" -o:"${vimdoc_tmp_dir}/${vimdoc}.md"
  pandoc --metadata title="${vimdoc}" --from markdown-yaml_metadata_block -i "${vimdoc_tmp_dir}/${vimdoc}.md" -o "${OUTPUT_DIR}/${vimdoc}".epub
  echo "${arg}"
done

rm -rf "${TMP_DIR}"
