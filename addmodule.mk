# This makefile MUST be included at the end of every module-specific makefile.
#
# The module-specific makefiles define the object files and sub-modules that
# are contained within the module.
#
# This makefile then does the actual work of:
#
#     + Adding the module's dependency files to the P_INCLUDES list
#     + Adding the module's list of objects to the main OBJS list
#     + Recursively including the sub-module makefiles
#     + Creating target-specific variables (e.g. include dirs, compiler flags)
#     + Combining objects into archives for modules that make libraries.

# Generate the fully qualified name of this module's directory and add this
# directory to the list of all directorys (DIRS).
ifeq "$(strip ${MOD_NAME})" ""
    DIR :=
else
    DIR := $(patsubst %,${DIR}%/,${MOD_NAME})
endif
DIRS += ${DIR}

# Append the top-level output directory (if any) to the object names (including
# the full path to the object -- make is running in the top-level directory).
MOD_OBJS := $(patsubst %,${OUTDIR}${DIR}%,${MOD_OBJS})

# Add the corresponding dependency files to the list of dependency includes.
P_INCLUDES += $(patsubst %.o,%.P,${MOD_OBJS})

# Add the objects contained in this module to the main OBJS list -- unless
# this module or one of its super-modules builds a library. In that case, add
# the objects from this module to the list of library objects instead.
ifeq "$(strip ${MOD_LIB})" ""
    OBJS += ${MOD_OBJS}
else
    ifeq "$(strip ${MOD_LIB_OBJS})" ""
        MOD_LIB_OBJS := ${MOD_OBJS}
        LIB_LEVELS := ${MOD_LIB}/
        LIB_OBJS += ${MOD_OBJS}
    else
        MOD_LIB_OBJS += ${MOD_OBJS}
        LIB_LEVELS := $(patsubst %,%${MOD_LIB}/,${LIB_LEVELS})
        LIB_OBJS += ${MOD_OBJS}
    endif
endif

# Create a target-specific variable to contain the module's compiler flags.
${MOD_OBJS}: TGT_CXXFLAGS := ${MOD_CXXFLAGS}
MOD_CXXFLAGS :=

# Create a target-specific variable to contain the module's include directory
# flags for the compile command line. If the special value "!all" was listed
# for MOD_INCDIRS, then set it to use the entire list of directories.
ifeq "$(strip ${MOD_INCDIRS})" "!all"
    ${MOD_OBJS}: TGT_INCDIRS = $(patsubst %,-I%,${DIRS})
else
    ${MOD_OBJS}: TGT_INCDIRS := $(patsubst %,-I%,${MOD_INCDIRS})
endif
MOD_INCDIRS :=

# If this module has any sub-modules, then recursively include the
# sub-makefiles from those sub-modules.
ifneq "$(strip ${SUBMODULES})" ""
    MK_INCLUDES := $(patsubst %,${DIR}%/module.mk,${SUBMODULES})
    include ${MK_INCLUDES}
endif

# Additional processing for modules that create libraries.
ifneq "$(strip ${LIB_LEVELS})" ""
    # Strip off the bottom-most level of LIB_LEVELS. When we reach the top of
    # the hierarchy (./), then we know we've returned to the module that
    # originally defined the library. All objects encountered below that level
    # should be archived in the library.
    LIB_LEVELS := $(dir $(patsubst %/,%,${LIB_LEVELS}))
    ifeq "$(strip ${LIB_LEVELS})" "./"
        # We have "popped" back out to the module that defined the library.
        # MOD_LIB_OBJS now contains the list of all objects within this module
        # and all of its sub-modules as well.
        #
        # Generate the rule to make the library. This must be done using eval
        # so that MOD_LIB and MOD_LIB_OBJS are expanded now, instead of later
        # after their values have been cleared.
        define libtarget
        ${OUTDIR}${MOD_LIB}: ${MOD_LIB_OBJS}
		@mkdir -p ${OUTDIR}
		@ar r ${OUTDIR}${MOD_LIB} ${MOD_LIB_OBJS}
        endef
        $(eval $(call libtarget))

        # Add this library to the list of libraries.
        LIBS += ${OUTDIR}${MOD_LIB}

        # Reset other library-related variables so that they are initialized
        # when the next module's makefile fragment is processed and a new
        # library can be started if required.
        LIB_LEVELS :=
        MOD_LIB :=
        MOD_LIB_OBJS :=
    endif
endif

# Restore DIR to point back at the parent directory. Note that this happens
# after we "pop back out" of the recursively included sub-makefiles (if any).
DIR := $(dir $(patsubst %/,%,${DIR}))
