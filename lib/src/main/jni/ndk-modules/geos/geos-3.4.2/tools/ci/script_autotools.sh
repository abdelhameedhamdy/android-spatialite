#!/bin/bash -e
#
# Travis CI script for GEOS build with GNU Autotools
#
# Copyright (C) 2013 Mateusz Loskot <mateusz@loskot.net>
#
# This is free software; you can redistribute and/or modify it under
# the terms of the GNU Lesser General Public Licence as published
# by the Free Software Foundation. 
# See the COPYING file for more information.
#
source ${TRAVIS_BUILD_DIR}/tools/ci/common.sh

cd ${TRAVIS_BUILD_DIR}
./autogen.sh
cd -
${TRAVIS_BUILD_DIR}/configure
run_make
run_test
