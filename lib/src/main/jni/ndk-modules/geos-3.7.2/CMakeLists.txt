#################################################################################
#
# Main GEOS build configuration file for CMake build system
#
# Copyright (C) 2009 Mateusz Loskot <mateusz@loskot.net>
#
# This is free software; you can redistribute and/or modify it under
# the terms of the GNU Lesser General Public Licence as published
# by the Free Software Foundation.
# See the COPYING file for more information.
#
#################################################################################
cmake_minimum_required(VERSION 3.1.3)

if(NOT CMAKE_VERSION)
    set(CMAKE_VERSION
      "${CMAKE_MAJOR_VERSION}.${CMAKE_MINOR_VERSION}.${CMAKE_PATCH_VERSION}")
endif()

if(POLICY CMP0048)
    cmake_policy(SET CMP0048 NEW)
endif()
#################################################################################
# Set GEOS project
#################################################################################
project(GEOS VERSION 3.7.2 LANGUAGES C CXX)

# Add custom GEOS modules for CMake
list(APPEND CMAKE_MODULE_PATH "${PROJECT_SOURCE_DIR}/cmake/modules")

#################################################################################
# Set C++ standard
#################################################################################
set(CMAKE_CXX_STANDARD 11)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)

message(STATUS "Setting C++ requirement to C++${CMAKE_CXX_STANDARD}")

#################################################################################
# Setup GEOS version
#################################################################################

# GEOS release version
# GEOS C++ library SONAME will use these encoding ABI break at every release
set(GEOS_VERSION "${GEOS_VERSION_MAJOR}.${GEOS_VERSION_MINOR}.${GEOS_VERSION_PATCH}")
set(VERSION "${GEOS_VERSION}")

# Copy version components into different variable names to match those used
# by autotools for *.h.in files
set(VERSION_MAJOR ${GEOS_VERSION_MAJOR})
set(VERSION_MINOR ${GEOS_VERSION_MINOR})
set(VERSION_PATCH ${GEOS_VERSION_PATCH})

# JTS_PORT is the version of JTS this release is bound to
set(JTS_PORT 1.13.0)
message(STATUS "Setting GEOS version ${VERSION} as port of JTS ${JTS_PORT}")

# GEOS C API version
set(CAPI_INTERFACE_CURRENT 12)
set(CAPI_INTERFACE_REVISION 2)
set(CAPI_INTERFACE_AGE 11)

math(EXPR CAPI_VERSION_MAJOR "${CAPI_INTERFACE_CURRENT} - ${CAPI_INTERFACE_AGE}")
set(CAPI_VERSION_MINOR ${CAPI_INTERFACE_AGE})
set(CAPI_VERSION_PATCH ${CAPI_INTERFACE_REVISION})
set(CAPI_VERSION "${CAPI_VERSION_MAJOR}.${CAPI_VERSION_MINOR}.${CAPI_VERSION_PATCH}")
message(STATUS "Setting GEOS C API version ${CAPI_VERSION}")
if (NOT WIN32)
  set(CAPI_SOVERSION ${CAPI_VERSION_MAJOR})
  message(STATUS "Setting GEOS C API soversion ${CAPI_SOVERSION}")
endif()

#################################################################################
# Check custom global options
#################################################################################

option(GEOS_ENABLE_INLINE
  "Set to OFF|ON (default) to control GEOS compilation with small functions inlining" ON)

if(NOT MSVC)
  option(GEOS_ENABLE_ASSERT
    "Set to ON|OFF (default) to build GEOS with assert() macro enabled" OFF)
endif()

option(GEOS_ENABLE_TESTS
  "Set to OFF|ON (default) to control build of GEOS tests package" ON)

option(GEOS_ENABLE_TESTS_UNIT2_ONLY
  "Set to ON|OFF (default) to enable only new tests based on Catch (WIP: experimental)." OFF)

option(GEOS_BUILD_STATIC
  "Set to OFF|ON (default) to build GEOS static libraries" ON)

option(GEOS_BUILD_SHARED
  "Set to OFF|ON (default) to build GEOS shared libraries" ON)

if(CMAKE_COMPILER_IS_GNUCC OR CMAKE_COMPILER_IS_GNUCXX)
  option(GEOS_ENABLE_FLOATSTORE
    "Set to OFF|ON (default) to control IEEE754 conformance and remove extra precision" ON)
endif()

if(APPLE)
  option(GEOS_ENABLE_MACOSX_FRAMEWORK
    "Set to ON|OFF (default) to build GEOS as a Mac OS X framework" OFF)
  option(GEOS_ENABLE_MACOSX_FRAMEWORK_UNIXCOMPAT
    "Set to ON|OFF (default) to add Unix compatibility to the Mac OS X framework" OFF)
endif()

#################################################################################
# Setup C/C++ compiler options
#################################################################################
if(NOT MSVC_IDE)
  if(NOT CMAKE_BUILD_TYPE)
    set(CMAKE_BUILD_TYPE Debug CACHE STRING
      "Choose the type of build, options are: None Debug Release" FORCE)
  endif()
  message(STATUS "Setting GEOS build type - ${CMAKE_BUILD_TYPE}")
endif()

if(CMAKE_BUILD_TYPE STREQUAL Debug)
  add_definitions(-D_DEBUG)
endif()

add_definitions(-DUSE_UNSTABLE_GEOS_CPP_API)

if(CMAKE_COMPILER_IS_GNUCC OR CMAKE_COMPILER_IS_GNUCXX)

  # General options
  set(CMAKE_C_FLAGS "-pedantic -ansi ${CMAKE_C_FLAGS}")

  # Numerical stability
  if(GEOS_ENABLE_FLOATSTORE)
    # Remove extra precision by forcing conformance to IEEE 754 rather than IEEE 854
    set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -ffloat-store")
  endif()
  message(STATUS
    "Forcing IEEE 754 using flag -ffloat-store - ${GEOS_ENABLE_FLOATSTORE}")

  # Warnings specification
  set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -Wall -Wno-long-long -fno-implicit-inline-templates -Wconversion -pedantic -W -Wunused -Wuninitialized -Wextra -Wdouble-promotion")

  # Turn on Position Independent Code generation for GEOS C shared library
  set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -fPIC -Wall -Wconversion -pedantic -Wmissing-prototypes -W -Wunused -Wuninitialized -Wextra -Wdouble-promotion")

  # Enable glibc ISO C99 features (macros isfinite, isnan)
  set(CMAKE_REQUIRED_DEFINITIONS "${CMAKE_REQUIRED_DEFINITIONS} -D_ISOC99_SOURCE=1")

elseif(MSVC)

  # Set pedantic mode by default
  #set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} /W4")
  string(REGEX REPLACE "/W[0-9]" "/W4" CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS}")

  if(MSVC)
    set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} /MP")

    add_definitions(-D_SCL_SECURE_NO_WARNINGS)
    add_definitions(-D_CRT_SECURE_NO_WARNINGS)
    add_definitions(-DNOMINMAX)
  endif()

endif()

if(GEOS_ENABLE_INLINE)
  add_definitions(-DGEOS_INLINE)
endif()
message(STATUS
  "Setting GEOS compilation with small functions inlining - ${GEOS_ENABLE_INLINE}")

if(NOT MSVC)
  if(GEOS_ENABLE_ASSERT)
    string(REGEX REPLACE "[-/]D.*NDEBUG" "-U NDEBUG"
      CMAKE_CXX_FLAGS_RELEASE "${CMAKE_CXX_FLAGS_RELEASE}")
  endif()
  message(STATUS
    "Setting GEOS compilation with assert() macro enabled - ${GEOS_ENABLE_ASSERT}")
endif()

#################################################################################
# Setup C/C++ library features
#################################################################################

# check header files
include(CheckIncludeFiles)

check_include_files(stdint.h HAVE_STDINT_H)
check_include_files(inttypes.h HAVE_INTTYPES_H)
check_include_files(ieeefp.h HAVE_IEEEFP_H)

# check types and sizes
include(CheckTypeSize)

if(MSVC)
  check_type_size("__int64" HAVE_INT64_T_64)
else()
  if(HAVE_STDINT_H OR HAVE_INTTYPES_H)
    check_type_size("int64_t" HAVE_INT64_T_64)
  else()
    check_type_size("long long int" HAVE_LONG_LONG_INT_64)
  endif()
endif()

# check functions and macros
include(CheckPrototypeExists)
include(CheckSymbolExists)

check_prototype_exists(isnan cmath HAVE_STD_ISNAN)
if(NOT HAVE_STD_ISNAN)
  if(MSVC)
    check_prototype_exists(_isnan float.h HAVE_ISNAN)
  elseif(APPLE)
    check_prototype_exists(__isnand math.h HAVE_ISNAND_XCODE)
    if(NOT HAVE_ISNAND_XCODE)
      check_prototype_exists(__inline_isnand math.h HAVE_INLINE_ISNAND_XCODE)
    endif()
  else()
    check_symbol_exists(isnan math.h HAVE_ISNAN)
  endif()
endif()

check_prototype_exists(isfinite cmath HAVE_STD_ISFINITE)

if(NOT HAVE_STD_ISFINITE)
  if(MSVC)
    check_prototype_exists(_finite float.h HAVE_FINITE)
  else()
    #CMAKE_COMPILER_IS_GNUCC OR CMAKE_COMPILER_IS_GNUCXX)
    check_symbol_exists(isfinite math.h HAVE_ISFINITE)
  endif()
endif()

################################################################################
# Setup build directories
#################################################################################

# Put the libaries and binaries that get built into directories at the
# top of the build tree rather than in hard-to-find leaf
# directories. This simplifies manual testing and the use of the build
# tree rather than installed Boost libraries.
set(CMAKE_LIBRARY_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/lib)
set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/lib)
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/bin)

################################################################################
# Setup include directories
#################################################################################

# for including GEOS C++ API headers
include_directories(${PROJECT_SOURCE_DIR}/include)

# for including build-specific GEOS C API headers
include_directories(${PROJECT_BINARY_DIR}/capi)

# for including build-specific version.h, platform.h and geos_c.h
include_directories(${PROJECT_BINARY_DIR}/include)

# for geos_ts.cpp which does #include "../geos_revision.h" whereas
# CMake generates geos_revision.h in build directory,
# to not to pollute source tree.
include_directories(${PROJECT_BINARY_DIR})

#################################################################################
# Setup checks and generate config headers
#################################################################################
find_package(Git)

message(STATUS "Generating GEOS ${PROJECT_BINARY_DIR}/geos_revision.h")
file(WRITE ${CMAKE_BINARY_DIR}/geos_revision.h.in "\#define GEOS_REVISION \"@GEOS_REVISION@\"\n")

file(WRITE ${CMAKE_BINARY_DIR}/geos_revision.cmake
"
execute_process(COMMAND \${GIT} describe --tags --always
  WORKING_DIRECTORY \${CWD}
  OUTPUT_VARIABLE GEOS_REVISION
  OUTPUT_STRIP_TRAILING_WHITESPACE)
configure_file(\${SRC} \${DST} @ONLY)
")

add_custom_target(geos_revision
  COMMAND ${CMAKE_COMMAND}
    -D CWD=${CMAKE_CURRENT_SOURCE_DIR}
    -D GIT=${GIT_EXECUTABLE}
    -D SRC=${PROJECT_BINARY_DIR}/geos_revision.h.in
    -D DST=${PROJECT_BINARY_DIR}/geos_revision.h
    -P ${PROJECT_BINARY_DIR}/geos_revision.cmake)

if(EXISTS ${PROJECT_SOURCE_DIR}/include/geos/platform.h)
  message(STATUS "Disabling existing ${PROJECT_SOURCE_DIR}/include/geos/platform.h")

  if(${CMAKE_MAJOR_VERSION} EQUAL 2 AND ${CMAKE_MINOR_VERSION} EQUAL 6)
    file(REMOVE ${PROJECT_SOURCE_DIR}/include/geos/platform.h)
    set(PH_RESULT "removed")
  else()
    file(RENAME
      ${PROJECT_SOURCE_DIR}/include/geos/platform.h
      ${PROJECT_SOURCE_DIR}/include/geos/platform.h.disabled)
      set(PH_RESULT "renamed")
  endif()

  message(STATUS "Disabling existing ${PROJECT_SOURCE_DIR}/include/geos/platform.h - ${PH_RESULT}")
endif()

message(STATUS "Generating GEOS ${PROJECT_BINARY_DIR}/include/geos/platform.h")
configure_file(${PROJECT_SOURCE_DIR}/include/geos/platform.h.cmake
  ${PROJECT_BINARY_DIR}/include/geos/platform.h)

message(STATUS "Generating GEOS ${PROJECT_BINARY_DIR}/include/geos/version.h")
configure_file(${PROJECT_SOURCE_DIR}/include/geos/version.h.in
  ${PROJECT_BINARY_DIR}/include/geos/version.h @ONLY)

message(STATUS "Generating GEOS ${PROJECT_BINARY_DIR}/capi/geos_c.h")
configure_file(${PROJECT_SOURCE_DIR}/capi/geos_c.h.in
  ${PROJECT_BINARY_DIR}/capi/geos_c.h @ONLY)

#################################################################################
# Configure tests
#################################################################################

if(GEOS_ENABLE_TESTS OR GEOS_ENABLE_TESTS_UNIT2_ONLY)
  enable_testing()
  # Define "make check" as alias for "make test"
  add_custom_target(check COMMAND ctest)
endif()

#################################################################################
# IDE specifics
#################################################################################
if (MSVC_IDE)
  # Visual Studio 2017 supports .editorconfig, copy it next to generated .sln
  message(STATUS "Copying .editorconfig file to ${PROJECT_BINARY_DIR}")
  file(COPY "${PROJECT_SOURCE_DIR}/.editorconfig"
    DESTINATION "${PROJECT_BINARY_DIR}")
endif()

include(GenerateSourceGroups)

# Enable target debugging for CMake Tools in Visual Studio Code
# https://github.com/vector-of-bool/vscode-cmake-tools
include(CMakeToolsHelpers OPTIONAL)

#################################################################################
# Configure subdirectories
#################################################################################
add_subdirectory(include)
add_subdirectory(src)
add_subdirectory(capi)
add_subdirectory(tests)
add_subdirectory(tools)

#################################################################################
# Install/Uninstall
#################################################################################

configure_file("${PROJECT_SOURCE_DIR}/cmake/cmake_uninstall.cmake.in"
  "${PROJECT_BINARY_DIR}/cmake/cmake_uninstall.cmake"
  IMMEDIATE @ONLY)

add_custom_target(uninstall
  "${CMAKE_COMMAND}" -P "${PROJECT_BINARY_DIR}/cmake/cmake_uninstall.cmake")

#################################################################################
# DEBUG settings - TODO: make a summary

message(STATUS "CMake ${CMAKE_VERSION} successfully configured ${PROJECT_NAME} using ${CMAKE_GENERATOR} generator")

#message(STATUS "XXX: CMAKE_CXX_FLAGS=${CMAKE_CXX_FLAGS}")
#message(STATUS "XXX: CMAKE_CXX_FLAGS_DEBUG=${CMAKE_CXX_FLAGS_DEBUG}")
#message(STATUS "XXX: CMAKE_CXX_FLAGS_RELEASE=${CMAKE_CXX_FLAGS_RELEASE}")
