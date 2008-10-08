# COMPILE_C_CMDS - Commands for compiling C source code.
define COMPILE_C_CMDS
	@mkdir -p $(dir $@)
	${CC} -o $@ -c -MD ${TGT_CFLAGS} ${CFLAGS} ${INCDIRS} ${TGT_INCS} $<
	@cp ${BUILD_DIR}$*.d ${BUILD_DIR}$*.P; \
	 sed -e 's/#.*//' -e 's/^[^:]*: *//' -e 's/ *\\$$//' \
	     -e '/^$$/ d' -e 's/$$/ :/' < ${BUILD_DIR}$*.d \
	     >> ${BUILD_DIR}$*.P; \
	 rm -f ${BUILD_DIR}$*.d
endef

# COMPILE_CXX_CMDS - Commands for compiling C++ source code.
define COMPILE_CXX_CMDS
	@mkdir -p $(dir $@)
	${CXX} -o $@ -c -MD ${TGT_CXXFLAGS} ${CXXFLAGS} ${INCDIRS} \
	    ${TGT_INCS} $<
	@cp ${BUILD_DIR}$*.d ${BUILD_DIR}$*.P; \
	 sed -e 's/#.*//' -e 's/^[^:]*: *//' -e 's/ *\\$$//' \
	     -e '/^$$/ d' -e 's/$$/ :/' < ${BUILD_DIR}$*.d \
	     >> ${BUILD_DIR}$*.P; \
	 rm -f ${BUILD_DIR}$*.d
endef

# INCLUDE_MODULE - Parameterized "function" that includes a new module into the
#   makefile. This also recursively includes all submodules of the specified
#   module (via the inclusion of module.mk). Note that this function is only
#   useful in conjuction with eval, since the function results in a block of
#   Makefile syntax that must be evaluated. Because it must be used with eval,
#   most instances of "$" need to be escaped with a second "$" to accomodate
#   the double-expansion that occurs when eval is invoked.
define INCLUDE_MODULE
    # Initialize module-specific variables, then include the module.
    LIBS :=
    MOD_INCDIRS :=
    MOD_CFLAGS :=
    MOD_CXXFLAGS :=
    OBJS :=
    SUBMODULES :=
    TARGET :=
    include ${1}

    # Ensure that valid values are set for BUILD_DIR and TARGET_DIR.
    # XXX may want to verify that BUILD_DIR is slash-terminated if it's defined
    ifndef BUILD_DIR
        BUILD_DIR := build/
    endif
    ifeq "$$(strip $${TARGET_DIR})" ""
        TARGET_DIR := ./
    endif

    # Include module.mk to build the appropriate variables from the values in
    # the module's makefile fragment. A directory stack is maintained so that
    # the correct paths are used as we recursively include all submodules.
    DIR := $(patsubst ./%,%,$(dir ${1}))
    DIR_STACK := $$(call PUSH,$${DIR_STACK},$${DIR})
    OUT_DIR := $${BUILD_DIR}$${DIR}
    include module.mk
    DIR_STACK := $$(call POP,$${DIR_STACK})
    DIR := $$(call PEEK,$${DIR_STACK})
    OUT_DIR := $${BUILD_DIR}$${DIR}
endef

# PEEK - Parameterized "function" that results in the value at the top of the
#   specified colon-delimited stack.
define PEEK
$(lastword $(subst :, ,${1}))
endef

# POP - Parameterized "function" that pops the top value off of the specified
#   colon-delimited stack, and results in the new value of the stack. Note that
#   the popped value cannot be obtained using this function; use peek for that.
define POP
$(patsubst %:$(lastword $(subst :, ,${1})),%,${1})
endef

# PUSH - Parameterized "function" that pushes a value onto the specified colon-
#   delimited stack, and results in the new value of the stack.
define PUSH
$(patsubst %,${1}:%,${2})
endef

# ADD_TARGET - Parameterized "function" that adds a new target to the Makefile.
#   The target may be an executable or a library. The two allowable types of
#   targets are distinguished based on the name: library targets must end with
#   the traditional ".a" extension.
# XXX need to distinguish between C/C++ projects for linking.
define ADD_TARGET
ifeq "$$(strip $$(patsubst %.a,%,${1}))" "${1}"
    # Create a new target for linking an executable.
    ${1}: $${${1}_OBJS} $${${1}_LIBS}
	    @mkdir -p $$(dir $$@)
	    $${CXX} -o ${1} $${TGT_LDFLAGS} $${LDFLAGS} $${${1}_OBJS} $${TGT_LDLIBS}
else
    # Create a new target for creating a library archive.
    ${1}: $${${1}_OBJS}
	    @mkdir -p $$(dir $$@)
	    $${AR} r ${1} $${${1}_OBJS}
endif
endef

###############################################################################
#
# Actual "Processing" Starts Here
#
###############################################################################

# Initialize global variables.
ALL_DEPS :=
ALL_OBJS :=
ALL_TGTS :=
DIR_STACK :=
INCDIRS :=
TGT_STACK :=

# Include the main user-supplied module. This also recursively includes all
# user-supplied submodules.
$(eval $(call INCLUDE_MODULE,main.mk))

# Perform post-processing on global variables as needed.
ALL_DEPS := $(patsubst %.o,%.P,${OBJS})
INCDIRS := $(patsubst %,-I%,${INCDIRS})

# Define "all", which simply builds all user-defined targets, as default goal.
.PHONY: all
all: ${ALL_TGTS}

# Add a new target rule for each user-defined target.
$(foreach TGT,${ALL_TGTS},$(eval $(call ADD_TARGET,${TGT})))

# Define "clean" target to remove all build-generated files.
.PHONY: clean
clean:
	rm -f ${ALL_TGTS} ${ALL_OBJS} ${ALL_DEPS}

# Include generated rules that define additional dependencies.
-include ${ALL_DEPS}

###############################################################################
#
# Pattern Rules
#
###############################################################################

# Pattern rule for creating compiled object code from C source.
${BUILD_DIR}%.o: %.c
	${COMPILE_C_CMDS}

# Pattern rules for creating compiled object code from C++ source.
${BUILD_DIR}%.o: %.C
	${COMPILE_CXX_CMDS}

${BUILD_DIR}%.o: %.cc
	${COMPILE_CXX_CMDS}

${BUILD_DIR}%.o: %.cpp
	${COMPILE_CXX_CMDS}

${BUILD_DIR}%.o: %.cxx
	${COMPILE_CXX_CMDS}
