ALL_OBJS :=
DEPS :=
TGT_STACK :=
TGTS :=
TOP_MK := top.mk

# XXX need to distinguish between C/C++ projects for linking.
define target
ifeq "$$(strip $$(patsubst %.a,%,${1}))" "${1}"
${1}: $${${1}_OBJS} $${${1}_LIBS}
	@mkdir -p $$(dir $$@)
	$${CXX} -o ${1} $${TGT_LDFLAGS} $${LDFLAGS} $${${1}_OBJS} $${TGT_LDLIBS}
else
${1}: $${${1}_OBJS}
	@mkdir -p $$(dir $$@)
	$${AR} r ${1} $${${1}_OBJS}
endif

endef

define include_module
LIBS :=
MOD_INCDIRS :=
MOD_CFLAGS :=
MOD_CXXFLAGS :=
OBJS :=
SUBMODULES :=
TARGET :=
include ${1}

ifndef BUILD_DIR
    BUILD_DIR := build/
endif
ifeq "$$(strip $${TARGET_DIR})" ""
    TARGET_DIR := ./
endif

DIR := $(patsubst ./%,%,$(dir ${1}))
DIR_STACK := $$(call push,$${DIR_STACK},$${DIR})
OUT_DIR := $${BUILD_DIR}$${DIR}
include addmodule.mk
DIR_STACK := $$(call pop,$${DIR_STACK})
DIR := $$(call peek,$${DIR_STACK})
OUT_DIR := $${BUILD_DIR}$${DIR}
endef

define peek
$(lastword $(subst :, ,${1}))
endef

define pop
$(patsubst %:$(lastword $(subst :, ,${1})),%,${1})
endef

define push
$(patsubst %,${1}:%,${2})
endef

$(eval $(call include_module,${TOP_MK}))

INCDIRS := $(patsubst %,-I%,${INCDIRS})

$(foreach TGT,${TGTS},$(eval $(call target,${TGT})))

.DEFAULT_GOAL = all
.PHONY: all
all: ${TGTS}

${BUILD_DIR}%.o: %.c
	@mkdir -p $(dir $@)
	${CC} -o $@ -c -MD ${TGT_CFLAGS} ${CFLAGS} ${INCDIRS} ${TGT_INCS} $<
	@cp ${BUILD_DIR}$*.d ${BUILD_DIR}$*.P; \
	sed -e 's/#.*//' -e 's/^[^:]*: *//' -e 's/ *\\$$//' \
	   -e '/^$$/ d' -e 's/$$/ :/' < ${BUILD_DIR}$*.d >> ${BUILD_DIR}$*.P; \
	rm -f ${BUILD_DIR}$*.d

${BUILD_DIR}%.o: %.cc
	@mkdir -p $(dir $@)
	${CXX} -o $@ -c -MD ${TGT_CXXFLAGS} ${CXXFLAGS} ${INCDIRS} ${TGT_INCS} $<
	@cp ${BUILD_DIR}$*.d ${BUILD_DIR}$*.P; \
	sed -e 's/#.*//' -e 's/^[^:]*: *//' -e 's/ *\\$$//' \
	   -e '/^$$/ d' -e 's/$$/ :/' < ${BUILD_DIR}$*.d >> ${BUILD_DIR}$*.P; \
	rm -f ${BUILD_DIR}$*.d

-include ${DEPS}

.PHONY: clean
clean:
	rm -f ${TGTS} ${ALL_OBJS} ${DEPS}
