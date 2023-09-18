From ubuntu:22.04
ADD galprop_v57_release_r1 /galprop
ADD modified_install_galprop.sh /galprop/install_galprop.sh
RUN apt-get update && apt-get install -y gcc autoconf cmake g++ gfortran libcfitsio-dev libzip-dev lbzip2 zlib1g-dev
RUN cd /galprop/lib && tar -xzf cfitsio-4.0.0.tar.gz && cd ./cfitsio-4.0.0/ && ./configure && make && make install
RUN cd /galprop && bash ./install_galprop.sh
ENV LD_LIBRARY_PATH=/galprop/lib/build/galtoolslib-1.1.1006/lib:/galprop/lib/build/CCfits-2.6/lib:/galprop/lib/build/cfitsio-4.0.0/lib:/galprop/lib/build/Healpix_3.50/lib:/galprop/lib/build/boost_1_76_0/lib:/galprop/lib/build/eigen-3.4.0/lib:/galprop/lib/build/gsl-2.7/lib:/galprop/lib/build/xerces-c-3.2.3/lib:/galprop/lib/build/CLHEP-2.4.4.2/lib:/galprop/lib/build/Minuit2/lib:/galprop/lib/build/galtoolslib-1.1.1006/lib:/galprop/lib/build/wcslib-7.7/lib
