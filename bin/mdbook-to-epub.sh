#!/usr/bin/env bash
set -e

GREEN="$(tput setaf 2)"
YELLOW="$(tput setaf 2)"
NC="$(tput sgr0)"

if [[ "$#" == 0 ]]; then
  echo "${GREEN}Usage${NC}: $0 [doc]..."
  echo "All converted mdbooks will be saved to the current directory"
  exit 0
fi

ensure_installed() {
  local -r tool=$1
  if ! which "${tool}" &>/dev/null; then
    echo -e "Could not find ${GREEN}${tool}${NC} in the PATH:\n$2"
    exit 1
  fi
}

ensure_installed mdbook "
You need to install ${GREEN}mdbook${NC}, which you do by using: ${YELLOW}cargo install mdbook${NC}
If you don't have ${YELLOW}rust${NC} installed, you'll need to install that first."
ensure_installed mdbook-epub "
You need to install ${GREEN}mdbook-epub${NC}, which you do by using: ${YELLOW}cargo install mdbook-epub${NC}
If you don't have ${YELLOW}rust${NC} installed, you'll need to install that first."

# Create a temporary directory
TMP_DIR="$(mktemp -d)"

# Loop over all command line arguments and convert them
for arg in "$@"; do
  if [[ ! -f "${arg}"/book.toml ]]; then
    echo "Could not find book.toml for ${arg}"
    exit 1
  fi
  mdbook_dir="${TMP_DIR}/$(basename "$(mktemp -ud)")"
  mkdir -p "${mdbook_dir}"/{book,docs}
  cp -r "${arg}"/* "${mdbook_dir}"/book/.
  additional_css="$(grep "additional-css" "${mdbook_dir}"/book/book.toml | head -n1)"
  cat <<EOF >> "${mdbook_dir}"/book/book.toml

[output.epub]
${additional_css}
EOF
  mdbook build -d "${mdbook_dir}"/docs "${mdbook_dir}"/book
  cp "${mdbook_dir}"/docs/epub/* .
  echo "${arg}"
done

rm -rf "${TMP_DIR}"
