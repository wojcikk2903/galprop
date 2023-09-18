#!/usr/bin/env bash

# Below are 2 example settings to build for OSX (10.15) or Linux (CentOS 8). Uncomment/modify the variables appropriate for your system -- you need to set these system variables

# User-defined variables -- this example is for OSX using a macports installation for the various tools

#MY_CMAKE=/opt/local/bin/cmake
#MY_AUTOCONF=/opt/local/bin/autoconf
#MY_CC=/opt/local/bin/clang-mp-12
#MY_CXX=/opt/local/bin/clang++-mp-12
#MY_FC=/opt/local/bin/gfortran-mp-11

# User-defined variables -- this example is for CentOS 7 using devtoolset-10 system tools

MY_CMAKE=cmake
MY_AUTOCONF=autoconf
MY_CC=/usr/bin/gcc
MY_CXX=/usr/bin/g++
MY_FC=/usr/bin/gfortran

# Set this to > 1 to use multiple threads during the build process
MY_BUILD_THREAD_NUMBER=8

###----- Alter below if further system customisation is needed -----###

# Additional compiler options. The `-march=native' flag is for gcc. Needs to be commented (or altered) for clang.

MY_CXX_FLAGS="-march=native"
MY_FC_FLAGS="-march=native"

# Install directory

INSTALL_DIRECTORY=$(pwd)

# System type variables

case "$OSTYPE" in
    darwin*)
	MY_OS_BOOST_TOOLSET=clang
	MY_OS_SHAREDLIB_SUFFIX=dylib
	MY_OS_SHAREDLIB_PATH_VAR=DYLD_LIBRARY_PATH
	MY_RC_FILE=.bash_profile
	;; 
    linux*)
	MY_OS_BOOST_TOOLSET=gcc
	MY_OS_SHAREDLIB_SUFFIX=so
	MY_OS_SHAREDLIB_PATH_VAR=LD_LIBRARY_PATH
	MY_RC_FILE=.bashrc
	;;
    *) echo "unknown: $OSTYPE"
       exit
       ;;
esac

# Define colours
RED="\033[0;31m"
GREEN="\033[0;32m"
PC="\033[0;35m"
TC="\033[0;36m"
NC="\033[0m"

# Configuration/build/install logging. Can change to /dev/null for silent.
LOG_DIRECTORY=${INSTALL_DIRECTORY}/log

function command_exists() {
    type "$1" &>/dev/null
}

function delete_build() {
    for DIRS in "lib/cfitsio-4.0.0" "lib/build/cfitsio-4.0.0" "lib/CCfits-2.6" "lib/build/CCfits-2.6" "lib/Healpix_3.50" "lib/build/Healpix_3.50" "lib/build/wcslib-7.7" "lib/wcslib-7.7" "lib/build/xerces-c-3.2.3" "lib/xerces-c-3.2.3" "lib/gsl-2.7" "lib/build/gsl-2.7" "lib/build/galtoolslib-1.1.1006" "lib/galtoolslib-1.1.1006-Source" "lib/build/eigen-3.4.0" "lib/eigen-3.4.0" "lib/build/CLHEP-2.4.4.2" "lib/2.4.4.2" "lib/build/boost_1_76_0" "lib/boost_1_76_0" "lib/build/Minuit2" "lib/build" "build" "GALPROP-57.0.3032"; do
	rm -rf ${DIRS}
    done
}

function clean_up() {

    for DIRS in "lib/cfitsio-4.0.0" "lib/CCfits-2.6" "lib/Healpix_3.50" "lib/wcslib-7.7" "lib/xerces-c-3.2.3" "lib/gsl-2.7" "lib/galtoolslib-1.1.1006-Source" "lib/eigen-3.4.0" "lib/2.4.4.2" "lib/boost_1_76_0" "lib/Minuit2"; do
	rm -rf ${DIRS}
    done

}

function initial_check() {
    if ! command_exists ${MY_CC}; then
        echo -e "--- ${RED}Error:${NC} C compiler not found. Please install C compiler!"
        exit
    fi
    if ! command_exists ${MY_CXX}; then
        echo -e "--- ${RED}Error:${NC} C++ compiler not found. Please install C++ compiler!"
        exit
    fi
    if ! command_exists ${MY_FC}; then
        echo -e "--- ${RED}Error:${NC} Fortran compiler not found. Please install Fortran compiler!"
        exit
    fi
    if ! command_exists ${MY_CMAKE}; then
        echo -e "--- ${RED}Error:${NC} cmake not found. Please install cmake!"
        exit
    fi
    if ! command_exists ${MY_AUTOCONF}; then
        echo -e "--- ${RED}Error:${NC} autoconf not found. Please install autotools!"
        exit
    fi
    if [ ! -d "lib" ]; then
        echo -e "--- ${RED}Error:${NC} support library directory not found (incomplete GALPROP package?)"
        exit
    fi
    if [ ! -d "source" ]; then
        echo -e "--- ${RED}Error:${NC} source directory not found (incomplete GALPROP package?)"
        exit
    fi
}

function install_support_libraries() {

    if ! command_exists ${MY_CC}; then
        echo -e "--- ${RED}Error:${NC} C compiler not found. Please install C compiler!"
        exit
    fi
    if ! command_exists ${MY_CXX}; then
        echo -e "--- ${RED}Error:${NC} C++ compiler not found. Please install C++ compiler!"
        exit
    fi
    if ! command_exists ${MY_FC}; then
        echo -e "--- ${RED}Error:${NC} Fortran compiler not found. Please install Fortran compiler!"
        exit
    fi
    
    # Check for necessary programs 1
    if ! command_exists ${MY_CMAKE}; then
        echo -e "--- ${RED}Error:${NC} cmake not found."
        exit
    fi
 
    # Check for necessary programs 2
    if ! command_exists ${MY_AUTOCONF}; then
        echo -e "--- ${RED}Error:${NC} autoconf not found."
        exit
    fi
    
    echo -e "${PC}--- Install required libraries ---${NC}"
    if [ ! -d "lib" ]; then
        echo -e "--- ${RED}Error:${NC} lib directory not found (incomplete package?)"
        exit
    fi
    cd "lib"

    echo -e "Install cfitsio"
    if [ ! -f "cfitsio-4.0.0/build/CMakeCache.txt" ] && [ -d "cfitsio-4.0.0/" ]; then
        rm -r "cfitsio-4.0.0/"
    fi
    if [ ! -d "cfitsio-4.0.0" ]; then
        tar -xf cfitsio-4.0.0.tar.gz
    fi
    cd "cfitsio-4.0.0"
    echo -ne "- Configure cfitsio ... "\\r
    if [ ! -d "build" ]; then
        mkdir "build"
    fi
    cd "build"
    ${MY_CMAKE} .. -DCMAKE_INSTALL_PREFIX=${INSTALL_DIRECTORY}/lib/build/cfitsio-4.0.0 -DCMAKE_C_COMPILER=${MY_CC} -DUSE_CURL=OFF -DCMAKE_BUILD_TYPE=$2 -DBUILD_SHARED_LIBS=$1 >${LOG_DIRECTORY}/cfitsio-4.0.0-config-log 2>&1 && 
    echo -e "- Configure cfitsio [${GREEN}done${NC}]" ||
    {
        echo -e "- Configure cfitsio [${RED}Error${NC}]"
        exit
    }
    echo -ne "- Compile cfitsio ... "\\r
    make VERBOSE=1 -j${MY_BUILD_THREAD_NUMBER} >${LOG_DIRECTORY}/cfitsio-4.0.0-build-log 2>&1 &&
    echo -e "- Compile cfitsio [${GREEN}done${NC}]" ||
    {
        echo -e "- Compile cfitsio [${RED}Error${NC}]"
        exit
    }
    make install >${LOG_DIRECTORY}/cfitsio-4.0.0-install-log 2>&1 &&
    echo -e "- Local install of cfitsio [${GREEN}done${NC}]" ||
    {
        echo -e "- Local install cfitsio [${RED}Error${NC}]"
        exit
    } 
    cd ${INSTALL_DIRECTORY}/lib

    echo -e "Install wcslib"
    if [ ! -d "wcslib-7.7" ]; then
        tar -xf wcslib-7.7.tar.bz2
    fi
    cd "wcslib-7.7"
    echo -ne "- Configure wcslib ... "\\r
    ./configure CC=${MY_CC} F77=${MY_FC} --prefix=${INSTALL_DIRECTORY}/lib/build/wcslib-7.7 CFLAGS="-fPIC -g -O2" --disable-flex --with-cfitsiolib=${INSTALL_DIRECTORY}/lib/build/cfitsio-4.0.0/lib --with-cfitsioinc=${INSTALL_DIRECTORY}/lib/build/cfitsio-4.0.0/include >${LOG_DIRECTORY}/wcslib-7.7-config-log 2>&1 &&
    echo -e "- Configure wcslib [${GREEN}done${NC}]" ||
    {
        echo -e "- Configure wcslib [${RED}Error${NC}]"
        exit
    }
    echo -ne "- Compile wcslib ... "\\r
    make -j${MY_BUILD_THREAD_NUMBER} >${LOG_DIRECTORY}/wcslib-7.7-build-log 2>&1 &&
    echo -e "- Compile wcslib [${GREEN}done${NC}]" ||
    {
        echo -e "- Compile wcslib [${RED}Error${NC}]"
        exit
    }
    make install >${LOG_DIRECTORY}/wcslib-7.7-install-log 2>&1 &&
    echo -e "- Local install of wcslib [${GREEN}done${NC}]" ||
    {
        echo -e "- Local install wcslib [${RED}Error${NC}]"
        exit
    } 
    cd ${INSTALL_DIRECTORY}/lib

    echo -e "Install CCfits"
    if [ ! -f "CCfits-2.6/build/CMakeCache.txt" ] && [ -d "CCfits-2.6/" ]; then
        rm -r "CCfits-2.6/"
    fi
    if [ ! -d "CCfits-2.6" ]; then
        tar -xf CCfits-2.6.tar.gz
    fi
    cd "CCfits-2.6"
    echo -ne "- Configure CCfits ... "\\r
    if [ ! -d "build" ]; then
        mkdir "build"
    fi
    cd "build"
    ${MY_CMAKE} .. -DCMAKE_INSTALL_PREFIX=${INSTALL_DIRECTORY}/lib/build/CCfits-2.6 -DCMAKE_CXX_COMPILER=${MY_CXX} -DCMAKE_BUILD_TYPE=$2 -DBUILD_SHARED_LIBS=$1 -DCMAKE_PREFIX_PATH="${INSTALL_DIRECTORY}/lib/build/cfitsio-4.0.0" >${LOG_DIRECTORY}/CCfits-2.6-config-log 2>&1 &&
    echo -e "- Configure CCfits [${GREEN}done${NC}]" ||
    {
        echo -e "- Configure CCfits [${RED}Error${NC}]"
        exit
    }
    echo -ne "- Compile CCfits ... "\\r
    make -j${MY_BUILD_THREAD_NUMBER} >${LOG_DIRECTORY}/CCfits-2.6-build-log 2>&1 &&
    echo -e "- Compile CCfits [${GREEN}done${NC}]" ||
    {
        echo -e "- Compile CCfits [${RED}Error${NC}]"
        exit
    }
    make install >${LOG_DIRECTORY}/CCfits-2.6-install-log 2>&1 &&
    echo -e "- Local install of CCfits [${GREEN}done${NC}]" ||
    {
        echo -e "- Local install CCfits [${RED}Error${NC}]"
        exit
    } 
    cd ${INSTALL_DIRECTORY}/lib

    echo -e "Install Healpix"
    if [ ! -d "Healpix_3.50" ]; then
        tar -xf Healpix_3.50.tar.gz
    fi
    cd "Healpix_3.50"
    echo -ne "- Configure Healpix ... "\\r
    cd "src/cxx"
    ${MY_AUTOCONF} &> /dev/null 2>&1
    ./configure CC=${MY_CC} CXX=${MY_CXX} --with-libcfitsio-lib=${INSTALL_DIRECTORY}/lib/build/cfitsio-4.0.0/lib CPPFLAGS="-fPIC" --with-libcfitsio-include=${INSTALL_DIRECTORY}/lib/build/cfitsio-4.0.0/include >${LOG_DIRECTORY}/Healpix_3.50-config-log 2>&1 &&
    echo -e "- Configure Healpix [${GREEN}done${NC}]" ||
    {
        echo -e "- Configure Healpix [${RED}Error${NC}]"
        exit
    }
    echo -ne "- Compile Healpix ... "\\r
    make -j${MY_BUILD_THREAD_NUMBER} >${LOG_DIRECTORY}/Healpix_3.50-build-log 2>&1 &&
    echo -e "- Compile Healpix [${GREEN}done${NC}]" ||
    {
        echo -e "- Compile Healpix [${RED}Error${NC}]"
        exit
    }
    cd ${INSTALL_DIRECTORY}/lib/build
    if [ ! -d "Healpix_3.50" ]; then
        mkdir Healpix_3.50
    fi
    cd Healpix_3.50
    if [ -d "auto" ]; then
        rm -r auto
    fi
    cd ${INSTALL_DIRECTORY}/lib/Healpix_3.50/src/cxx
    mv auto ${INSTALL_DIRECTORY}/lib/build/Healpix_3.50/
    echo -e "- Local install of Healpix [${GREEN}done${NC}]" ||
    {
        echo -e "- Local install Healpix [${RED}Error${NC}]"
        exit
    } 
    cd ${INSTALL_DIRECTORY}/lib

    echo -e "Install xerces-c"
    if [ ! -f "xerces-c-3.2.3/build/CMakeCache.txt" ] && [ -d "xerces-c-3.2.3/" ]; then
        rm -r "xerces-c-3.2.3/"
    fi
    if [ ! -d "xerces-c-3.2.3" ]; then
        tar -xf xerces-c-3.2.3.tar.bz2
    fi
    cd "xerces-c-3.2.3"
    echo -ne "- Configure xerces-c ... "\\r
    if [ ! -d "build" ]; then
        mkdir "build"
    fi
    cd "build"
    ${MY_CMAKE} .. -G "Unix Makefiles" -DCMAKE_INSTALL_PREFIX=${INSTALL_DIRECTORY}/lib/build/xerces-c-3.2.3 -DCMAKE_C_COMPILER=${MY_CC} -DCMAKE_CXX_COMPILER=${MY_CXX} -DBUILD_SHARED_LIBS=$1 -DCMAKE_BUILD_TYPE=$2 >${LOG_DIRECTORY}/xerces-c-3.2.3-config-log 2>&1 &&
    echo -e "- Configure xerces-c [${GREEN}done${NC}]" ||
    {
        echo -e "- Configure xerces-c [${RED}Error${NC}]"
        exit
    }
    echo -ne "- Compile xerces-c ... "\\r
    make -j${MY_BUILD_THREAD_NUMBER} >${LOG_DIRECTORY}/xerces-c-3.2.3-build-log 2>&1 &&
    echo -e "- Compile xerces-c [${GREEN}done${NC}]" ||
    {
        echo -e "- Compile xerces-c [${RED}Error${NC}]"
        exit
    }
    make install >${LOG_DIRECTORY}/xerces-c-3.2.3-install-log 2>&1 &&
    echo -e "- Local install of xerces-c [${GREEN}done${NC}]" ||
    {
        echo -e "- Local install xerces-c [${RED}Error${NC}]"
        exit
    } 
    cd ${INSTALL_DIRECTORY}/lib

    echo -e "Install gsl"
    if [ ! -d "gsl-2.7" ]; then
        tar -xf gsl-2.7.tar.gz
    fi
    cd "gsl-2.7"
    echo -ne "- Configure gsl ... "\\r
    ./configure CC=${MY_CC} FC=${MY_FC} --prefix=${INSTALL_DIRECTORY}/lib/build/gsl-2.7 >${LOG_DIRECTORY}/gsl-2.7-config-log 2>&1 &&
    echo -e "- Configure gsl [${GREEN}done${NC}]" ||
    {
        echo -e "- Configure gsl [${RED}Error${NC}]"
        exit
    }
    echo -ne "- Compile gsl ... "\\r
    make -j${MY_BUILD_THREAD_NUMBER} >${LOG_DIRECTORY}/gsl-2.7-build-log 2>&1 &&
    echo -e "- Compile gsl [${GREEN}done${NC}]" ||
    {
        echo -e "- Compile gsl [${RED}Error${NC}]"
        exit
    }
    make install >${LOG_DIRECTORY}/gsl-2.7-install-log 2>&1 &&
    echo -e "- Local install of gsl [${GREEN}done${NC}]" ||
    {
        echo -e "- Local install gsl [${RED}Error${NC}]"
        exit
    } 
    cd ${INSTALL_DIRECTORY}/lib

    echo -e "Install boost"
    if [ ! -d "boost_1_76_0" ]; then
        tar -xf boost_1_76_0.tar.bz2
    fi
    cd "boost_1_76_0"
    if [ ! -d "build" ]; then
        mkdir "build"
    fi
    echo -ne "- Configure boost ... "\\r
    cd "tools/build"
    ./bootstrap.sh --cxx=${MY_CXX} -std=c++11 >${LOG_DIRECTORY}/boost_1_76_0-install-bootstrap-log 2>&1
    ./b2 install --prefix=${INSTALL_DIRECTORY}/lib/boost_1_76_0/build >${LOG_DIRECTORY}/boost_1_76_0-config-log 2>&1 
    cd ${INSTALL_DIRECTORY}/lib/boost_1_76_0
    echo -ne "- Compile and install boost ... "\\r
    build/bin/b2 install --prefix=${INSTALL_DIRECTORY}/lib/build/boost_1_76_0 --with-system --with-filesystem --with-serialization --with-math toolset=${MY_OS_BOOST_TOOLSET} variant=release runtime-link=shared threading=multi stage >${LOG_DIRECTORY}/boost_1_76_0-install-log 2>&1 &&
    echo -e "- Local install of boost [${GREEN}done${NC}]" ||
    {
        echo -e "- Local install boost [${RED}Error${NC}]"
        exit
    } 
    cd ${INSTALL_DIRECTORY}/lib

    echo -e "Install CLHEP"
    if [ ! -f "2.4.4.2/build/CMakeCache.txt" ] && [ -d "2.4.4.2/" ]; then
        rm -r "2.4.4.2/"
    fi
    if [ ! -d "2.4.4.2" ]; then
        tar -xf clhep-2.4.4.2.tgz
    fi
    cd "2.4.4.2"
    echo -ne "- Configure CLHEP ... "\\r
    if [ ! -d "build" ]; then
        mkdir "build"
    fi
    cd "build"
    ${MY_CMAKE} ../CLHEP -DCMAKE_INSTALL_PREFIX=${INSTALL_DIRECTORY}/lib/build/CLHEP-2.4.4.2 -DCMAKE_CXX_COMPILER=${MY_CXX} -DCMAKE_C_COMPILER=${MY_CC} -DBUILD_SHARED_LIBS=$1 -DCMAKE_BUILD_TYPE=$2 >${LOG_DIRECTORY}/CLHEP-2.4.4.2-config-log 2>&1 &&
    echo -e "- Configure CLHEP [${GREEN}done${NC}]" ||
    {
        echo -e "- Configure CLHEP [${RED}Error${NC}]"
        exit
    }
    echo -ne "- Compile CLHEP ... "\\r
    make -j${MY_BUILD_THREAD_NUMBER} >${LOG_DIRECTORY}/CLHEP-2.4.4.2-build-log 2>&1 &&
    echo -e "- Compile CLHEP [${GREEN}done${NC}]" ||
    {
        echo -e "- Compile CLHEP [${RED}Error${NC}]"
        exit
    }
    make install >${LOG_DIRECTORY}/CLHEP-2.4.4.2-install-log 2>&1 &&
    echo -e "- Local install of CLHEP [${GREEN}done${NC}]" ||
    {
        echo -e "- Local install CLHEP [${RED}Error${NC}]"
        exit
    } 
    cd ${INSTALL_DIRECTORY}/lib

    echo -e "Install galtoolslib"
    if [ ! -f "galtoolslib-1.1.1006-Source/build/CMakeCache.txt" ] && [ -d "galtoolslib-1.1.1006-Source/" ]; then
        rm -r "galtoolslib-1.1.1006-Source/"
    fi
    if [ ! -d "galtoolslib-1.1.1006-Source" ]; then
        tar -xf galtoolslib-1.1.1006-Source.tar.gz
    fi
    cd "galtoolslib-1.1.1006-Source"
    echo -ne "- Configure galtoolslib ... "\\r
    if [ ! -d "build" ]; then
        mkdir "build"
    fi

    cd "build"
    # Xerces sets up different default build targets based on OS. Need to substitute correct path for the `lib' directory -- it can be `lib64' or `lib'
    if [ -d "${INSTALL_DIRECTORY}/lib/build/xerces-c-3.2.3/lib64" ]; then
	${MY_CMAKE} .. -DCMAKE_INSTALL_PREFIX=${INSTALL_DIRECTORY}/lib/build/galtoolslib-1.1.1006 -DCMAKE_CXX_COMPILER=${MY_CXX} -DCMAKE_C_COMPILER=${MY_CC} -DCMAKE_Fortran_COMPILER=${MY_FC} -DCMAKE_BUILD_TYPE=$2 -DBUILD_SHARED_LIBS=$1 -DCMAKE_PREFIX_PATH="${INSTALL_DIRECTORY}/lib/build/CLHEP-2.4.4.2;${INSTALL_DIRECTORY}/lib/build/boost_1_76_0/" -DCfitsio_INC=${INSTALL_DIRECTORY}/lib/build/cfitsio-4.0.0/include -DCfitsio_LIB=${INSTALL_DIRECTORY}/lib/build/cfitsio-4.0.0/lib/ -DCCfits_PREFIX=${INSTALL_DIRECTORY}/lib/build/CCfits-2.6 -DWCS_PREFIX=${INSTALL_DIRECTORY}/lib/build/wcslib-7.7 -DHEALPix_PREFIX=${INSTALL_DIRECTORY}/lib/build/Healpix_3.50/auto -DGSL_CONFIG=${INSTALL_DIRECTORY}/lib/build/gsl-2.7/bin/gsl-config -DXERCESC_INCLUDE=${INSTALL_DIRECTORY}/lib/build/xerces-c-3.2.3/include -DXERCESC_LIBRARY=${INSTALL_DIRECTORY}/lib/build/xerces-c-3.2.3/lib64/libxerces-c.${MY_OS_SHAREDLIB_SUFFIX} >${LOG_DIRECTORY}/galtoolslib-config-log 2>&1
    else
	${MY_CMAKE} .. -DCMAKE_INSTALL_PREFIX=${INSTALL_DIRECTORY}/lib/build/galtoolslib-1.1.1006 -DCMAKE_CXX_COMPILER=${MY_CXX} -DCMAKE_C_COMPILER=${MY_CC} -DCMAKE_Fortran_COMPILER=${MY_FC} -DCMAKE_BUILD_TYPE=$2 -DBUILD_SHARED_LIBS=$1 -DCMAKE_PREFIX_PATH="${INSTALL_DIRECTORY}/lib/build/CLHEP-2.4.4.2;${INSTALL_DIRECTORY}/lib/build/boost_1_76_0/" -DCfitsio_INC=${INSTALL_DIRECTORY}/lib/build/cfitsio-4.0.0/include -DCfitsio_LIB=${INSTALL_DIRECTORY}/lib/build/cfitsio-4.0.0/lib/ -DCCfits_PREFIX=${INSTALL_DIRECTORY}/lib/build/CCfits-2.6 -DWCS_PREFIX=${INSTALL_DIRECTORY}/lib/build/wcslib-7.7 -DHEALPix_PREFIX=${INSTALL_DIRECTORY}/lib/build/Healpix_3.50/auto -DGSL_CONFIG=${INSTALL_DIRECTORY}/lib/build/gsl-2.7/bin/gsl-config -DXERCESC_INCLUDE=${INSTALL_DIRECTORY}/lib/build/xerces-c-3.2.3/include -DXERCESC_LIBRARY=${INSTALL_DIRECTORY}/lib/build/xerces-c-3.2.3/lib/libxerces-c.${MY_OS_SHAREDLIB_SUFFIX} >${LOG_DIRECTORY}/galtoolslib-config-log 2>&1
    fi &&
    echo -e "- Configure galtoolslib [${GREEN}done${NC}]" ||
    {
        echo -e "- Configure galtoolslib [${RED}Error${NC}]"
        exit
    }
    echo -ne "- Compile galtoolslib ... "\\r
    make VERBOSE=1 -j${MY_BUILD_THREAD_NUMBER} >${LOG_DIRECTORY}/galtoolslib-build-log 2>&1 &&
    echo -e "- Compile galtoolslib [${GREEN}done${NC}]" ||
    {
        echo -e "- Compile galtoolslib [${RED}Error${NC}]"
        exit
    }
    make install >${LOG_DIRECTORY}/galtoolslib-install-log 2>&1 &&
    echo -e "- Local install of galtoolslib [${GREEN}done${NC}]" ||
    {
        echo -e "- Local install galtoolslib [${RED}Error${NC}]"
        exit
    } 
    cd ${INSTALL_DIRECTORY}/lib

    echo -e "Install eigen3"
    if [ ! -f "eigen-3.4.0/build/CMakeCache.txt" ] && [ -d "eigen-3.4.0/" ]; then
        rm -r "eigen-3.4.0/"
    fi
    if [ ! -d "eigen-3.4.0" ]; then
        tar -xf eigen-3.4.0.tar.gz
    fi
    cd "eigen-3.4.0"
    echo -ne "- Configure eigen3 ... "\\r
    if [ ! -d "build" ]; then
        mkdir "build"
    fi
    cd "build"
    ${MY_CMAKE} .. -DCMAKE_INSTALL_PREFIX=${INSTALL_DIRECTORY}/lib/build/eigen-3.4.0 -DCMAKE_C_COMPILER=${MY_CC} -DCMAKE_CXX_COMPILER=${MY_CXX} -DBUILD_SHARED_LIBS=$1 -DCMAKE_BUILD_TYPE=$2 -DCMAKE_CXX_FLAGS=${MY_CXX_FLAGS} -DBUILD_TESTING=OFF >${LOG_DIRECTORY}/eigen-3.4.0-config-log 2>&1 &&
    echo -e "- Configure eigen3 [${GREEN}done${NC}]" ||
    {
        echo -e "- Configure eigen3 [${RED}Error${NC}]"
        exit
    }
    make install >${LOG_DIRECTORY}/eigen-3.4.0-install-log 2>&1 &&
    cd ${INSTALL_DIRECTORY}/lib/build/eigen-3.4.0/share/eigen3/cmake &&
    if [ ! -e "EIGEN3Config.cmake" ]; then
	ln -s Eigen3Config.cmake EIGEN3Config.cmake >${LOG_DIRECTORY}/eigen-3.4.0-linking-log 2>&1
    fi &&
    echo -e "- Local install of eigen3 [${GREEN}done${NC}]" ||
    {
        echo -e "- Local install eigen3 [${RED}Error${NC}]"
        exit
    } 
    cd ${INSTALL_DIRECTORY}/lib

    echo -e "Install Minuit2 standalone"
    if [ ! -f "Minuit2/build/CMakeCache.txt" ] && [ -d "Minuit2/" ]; then
        rm -r "Minuit2/"
    fi
    if [ ! -d "Minuit2" ]; then
        tar -xf Minuit2.tar.gz
    fi
    cd "Minuit2"
    echo -ne "- Configure Minuit2 standalone ... "\\r
    if [ ! -d "build" ]; then
        mkdir "build"
    fi
    cd "build"
    ${MY_CMAKE} .. -DCMAKE_INSTALL_PREFIX=${INSTALL_DIRECTORY}/lib/build/Minuit2 -DCMAKE_C_COMPILER=${MY_CC} -DCMAKE_CXX_COMPILER=${MY_CXX} -DBUILD_SHARED_LIBS=$1 -DCMAKE_BUILD_TYPE=$2 >${LOG_DIRECTORY}/Minuit2-config-log 2>&1 &&
    echo -e "- Configure Minuit2 standalone [${GREEN}done${NC}]" ||
    {
        echo -e "- Configure Minuit2 standalone [${RED}Error${NC}]"
        exit
    }
    echo -ne "- Compile Minuit2 standalone ... "\\r
    make VERBOSE=1 -j${MY_BUILD_THREAD_NUMBER} >${LOG_DIRECTORY}/Minuit2-build-log 2>&1 &&
    echo -e "- Compile Minuit2 standalone [${GREEN}done${NC}]" ||
    {
        echo -e "- Compile Minuit2 standalone [${RED}Error${NC}]"
        exit
    }
    make install >${LOG_DIRECTORY}/Minuit2-install-log 2>&1 &&
    echo -e "- Local install of Minuit2 standalone [${GREEN}done${NC}]" ||
    {
        echo -e "- Local install Minuit2 standalone [${RED}Error${NC}]"
        exit
    } 

    cd ${INSTALL_DIRECTORY}

    clean_up >${LOG_DIRECTORY}/clean_up-log

    export_str="export ${MY_OS_SHAREDLIB_PATH_VAR}=\"${INSTALL_DIRECTORY}/lib/build/Minuit2/lib:${INSTALL_DIRECTORY}/lib/build/galtoolslib-1.1.1006/lib:${INSTALL_DIRECTORY}/lib/build/boost_1_76_0/lib:${INSTALL_DIRECTORY}/lib/build/CLHEP-2.4.4.2/lib:${INSTALL_DIRECTORY}/lib/build/gsl-2.7/lib:${INSTALL_DIRECTORY}/lib/build/xerces-c-3.2.3/lib:${INSTALL_DIRECTORY}/lib/build/Healpix_3.50/auto/lib:${INSTALL_DIRECTORY}/lib/build/CCfits-2.6/lib:${INSTALL_DIRECTORY}/lib/build/wcslib-7.7/lib:${INSTALL_DIRECTORY}/lib/build/cfitsio-4.0.0/lib:\$${MY_OS_SHAREDLIB_PATH_VAR}\""

    if [ -d "${INSTALL_DIRECTORY}/lib/build/xerces-c-3.2.3/lib64" ]; then

	export_str="export ${MY_OS_SHAREDLIB_PATH_VAR}=\"${INSTALL_DIRECTORY}/lib/build/Minuit2/lib:${INSTALL_DIRECTORY}/lib/build/galtoolslib-1.1.1006/lib:${INSTALL_DIRECTORY}/lib/build/boost_1_76_0/lib:${INSTALL_DIRECTORY}/lib/build/CLHEP-2.4.4.2/lib:${INSTALL_DIRECTORY}/lib/build/gsl-2.7/lib:${INSTALL_DIRECTORY}/lib/build/xerces-c-3.2.3/lib64:${INSTALL_DIRECTORY}/lib/build/Healpix_3.50/auto/lib:${INSTALL_DIRECTORY}/lib/build/CCfits-2.6/lib:${INSTALL_DIRECTORY}/lib/build/wcslib-7.7/lib:${INSTALL_DIRECTORY}/lib/build/cfitsio-4.0.0/lib:\$${MY_OS_SHAREDLIB_PATH_VAR}\""
		
    fi
    
    if ! grep -q "${export_str}" ${HOME}/${MY_RC_FILE}; then
        echo "${export_str}" >>${HOME}/${MY_RC_FILE}
        echo -e "- Update ${MY_RC_FILE} [${GREEN}done${NC}]"
    fi
    source ~/${MY_RC_FILE}

}

function clean_rc() {

    export_str="export PATH=\"${INSTALL_DIRECTORY}/bin:"'$PATH'"\""
    if grep -q "${export_str}" ${HOME}/${MY_RC_FILE}; then
        sed -i.bak "/${export_str//\//\\/}/d" ${HOME}/${MY_RC_FILE}
    fi

    export_str="export ${MY_OS_SHAREDLIB_PATH_VAR}=\"${INSTALL_DIRECTORY}/lib/build/Minuit2/lib:${INSTALL_DIRECTORY}/lib/build/galtoolslib-1.1.1006/lib:${INSTALL_DIRECTORY}/lib/build/boost_1_76_0/lib:${INSTALL_DIRECTORY}/lib/build/CLHEP-2.4.4.2/lib:${INSTALL_DIRECTORY}/lib/build/gsl-2.7/lib:${INSTALL_DIRECTORY}/lib/build/xerces-c-3.2.3/lib:${INSTALL_DIRECTORY}/lib/build/Healpix_3.50/auto/lib:${INSTALL_DIRECTORY}/lib/build/CCfits-2.6/lib:${INSTALL_DIRECTORY}/lib/build/wcslib-7.7/lib:${INSTALL_DIRECTORY}/lib/build/cfitsio-4.0.0/lib:\$${MY_OS_SHAREDLIB_PATH_VAR}\""

    if [ -d "${INSTALL_DIRECTORY}/lib/build/xerces-c-3.2.3/lib64" ]; then

	export_str="export ${MY_OS_SHAREDLIB_PATH_VAR}=\"${INSTALL_DIRECTORY}/lib/build/Minuit2/lib:${INSTALL_DIRECTORY}/lib/build/galtoolslib-1.1.1006/lib:${INSTALL_DIRECTORY}/lib/build/boost_1_76_0/lib:${INSTALL_DIRECTORY}/lib/build/CLHEP-2.4.4.2/lib:${INSTALL_DIRECTORY}/lib/build/gsl-2.7/lib:${INSTALL_DIRECTORY}/lib/build/xerces-c-3.2.3/lib64:${INSTALL_DIRECTORY}/lib/build/Healpix_3.50/auto/lib:${INSTALL_DIRECTORY}/lib/build/CCfits-2.6/lib:${INSTALL_DIRECTORY}/lib/build/wcslib-7.7/lib:${INSTALL_DIRECTORY}/lib/build/cfitsio-4.0.0/lib:\$${MY_OS_SHAREDLIB_PATH_VAR}\""
		
    fi
    
    if grep -q "${export_str}" ${HOME}/${MY_RC_FILE}; then
        sed -i.bak "/${export_str//\//\\/}/d" ${HOME}/${MY_RC_FILE}
    fi

}

function install_galprop() {

    initial_check
    echo -e "${PC}--- Install GALPROP ---${NC}"
    if [ ! -d "build" ]; then
        mkdir "build"
    fi
    cd "build"
    echo -ne "Configure GALPROP ... "\\r
    ${MY_CMAKE} .. -DCMAKE_INSTALL_PREFIX=${INSTALL_DIRECTORY}/GALPROP-57.0.3032 -DCMAKE_CXX_COMPILER=${MY_CXX} -DCMAKE_CXX_FLAGS=${MY_CXX_FLAGS} -DCMAKE_C_COMPILER=${MY_CC} -DCMAKE_Fortran_COMPILER=${MY_FC} -DCMAKE_Fortran_FLAGS=${MY_FC_FLAGS} -DBUILD_SHARED_LIBS=$1 -DCMAKE_BUILD_TYPE=$2 -Dgaltoolslib_DIR=${INSTALL_DIRECTORY}/lib/build/galtoolslib-1.1.1006/lib/CMake -DEIGEN3_DIR=${INSTALL_DIRECTORY}/lib/build/eigen-3.4.0/share/eigen3/cmake -DMinuit2_DIR=${INSTALL_DIRECTORY}/lib/build/Minuit2/lib/cmake/Minuit2 >${LOG_DIRECTORY}/galprop-config-log 2>&1 &&
    echo -e "- Configure GALPROP [${GREEN}done${NC}]" ||
    {
        echo -e "- Configure GALPROP [${RED}Error${NC}]"
        exit
    }
    echo -ne "- Compile GALPROP ... "\\r
    make VERBOSE=1 -j${MY_BUILD_THREAD_NUMBER} >${LOG_DIRECTORY}/galprop-build-log 2>&1 &&
    echo -e "- Compile GALPROP [${GREEN}done${NC}]" ||
    {
        echo -e "- Compile GALPROP [${RED}Error${NC}]"
        exit
    }
    make install >${LOG_DIRECTORY}/galprop-install-log 2>&1 &&
    echo -e "- Local install of GALPROP [${GREEN}done${NC}]" ||
    {
        echo -e "- Local install GALPROP [${RED}Error${NC}]"
        exit
    } 

}

function usage() {
    echo "Usage: ./install_galprop.sh [-h] [-n]"
    echo ""
    echo "Install GALPROP on your system."
    echo ""
    echo "Optional arguments:"
    echo "-h        show this help message only."
    echo "-n        new installation: compile support libraries and GALPROP."
    echo "-r        clean and compile GALPROP with optimisation."
    echo "-d        clean and compile GALPROP in debug mode."
    echo "-C        clean all builds (support libraries and GALPROP)."
    echo "-D        delete GALPROP and support libraries from system."
    echo "-u        update existing GALPROP build."
    exit
}

while getopts "hoduCD" OPT; do
    case $OPT in 
	C)
	    echo -e "${TC}------ Clean support libraries and GALPROP build ------${NC}"
	    cd ${INSTALL_DIRECTORY}
	    delete_build >${LOG_DIRECTORY}/delete-build-log 2>&1
	    clean_rc
	    exit
	    ;;
	D) 
	    printf "%s\n" "Do you really want to delete your GALPROP installation [y/N]?"
            read really_delete
            case ${really_delete:=n} in
		[yY]*)
		    echo -e "${TC}------ delete GALPROP ------${NC}"
		    clean_rc >${LOG_DIRECTORY}/clean_rc-log 2>&1
		    cd ${INSTALL_DIRECTORY}/../
		    rm -rv ${INSTALL_DIRECTORY}
		    exit
		    ;;
		*)
		    exit
		    ;;
            esac
            ;;
  	h)
	    usage
	    ;;
	o)
	    echo -e "${TC}------ Recompile GALPROP in optimised mode ------${NC}"
	    cd ${INSTALL_DIRECTORY}
	    delete_build >${LOG_DIRECTORY}/delete-build-log 2>&1
	    install_support_libraries "ON" "RelWithDebInfo"
	    install_galprop "ON" "RelWithDebInfo"
	    exit
	    ;;
	d)
	    echo -e "${TC}------ Recompile GALPROP in debug mode ------${NC}"
	    cd ${INSTALL_DIRECTORY}
	    delete_build >${LOG_DIRECTORY}/delete-build-log 2>&1
	    install_support_libraries "ON" "Debug"
	    install_galprop "ON" "Debug"
	    exit
	    ;;
	u)
	    echo -e "${TC}------ Update GALPROP executable ------${NC}"
	    cd ${INSTALL_DIRECTORY}
	    install_galprop "ON" "RelWithDebInfo"
	    exit
	    ;;
	\?)
	    usage
	    ;;
    esac
done

## Installation
echo -e "${TC}------ Installation of GALPROP cosmic ray propagation code ------${NC}"
cd ${INSTALL_DIRECTORY}
chmod +x *.sh

## Test for existing installation
if [ -e "${INSTALL_DIRECTORY}/GALPROP-57.0.3032/bin/galprop" ]; then
    echo -e "GALPROP executable found (use -o or -u to recompile) [${GREEN}done${NC}]"
else
    install_support_libraries "ON" "RelWithDebInfo"
    install_galprop "ON" "RelWithDebInfo"

    echo -e "${TC}-> Installation of GALPROP cosmic ray propagation code ${NC}[${GREEN}done${NC}]"
    echo -e "${TC} Source ~/${MY_RC_FILE} to set libraries for current shell to run GALPROP${NC}"
fi
