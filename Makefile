# boilermake: A reusable, but flexible, boilerplate Makefile.
#
# Author: Dan Moulding <dmoulding@gmail.com> (2008)

# Caution: Don't edit this Makefile! Create your own main.mk and other
#          submakefiles, which will be included by this Makefile.
#          Only edit this if you need to modify boilermake's behavior (fix
#          bugs, add features, etc).

# Note: Parameterized "functions" in this makefile that are marked with
#       "USE WITH EVAL" are only useful in conjuction with eval. This is
#       because those functions result in a block of Makefile syntax that must
#       be evaluated after expansion. Since they must be used with eval, most
#       instances of "$" within them need to be escaped with a second "$" to
#       accomodate the double expansion that occurs when eval is invoked.

# ADD_CLEAN_RULE - Parameterized "function" that adds a new rule and phony
#   target for cleaning the specified target (removing its build-generated
#   files).
#
#   USE WITH EVAL
#
define ADD_CLEAN_RULE
    clean: clean_${1}
    .PHONY: clean_${1}
    clean_${1}:
	$$(strip rm -f ${1} $${${1}_OBJS:%.o=%.[oP]})
	$${${1}_POSTCLEAN}
endef

# ADD_OBJECT_RULE - Parameterized "function" that adds a pattern rule, using
#   the commands from the second argument, for building object files from
#   source files with the filename extension specified in the first argument.
#
#   USE WITH EVAL
#
define ADD_OBJECT_RULE
$${BUILD_DIR}/%.o: ${1}
	${2}
endef

# ADD_TARGET_RULE - Parameterized "function" that adds a new target to the
#   Makefile. The target may be an executable or a library. The two allowable
#   types of targets are distinguished based on the name: library targets must
#   end with the traditional ".a" extension.
#
#   USE WITH EVAL
#
define ADD_TARGET_RULE
    ifeq "$$(suffix ${1})" ".a"
        # Add a target for creating a static library.
        ${1}: $${${1}_OBJS}
	    @mkdir -p $$(dir $$@)
	    $$(strip $${AR} $${ARFLAGS} ${1} $${${1}_OBJS})
	    $${TGT_POSTMAKE}
    else
        # Add a target for linking an executable. First, attempt to select the
        # appropriate front-end to use for linking. This might not choose the
        # right one (e.g. if linking with a C++ static library, but all other
        # sources are C sources), so the user makefile is allowed to specify a
        # linker to be used for each target.
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

        ${1}: $${${1}_OBJS} $${${1}_PREREQS}
	    @mkdir -p $$(dir $$@)
	    $$(strip $${TGT_LINKER} -o ${1} $${LDFLAGS} $${TGT_LDFLAGS} \
	        $${${1}_OBJS} $${LDLIBS} $${TGT_LDLIBS})
	    $${TGT_POSTMAKE}
    endif
endef

# CANONICAL_PATH - Given one or more paths, converts the paths to the canonical
#   form. The canonical form is the path, relative to the project's top-level
#   directory (the directory from which "make" is run), and without
#   any "./" or "../" sequences. For paths that are not  located below the
#   top-level directory, the canonical form is the absolute path (i.e. from
#   the root of the filesystem) also without "./" or "../" sequences.
define CANONICAL_PATH
$(patsubst ${CURDIR}/%,%,$(abspath ${1}))
endef

# COMPILE_C_CMDS - Commands for compiling C source code.
define COMPILE_C_CMDS
	@mkdir -p $(dir $@)
	$(strip ${CC} -o $@ -c -MD ${CFLAGS} ${SRC_CFLAGS} ${INCDIRS} \
	    ${SRC_INCDIRS} ${SRC_DEFS} ${DEFS} $<)
	@cp ${BUILD_DIR}/$*.d ${BUILD_DIR}/$*.P; \
	 sed -e 's/#.*//' -e 's/^[^:]*: *//' -e 's/ *\\$$//' \
	     -e '/^$$/ d' -e 's/$$/ :/' < ${BUILD_DIR}/$*.d \
	     >> ${BUILD_DIR}/$*.P; \
	 rm -f ${BUILD_DIR}/$*.d
endef

# COMPILE_CXX_CMDS - Commands for compiling C++ source code.
define COMPILE_CXX_CMDS
	@mkdir -p $(dir $@)
	$(strip ${CXX} -o $@ -c -MD ${CXXFLAGS} ${SRC_CXXFLAGS} ${INCDIRS} \
	    ${SRC_INCDIRS} ${SRC_DEFS} ${DEFS} $<)
	@cp ${BUILD_DIR}/$*.d ${BUILD_DIR}/$*.P; \
	 sed -e 's/#.*//' -e 's/^[^:]*: *//' -e 's/ *\\$$//' \
	     -e '/^$$/ d' -e 's/$$/ :/' < ${BUILD_DIR}/$*.d \
	     >> ${BUILD_DIR}/$*.P; \
	 rm -f ${BUILD_DIR}/$*.d
endef

# INCLUDE_SUBMAKEFILE - Parameterized "function" that includes a new
#   "submakefile" fragment into the overall Makefile. It also recursively
#   includes all submakefiles of the specified submakefile fragment.
#
#   USE WITH EVAL
#
define INCLUDE_SUBMAKEFILE
    # Initialize all variables that can be defined by a makefile fragment, then
    # include the specified makefile fragment.
    TARGET :=
    TGT_LDFLAGS :=
    TGT_LDLIBS :=
    TGT_LINKER :=
    TGT_POSTCLEAN :=
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
    DIR := $(call CANONICAL_PATH,$(dir ${1}))
    DIR_STACK := $$(call PUSH,$${DIR_STACK},$${DIR})

    # Determine which target this makefile's variables apply to. A stack is
    # used to keep track of which target is the "current" target as we
    # recursively include other submakefiles.
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
        $${TGT}_POSTCLEAN := $${TGT_POSTCLEAN}
        $${TGT}_PREREQS := $$(addprefix $${TARGET_DIR}/,$${TGT_PREREQS})
        $${TGT}_DEPS :=
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

        # Qualify and canonicalize paths.
        SOURCES     := $$(call QUALIFY_PATH,$${DIR},$${SOURCES})
        SOURCES     := $$(call CANONICAL_PATH,$${SOURCES})
        SRC_INCDIRS := $$(call QUALIFY_PATH,$${DIR},$${SRC_INCDIRS})
        SRC_INCDIRS := $$(call CANONICAL_PATH,$${SRC_INCDIRS})

        # Save the list of source files for this target.
        $${TGT}_SOURCES += $${SOURCES}

        # Convert the source file names to their corresponding object file
        # names.
        OBJS := $$(addprefix $${BUILD_DIR}/,\
                   $$(addsuffix .o,$$(basename $${SOURCES})))

        # Add the objects to the current target's list of objects, and create
        # target-specific variables for the objects based on any source
        # variables that were defined.
        $${TGT}_OBJS += $${OBJS}
        $${TGT}_DEPS += $${OBJS:%.o=%.P}
        $${OBJS}: SRC_CFLAGS := $${SRC_CFLAGS}
        $${OBJS}: SRC_CXXFLAGS := $${SRC_CXXFLAGS}
        $${OBJS}: SRC_DEFS := $$(addprefix -D,$${SRC_DEFS})
        $${OBJS}: SRC_INCDIRS := $$(addprefix -I,$${SRC_INCDIRS})
    endif

    ifneq "$$(strip $${SUBMAKEFILES})" ""
        # This makefile has submakefiles. Recursively include them.
        $$(foreach MK,$${SUBMAKEFILES},\
           $$(eval $$(call INCLUDE_SUBMAKEFILE,\
                      $$(call CANONICAL_PATH,\
                         $$(call QUALIFY_PATH,$${DIR},$${MK})))))
    endif

    # Reset the "current" target to it's previous value.
    TGT_STACK := $$(call POP,$${TGT_STACK})
    TGT := $$(call PEEK,$${TGT_STACK})

    # Reset the "current" directory to it's previous value.
    DIR_STACK := $$(call POP,$${DIR_STACK})
    DIR := $$(call PEEK,$${DIR_STACK})
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
${1:%:$(lastword $(subst :, ,${1}))=%}
endef

# PUSH - Parameterized "function" that pushes a value onto the specified colon-
#   delimited stack, and results in the new value of the stack.
define PUSH
${2:%=${1}:%}
endef

# QUALIFY_PATH - Given a "root" directory and one or more paths, qualifies the
#   paths using the "root" directory (i.e. appends the root directory name to
#   the paths) except for paths that are absolute.
define QUALIFY_PATH
$(addprefix ${1}/,$(filter-out /%,${2})) $(filter /%,${2})
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
ALL_TGTS :=
DEFS :=
DIR_STACK :=
INCDIRS :=
TGT_STACK :=

# Include the main user-supplied submakefile. This also recursively includes
# all other user-supplied submakefiles.
$(eval $(call INCLUDE_SUBMAKEFILE,main.mk))

# Perform post-processing on global variables as needed.
DEFS := $(addprefix -D,${DEFS})
INCDIRS := $(addprefix -I,$(call CANONICAL_PATH,${INCDIRS}))

# Define the "all" target (which simply builds all user-defined targets) as the
# default goal.
.PHONY: all
all: ${ALL_TGTS}

# Add a new target rule for each user-defined target.
$(foreach TGT,${ALL_TGTS},\
  $(eval $(call ADD_TARGET_RULE,${TGT})))

# Add pattern rule(s) for creating compiled object code from C source.
$(foreach EXT,${C_SRC_EXTS},\
  $(eval $(call ADD_OBJECT_RULE,${EXT},$${COMPILE_C_CMDS})))

# Add pattern rule(s) for creating compiled object code from C++ source.
$(foreach EXT,${CXX_SRC_EXTS},\
  $(eval $(call ADD_OBJECT_RULE,${EXT},$${COMPILE_CXX_CMDS})))

# Add "clean" rules to remove all build-generated files.
.PHONY: clean
$(foreach TGT,${ALL_TGTS},\
  $(eval $(call ADD_CLEAN_RULE,${TGT})))

# Include generated rules that define additional (header) dependencies.
$(foreach TGT,${ALL_TGTS},\
  $(eval -include ${${TGT}_DEPS}))
