From ubuntu:22.04
ADD galprop_v57_release_r1 /galprop
RUN apt-get update && apt-get install -y gcc autoconf cmake g++ gfortran libcfitsio-dev libzip-dev lbzip2
RUN cd /galprop/lib/cfitsio-4.0.0/ && ./configure && make && make install
RUN cd /galprop && ./install_galprop
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/galprop/lib/build/galtoolslib-1.1.1006/lib:/galprop/lib/build/CCfits-2.6/lib:/galprop/lib/build/cfitsio-4.0.0/lib:/galprop/lib/build/Healpix_3.50/lib:/galprop/lib/build/boost_1_76_0/lib:/galprop/lib/build/eigen-3.4.0/lib:/galprop/lib/build/gsl-2.7/lib:/galprop/lib/build/xerces-c-3.2.3/lib:/galprop/lib/build/CLHEP-2.4.4.2/lib:/galprop/lib/build/Minuit2/lib:/galprop/lib/build/galtoolslib-1.1.1006/lib:/galprop/lib/build/wcslib-7.7/lib





# RUN /galprop/install_galprop.sh

