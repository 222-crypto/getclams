#!/bin/bash
set -euxo pipefail

PROJECT="nochowderforyou/clams"
VERSION="v2.1.0-beta.1"
FILENAME="clam-2.1.0-x86_64-linux-gnu.tar.gz"
EXTRACTED_FOLDER_PATH="clam-2.1.0"
SHA512SUM="12db76770923260132b04674e250047f71bf77172c69efe0257c1785f1520bcfde18ea98a521d55afd977886aa039b0ba376410358841b00801e9bc6f2bca9d3"

URL="https://github.com/${PROJECT}/releases/download/${VERSION}/${FILENAME}"
CALCSUM="${SHA512SUM}  ${FILENAME}"


if [ ! -f "${FILENAME}" ]; then
        wget "${URL}"
fi

sha512sum -c <(echo "${CALCSUM}")

if [ ! -d "${EXTRACTED_FOLDER_PATH}" ]; then
        tar xzvf "${FILENAME}"
fi
