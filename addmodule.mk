ifndef BUILD_DIR
    BUILD_DIR := build/
endif

ifeq "$(strip ${TARGET_DIR})" ""
    TARGET_DIR := ./
endif

OUT_DIR := ${BUILD_DIR}${DIR}

ifneq "$(strip ${TARGET})" ""
    TGT := $(strip ${TARGET_DIR}${TARGET})
    TGTS += ${TGT}
    ${TGT}_OBJS :=
    ${TGT}_LIBS :=
    ${TGT}: TGT_LDLIBS :=
else
    TGT := $(strip $(call peek,${TGT_STACK}))
endif
TGT_STACK := $(call push,${TGT_STACK},${TGT})

ifneq "$(strip ${OBJS})" ""
    OBJS := $(patsubst %,${OUT_DIR}%,${OBJS})
    ${TGT}_OBJS += ${OBJS}
    ALL_OBJS += ${OBJS}
    ${OBJS}: TGT_CFLAGS := ${MOD_CFLAGS}
    ${OBJS}: TGT_CXXFLAGS := ${MOD_CXXFLAGS}
    ${OBJS}: TGT_INCS := $(patsubst %,-I%,${MOD_INCDIRS})

    DEPS += $(patsubst %.o,%.P,${OBJS})
endif

ifneq "$(strip ${LIBS})" ""
    ${TGT}_LIBS += ${TARGET_DIR}${LIBS}
    ${TGT}: TGT_LDFLAGS := $(patsubst %,-L%,${TARGET_DIR})
    ${TGT}: TGT_LDLIBS += $(patsubst lib%.a,-l%,${LIBS})
endif

ifneq "$(strip ${SUBMODULES})" ""
    $(eval $(foreach SUB,${SUBMODULES},$(call include_module,${DIR}${SUB})))
endif

TGT_STACK := $(call pop,${TGT_STACK})
TGT := $(call peek,${TGT_STACK})
