ifneq "$(strip ${TARGET})" ""
    TGT := $(strip ${TARGET_DIR}${TARGET})
    ALL_TGTS += ${TGT}
    ${TGT}_OBJS :=
    ${TGT}_LIBS :=
    ${TGT}: TGT_LDLIBS :=
else
    TGT := $(strip $(call PEEK,${TGT_STACK}))
endif
TGT_STACK := $(call PUSH,${TGT_STACK},${TGT})

ifneq "$(strip ${OBJS})" ""
    OBJS := $(patsubst %,${OUT_DIR}%,${OBJS})
    ${TGT}_OBJS += ${OBJS}
    ALL_OBJS += ${OBJS}
    ${OBJS}: TGT_CFLAGS := ${MOD_CFLAGS}
    ${OBJS}: TGT_CXXFLAGS := ${MOD_CXXFLAGS}
    ${OBJS}: TGT_INCS := $(patsubst %,-I%,${MOD_INCDIRS})
endif

ifneq "$(strip ${LIBS})" ""
    ${TGT}_LIBS += ${TARGET_DIR}${LIBS}
    ${TGT}: TGT_LDFLAGS := $(patsubst %,-L%,${TARGET_DIR})
    ${TGT}: TGT_LDLIBS += $(patsubst lib%.a,-l%,${LIBS})
endif

ifneq "$(strip ${SUBMODULES})" ""
    $(foreach SUB,${SUBMODULES},$(eval $(call INCLUDE_MODULE,${DIR}${SUB})))
endif

TGT_STACK := $(call POP,${TGT_STACK})
TGT := $(call PEEK,${TGT_STACK})
