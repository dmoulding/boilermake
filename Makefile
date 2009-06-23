# Note: Parameterized "functions" in this makefile that are marked with
#       "USE WITH EVAL" are only useful in conjuction with eval. This is because
#       those functions result in a block of Makefile syntax that must be
#       evaluated after expansion.
#
#       Since they must be used with eval, most instances of "$" within them
#       need to be escaped with a second "$" to accomodate the double expansion
#       that occurs when eval is invoked. Consequently, attempting to call these
#       "functions" without also using eval will probably not yield the expected
#       result.

# ADD_OBJECT_RULE - Parameterized "function" that adds a pattern rule, using
#   the commands from the second argument, for building object files from source
#   files with the filename extension specified in the first argument.
#
#   USE WITH EVAL
#
define ADD_OBJECT_RULE
$${BUILD_DIR}/%.o: ${1}
	${2}
endef

# ADD_TARGET - Parameterized "function" that adds a new target to the Makefile.
#   The target may be an executable or a library. The two allowable types of
#   targets are distinguished based on the name: library targets must end with
#   the traditional ".a" extension.
#
#   USE WITH EVAL
#
define ADD_TARGET
    ifeq "$$(suffix ${1})" ".a"
        # Add a target for creating a static library.
        ${1}: $${${1}_OBJS}
	    @mkdir -p $$(dir $$@)
	    $${AR} $${ARFLAGS} ${1} $${${1}_OBJS}
	    $${TGT_POSTMAKE}
    else
        # Add a target for linking an executable.
        ${1}: $${${1}_OBJS} $${${1}_PREREQS}
	    @mkdir -p $$(dir $$@)
	    $${TGT_LINKER} -o ${1} $${TGT_LDFLAGS} $${LDFLAGS} $${${1}_OBJS} \
	        $${LDLIBS} $${TGT_LDLIBS}
	    $${TGT_POSTMAKE}
    endif
endef

# COMPILE_C_CMDS - Commands for compiling C source code.
define COMPILE_C_CMDS
	@mkdir -p $(dir $@)
	${CC} -o $@ -c -MD ${SRC_CFLAGS} ${CFLAGS} ${INCDIRS} ${SRC_INCDIRS} \
	    ${SRC_DEFS} ${DEFS} $<
	@cp ${BUILD_DIR}/$*.d ${BUILD_DIR}/$*.P; \
	 sed -e 's/#.*//' -e 's/^[^:]*: *//' -e 's/ *\\$$//' \
	     -e '/^$$/ d' -e 's/$$/ :/' < ${BUILD_DIR}/$*.d \
	     >> ${BUILD_DIR}/$*.P; \
	 rm -f ${BUILD_DIR}/$*.d
endef

# COMPILE_CXX_CMDS - Commands for compiling C++ source code.
define COMPILE_CXX_CMDS
	@mkdir -p $(dir $@)
	${CXX} -o $@ -c -MD ${SRC_CXXFLAGS} ${CXXFLAGS} ${INCDIRS} \
	    ${SRC_INCDIRS} ${SRC_DEFS} ${DEFS} $<
	@cp ${BUILD_DIR}/$*.d ${BUILD_DIR}/$*.P; \
	 sed -e 's/#.*//' -e 's/^[^:]*: *//' -e 's/ *\\$$//' \
	     -e '/^$$/ d' -e 's/$$/ :/' < ${BUILD_DIR}/$*.d \
	     >> ${BUILD_DIR}/$*.P; \
	 rm -f ${BUILD_DIR}/$*.d
endef

# INCLUDE_MK - Parameterized "function" that includes a new makefile fragment
#   into the overall makefile. It also recursively includes all submakefiles of
#   the specified makefile fragment.
#
#   USE WITH EVAL
#
define INCLUDE_MK
    # Initialize all variables that can be defined by a makefile fragment, then
    # include the specified makefile fragment.
    TARGET :=
    TGT_LDLIBS :=
    TGT_LINKER :=
    TGT_LDFLAGS :=
    TGT_POSTMAKE :=
    TGT_PREREQS :=

    SOURCES :=
    SRC_CFLAGS :=
    SRC_CXXFLAGS :=
    SRC_DEFS :=
    SRC_INCDIRS :=

    SUBMAKEFILES :=

    include ${1}

    # Initialize internal local variables.
    OBJS :=

    # Ensure that valid values are set for BUILD_DIR and TARGET_DIR.
    ifeq "$$(strip $${BUILD_DIR})" ""
        BUILD_DIR := build
    endif
    ifeq "$$(strip $${TARGET_DIR})" ""
        TARGET_DIR := .
    endif

    # A directory stack is maintained so that the correct paths are used as we
    # recursively include all submakefiles. Get the makefile's directory and
    # push it onto the stack.
    DIR := $(patsubst ./%,%,$(dir ${1}))
    DIR_STACK := $$(call PUSH,$${DIR_STACK},$${DIR})
    OUT_DIR := $${BUILD_DIR}/$${DIR}

    # Determine which target this makefile's variables apply to. A stack is used
    # to keep track of which target is the "current" target as we recursively
    # include other submakefiles.
    ifneq "$$(strip $${TARGET})" ""
        # This makefile defined a new target. Target variables defined by this
        # makefile apply to this new target. Initialize the target's variables.
        TGT := $$(strip $${TARGET_DIR}/$${TARGET})
        ALL_TGTS += $${TGT}
        $${TGT}: TGT_LDFLAGS := $${TGT_LDFLAGS}
        $${TGT}: TGT_LDLIBS := $${TGT_LDLIBS}
        $${TGT}: TGT_LINKER := $${TGT_LINKER}
        $${TGT}: TGT_POSTMAKE := $${TGT_POSTMAKE}
        $${TGT}_LINKER := $${TGT_LINKER}
        $${TGT}_PREREQS := $$(patsubst %,$${TARGET_DIR}/%,$${TGT_PREREQS})

        $${TGT}_OBJS :=
        $${TGT}_SOURCES :=
    else
        # The values defined by this makefile apply to the the "current" target
        # as determined by which target is at the top of the stack.
        TGT := $$(strip $$(call PEEK,$${TGT_STACK}))
    endif

    # Push the current target onto the target stack.
    TGT_STACK := $$(call PUSH,$${TGT_STACK},$${TGT})

    ifneq "$$(strip $${SOURCES})" ""
        # This makefile builds one or more objects from source. Validate the
        # specified sources against the supported source file types.
        BAD_SRCS := $$(strip $$(filter-out $${ALL_SRC_EXTS},$${SOURCES}))
        ifneq "$${BAD_SRCS}" ""
            $$(error Unsupported source file(s) found in ${1} [$${BAD_SRCS}])
        endif
        $${TGT}_SOURCES += $${SOURCES}

        # Convert the source file names to their corresponding object file
        # names.
        OBJS := $${SOURCES}
        $$(foreach EXT,$${ALL_SRC_EXTS},$$(eval OBJS := $${OBJS:$${EXT}=%.o}))

        # Add the objects to the current target's list of objects, and create
        # target-specific variables for the objects based on any source
        # variables that were defined.
        OBJS := $$(patsubst %,$${OUT_DIR}%,$${OBJS})
        ALL_OBJS += $${OBJS}
        $${TGT}_OBJS += $${OBJS}
        $${OBJS}: SRC_CFLAGS := $${SRC_CFLAGS}
        $${OBJS}: SRC_CXXFLAGS := $${SRC_CXXFLAGS}
        $${OBJS}: SRC_DEFS := $$(patsubst %,-D%,$${SRC_DEFS})
        $${OBJS}: SRC_INCDIRS := $$(patsubst %,-I%,$${SRC_INCDIRS})
    endif

    ifneq "$$(strip $${SUBMAKEFILES})" ""
        # This makefile has submakefiles. Recursively include them.
        $$(foreach MK,$${SUBMAKEFILES}, \
            $$(eval $$(call INCLUDE_MK,$${DIR}$${MK})))
    endif

    # Reset the "current" target to it's previous value.
    TGT_STACK := $$(call POP,$${TGT_STACK})
    TGT := $$(call PEEK,$${TGT_STACK})

    # Reset the "current" directory to it's previous value.
    DIR_STACK := $$(call POP,$${DIR_STACK})
    DIR := $$(call PEEK,$${DIR_STACK})
    OUT_DIR := $${BUILD_DIR}/$${DIR}
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

# SELECT_LINKER - Parameterized "function" that attempts to select the
#   appropriate front-end to the linker which should be used for linking an
#   executable target. Note that this function can be safely called for all
#   targets (even static libraries). For targets that don't require linking
#   (such as static libraries), the end result of this function will have no
#   effect on the target's final creation.
#
#   USE WITH EVAL
#
define SELECT_LINKER
    ifeq "$$(strip $${${1}_LINKER})" ""
        # No linker was explicitly specified to be used for this target. If
        # there are any C++ sources for this target, use the C++ compiler.
        # For all other targets, default to using the C compiler.
        ifneq "$$(strip $$(filter $${CXX_SRC_EXTS},$${${1}_SOURCES}))" ""
            ${1}: TGT_LINKER = $${CXX}
        else
            ${1}: TGT_LINKER = $${CC}
        endif
    endif
endef

###############################################################################
#
# Start of Makefile Evaluation
#
###############################################################################

# Define the source file extensions that we know how to handle.
C_SRC_EXTS := %.c
CXX_SRC_EXTS := %.C %.cc %.cp %.cpp %.CPP %.cxx %.c++
ALL_SRC_EXTS := ${C_SRC_EXTS} ${CXX_SRC_EXTS}

# Initialize global variables.
ALL_DEPS :=
ALL_OBJS :=
ALL_TGTS :=
DEFS :=
DIR_STACK :=
INCDIRS :=
TGT_STACK :=

# Include the main user-supplied makefile. This also recursively includes all
# user-supplied submakefiles.
$(eval $(call INCLUDE_MK,main.mk))

# Perform post-processing on global variables as needed.
ALL_DEPS := $(patsubst %.o,%.P,${ALL_OBJS})
DEFS := $(patsubst %,-D%,${DEFS})
INCDIRS := $(patsubst %,-I%,${INCDIRS})

# Define "all", which simply builds all user-defined targets, as default goal.
.PHONY: all
all: ${ALL_TGTS}

# Select the linker to be used for each user-defined target.
$(foreach TGT,${ALL_TGTS},$(eval $(call SELECT_LINKER,${TGT})))

# Add a new target rule for each user-defined target.
$(foreach TGT,${ALL_TGTS},$(eval $(call ADD_TARGET,${TGT})))

# Add pattern rule(s) for creating compiled object code from C source.
$(foreach EXT,${C_SRC_EXTS},\
  $(eval $(call ADD_OBJECT_RULE,${EXT},$${COMPILE_C_CMDS})))

# Add pattern rule(s) for creating compiled object code from C++ source.
$(foreach EXT,${CXX_SRC_EXTS},\
  $(eval $(call ADD_OBJECT_RULE,${EXT},$${COMPILE_CXX_CMDS})))

# Include generated rules that define additional (header) dependencies.
-include ${ALL_DEPS}

# Define "clean" target to remove all build-generated files.
.PHONY: clean
clean:
	rm -f ${ALL_TGTS} ${ALL_OBJS} ${ALL_DEPS}
	${POSTCLEAN}
