#!/bin/bash
#/opt/clams/getclams.sh
set -euxo pipefail

PROJECT="nochowderforyou/clams"
VERSION="v2.1.0-beta.1"
FILENAME="clam-2.1.0.tar.gz"
EXTRACTED_FOLDER_PATH="clam-2.1.0"
SHA512SUM="f3f998dc685210b180ca3f265cd0ea26190d845b3dab9a27cff7fa92c765019c57f89e73be4258e93c4dc295839e5506835e663e7805cc76d27be09e57df3f0d"

URL="https://github.com/${PROJECT}/releases/download/${VERSION}/${FILENAME}"
CALCSUM="${SHA512SUM}  ${FILENAME}"


if [ ! -f "${FILENAME}" ]; then
        wget "${URL}"
fi

sha512sum -c <(echo "${CALCSUM}")

if [ ! -d "${EXTRACTED_FOLDER_PATH}" ]; then
        tar xzvf "${FILENAME}"
fi
