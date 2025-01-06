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

        cd "${EXTRACTED_FOLDER_PATH}"
        git clone "git@github.com:${PROJECT}.git" ./clams-git-upstream
        cd clams-git-upstream
        git checkout "${VERSION}"
        git checkout -b "work_${VERSION}"
        git am ../../patches/0001-Upgrade-boost-to-fix-github-boostorg-build-664.patch
        git am ../../patches/0002-modified-packages-openssl.mk.patch
        git am ../../patches/0003-toolset-clang.patch
        git am ../../patches/0004-Add-ARM64-support.patch
        git am ../../patches/zlib-is-sneaky.patch
        git mv depends/ contrib/ && git commit -m 'git mv depends/ contrib/'
        # https://git.wownero.com/asymptotically/wownero/commit/7c7ccbd2a5379b18aeee1e8fec3c17edc43fc57e
        git am ../../patches/fix-broken-links-for-ds_store-mac_alias.7c7ccbd2a5.patch
        mv contrib/depends ..
        cd ..
        rm -rf clams-git-upstream
        cd ..
fi

if [ ! -d "venv" ]; then
    pyenv install -s
    python3 -m venv venv
    bash -c 'source venv/bin/activate && pip install setuptools==75.6.0'
fi

NPROC=$(sysctl -n hw.physicalcpu)
SDKROOT=$(xcrun --sdk macosx --show-sdk-path)
HOST="arm-apple-darwin$(uname -r)"
PREFIX="$(cd "${EXTRACTED_FOLDER_PATH}" && pwd)/depends/${HOST}"
BOOST_ROOT="${PREFIX}"
BOOST_LIBRARYDIR="${BOOST_ROOT}/lib"

bash <(cat <<SUBSCRIPT
source venv/bin/activate
set -euxo pipefail

export BOOST_ROOT=${BOOST_ROOT}
export BOOST_LIBRARYDIR=${BOOST_LIBRARYDIR}
export SDKROOT=${SDKROOT}
export LDFLAGS="-L${BOOST_LIBRARYDIR}"
export CPPFLAGS="-I${BOOST_ROOT}/include"
cd ${EXTRACTED_FOLDER_PATH}

./autogen.sh

cd depends
make -j${NPROC} NO_QT=true NO_WALLET=true HOST=${HOST}
cd ..

./configure \\
    --prefix=${PREFIX} \\
    --disable-wallet \\
    --disable-tests \\
    --disable-gui-tests \\
    --disable-bench \\
    --enable-hardening \\
    --with-boost=${BOOST_ROOT} \\
    --with-boost-libdir=${BOOST_LIBRARYDIR} \\
    --with-openssl=${PREFIX} \\
    BOOST_SYSTEM_LIB=boost_system-mt-s-a64 \\
    BOOST_FILESYSTEM_LIB=boost_filesystem-mt-s-a64 \\
    BOOST_PROGRAM_OPTIONS_LIB=boost_program_options-mt-s-a64 \\
    BOOST_THREAD_LIB=boost_thread-mt-s-a64 \\
    BOOST_CHRONO_LIB=boost_chrono-mt-s-a64 \\
    CXXFLAGS="-Wno-error=enum-constexpr-conversion -DBOOST_THREAD_USES_CHRONO -DBOOST_THREAD_PROVIDES_FUTURE_CONTINUATION" \\
    CPPFLAGS="-I${PREFIX}/include -DBOOST_NO_CXX11_SCOPED_ENUMS -DBOOST_THREAD_VERSION=4" \\
    PKG_CONFIG_PATH="${PREFIX}/lib/pkgconfig" \\
;
SUBSCRIPT
)

cd "${EXTRACTED_FOLDER_PATH}"
make -j${NPROC}
