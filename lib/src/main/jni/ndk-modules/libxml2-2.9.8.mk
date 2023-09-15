LOCAL_PATH:= $(call my-dir)
include $(CLEAR_VARS)
# -------------------
#  libxml2-2.9.8
# -------------------
# ./autogen.sh  --build=x86_64-pc-linux-gnu --host=arm-linux-eabi
# ASFLAGS="-D__ANDROID__" ; ./configure --build=x86_64-pc-linux-gnu --host=arm-linux-eabi
# -------------------
# As of 2018-03-05
# -------------------
# https://github.com/GNOME/libxml2/releases
# -------------------
# changes:
# use autogen.sh with configure parameters
# avoid: dict.c:205: error: undefined reference to 'rand_r' using 'ASFLAGS="-D__ANDROID__"'
# ------------------
LOCAL_MODULE    := libxml2

# taken from make file am__libxml2_la_SOURCES_DIST

xml2_flags := \
 -DHAVE_CONFIG_H=1 \
 -DHAVE_ERRNO_H=1 \
 -DHAVE_RAND=0 \
 -DLIBXML_THREAD_ENABLED=1

LOCAL_CFLAGS    := \
 $(xml2_flags)

LOCAL_C_INCLUDES := \
 $(LOCAL_PATH)/$(ICONV_PATH)/include \
 $(LOCAL_PATH)/$(ICONV_PATH)/libcharset/include \
 $(LOCAL_PATH)/$(LZMA_PATH)/src/liblzma/api \
 $(LOCAL_PATH)/$(XML2_PATH)/include \
 $(LOCAL_PATH)/$(XML2_PATH)
LOCAL_SRC_FILES := \
 $(XML2_PATH)/buf.c \
 $(XML2_PATH)/c14n.c \
 $(XML2_PATH)/catalog.c \
 $(XML2_PATH)/chvalid.c \
 $(XML2_PATH)/debugXML.c \
 $(XML2_PATH)/dict.c \
 $(XML2_PATH)/DOCBparser.c \
 $(XML2_PATH)/encoding.c \
 $(XML2_PATH)/entities.c \
 $(XML2_PATH)/error.c \
 $(XML2_PATH)/globals.c \
 $(XML2_PATH)/hash.c \
 $(XML2_PATH)/HTMLparser.c \
 $(XML2_PATH)/HTMLtree.c \
 $(XML2_PATH)/legacy.c \
 $(XML2_PATH)/list.c \
 $(XML2_PATH)/nanoftp.c \
 $(XML2_PATH)/nanohttp.c \
 $(XML2_PATH)/parser.c \
 $(XML2_PATH)/parserInternals.c \
 $(XML2_PATH)/pattern.c \
 $(XML2_PATH)/relaxng.c \
 $(XML2_PATH)/SAX2.c \
 $(XML2_PATH)/SAX.c \
 $(XML2_PATH)/schematron.c \
 $(XML2_PATH)/threads.c \
 $(XML2_PATH)/tree.c \
 $(XML2_PATH)/trio.c \
 $(XML2_PATH)/triostr.c \
 $(XML2_PATH)/uri.c \
 $(XML2_PATH)/valid.c \
 $(XML2_PATH)/xinclude.c \
 $(XML2_PATH)/xlink.c \
 $(XML2_PATH)/xmlIO.c \
 $(XML2_PATH)/xmlmemory.c \
 $(XML2_PATH)/xmlmodule.c \
 $(XML2_PATH)/xmlreader.c \
 $(XML2_PATH)/xmlregexp.c \
 $(XML2_PATH)/xmlsave.c \
 $(XML2_PATH)/xmlschemas.c \
 $(XML2_PATH)/xmlschemastypes.c \
 $(XML2_PATH)/xmlstring.c \
 $(XML2_PATH)/xmlunicode.c \
 $(XML2_PATH)/xmlwriter.c \
 $(XML2_PATH)/xpath.c \
 $(XML2_PATH)/xpointer.c \
 $(XML2_PATH)/xzlib.c
LOCAL_STATIC_LIBRARIES := iconv liblzma
include $(BUILD_STATIC_LIBRARY)


