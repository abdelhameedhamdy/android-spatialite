LOCAL_PATH:= $(call my-dir)
include $(CLEAR_VARS)

JSQLITE_PATH := javasqlite-20120209
SQLITE_PATH := sqlite-amalgamation-3430100
SPATIALITE_PATH := libspatialite-5.0.0
PROJ_PATH := proj-6.1.1
GEOS_PATH := geos-3.7.2
JSONC_PATH := json-c-0.13.1
RTTOPO_PATH := librttopo-20180125
XML2_PATH := libxml2-2.9.8
LZMA_PATH := xz-5.2.1
ICONV_PATH := libiconv-1.15

NDK_MODULES_PATH := ndk-modules

LOCAL_MODULE:= libandroid_spatialite

LOCAL_STATIC_LIBRARIES := \
    spatialite

# LOCAL_C_INCLUDES := \
#     $(NDK_MODULES_PATH)/$(SQLITE_PATH) \
#     $(NDK_MODULES_PATH)/$(SPATIALITE_PATH)/src/headers \

LOCAL_SRC_FILES:= \
    android_database_SQLiteCommon.cpp \
    android_database_SQLiteConnection.cpp \
    android_database_SQLiteGlobal.cpp \
    android_database_SQLiteDebug.cpp \
    android_database_CursorWindow.cpp \
    CursorWindow.cpp \
    JNIHelp.cpp \
    JNIString.cpp

ifeq ($(TARGET_ARCH), arm)
    LOCAL_CFLAGS += -DPACKED="__attribute__ ((packed))"
else
    LOCAL_CFLAGS += -DPACKED=""
endif

LOCAL_CFLAGS += -Wno-unused-parameter -Wno-int-to-pointer-cast
LOCAL_CFLAGS += -Wno-uninitialized -Wno-parentheses -Wpointer-bool-conversion
LOCAL_CPPFLAGS += -Wno-conversion-null

# libs from the NDK
LOCAL_LDLIBS += -llog

include $(BUILD_SHARED_LIBRARY)

# The library concrete version subfolder name must match its .mk file.
# E.g. libxml2-2.9.2/ -> libxml2-2.9.2.mk



# -------------------
# Android_5.0.0.mk
# -------------------
# For Spatialite without RasterLite2
# - jsqlite-20120209.mk
# 'HAVE_RASTERLITE2=0'
# -------------------
# [from 'jni/' directory]
# ndk-build clean
# ndk-build
# OR
# ndk-build clean ; ndk-build
# -------------------
# As of 2019-07-07
# -------------------
# Order of running:
# - javasqlite[20120209] code corrections for 64-bits
# - sqlite3[3280000]
# - spatialite [5.0.0-20180508]
# - proj[6.1.1]
# - geos[3.7.2]
# - json-c[0.13.1]
# - librttopo[20180125]
# - libxml2[2.9.8]
# - xz[5.2.1 (5.2.3 fails)]
# - libiconv[1.15]
# -------------------

# -------------------
# include $(NDK_MODULES_PATH)/jsqlite-20120209.mk
include $(NDK_MODULES_PATH)/$(SQLITE_PATH)/sqlite-3430100.mk
include $(NDK_MODULES_PATH)/spatialite-5.0.0.mk
include $(NDK_MODULES_PATH)/proj-6.1.1.mk
include $(NDK_MODULES_PATH)/geos-3.7.2.mk
# include $(NDK_MODULES_PATH)/json-c-0.13.1.mk
include $(NDK_MODULES_PATH)/librttopo-1.1.0.mk
include $(NDK_MODULES_PATH)/libxml2-2.9.8.mk
include $(NDK_MODULES_PATH)/lzma-xz-5.2.1.mk
include $(NDK_MODULES_PATH)/iconv-1.15.mk

# NOTE: iconv is dependency of Spatialite virtual modules like VirtualText, VirtualShape, VirtualXL, etc.
