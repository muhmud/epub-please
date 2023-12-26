#!/usr/bin/env bash
set -e

GREEN="$(tput setaf 2)"
YELLOW="$(tput setaf 2)"
NC="$(tput sgr0)"

if [[ "$#" == 0 ]]; then
  echo "${GREEN}Usage${NC}: $0 [doc]..."
  echo "All converted markdown files will be saved to the current directory"
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
  markdown_file="$(basename "${arg}")"
  markdown=${markdown_file%%.*}
  markdown_tmp_dir="${TMP_DIR}/$(basename "$(mktemp -ud)")"
  mkdir -p "${markdown_tmp_dir}"/book/src
  cp "${arg}" "${markdown_tmp_dir}"/book/src/book.md
  cat <<EOF > "${markdown_tmp_dir}"/book/src/SUMMARY.md
# Summary

["${markdown}"](book.md)
EOF
  cat <<EOF > "${markdown_tmp_dir}"/book/book.toml
[book]
title = "${markdown}"

[output.epub]
EOF
  mdbook build -d "${markdown_tmp_dir}"/docs "${markdown_tmp_dir}"/book
  cp "${markdown_tmp_dir}"/docs/* .
  echo "${arg}"
done

rm -rf "${TMP_DIR}"
