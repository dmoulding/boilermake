DEFAULT_CFG := debug

ifeq "$(strip ${CFG})" ""
    CFG := ${DEFAULT_CFG}
endif

INCDIRS := animals
LDFLAGS  = -L${TARGET_DIR}

ifeq "$(strip ${CFG})" "debug"
    BUILD_DIR  := debug
    CXXFLAGS   := -g -O0 -Wall -pipe
    TARGET_DIR := debug
else ifeq "$(strip ${CFG})" "release"
    BUILD_DIR  := release
    CXXFLAGS   := -g -O2 -Wall -pipe
    TARGET_DIR := release
endif

SUBMAKEFILES := talk.mk
