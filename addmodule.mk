# This makefile fragment should be included at the end of every module-specific
# makefile.
#
# The module-specific makefiles define the object files and sub-modules that
# are contained within the module.
#
# This makefile then does the actual work of adding the defined list of objects
# to the main OBJS list, and of recursively including the sub-module makefiles.
# It also creates any target-specific variables, such as include directories,
# or compiler flags, as required per the module-specific definitions.

# Generate the fully qualified name of this module's directory.
ifeq "$(strip ${MOD_NAME})" ""
DIR :=
else
DIR := $(patsubst %,${DIR}%/,${MOD_NAME})
endif
DIRS += ${DIR}

# Add the objects contained in this module to OBJS list (including the full
# path to the object -- remember make is running in the top-level directory).
MOD_OBJS := $(patsubst %,${OUTDIR}${DIR}%,${MOD_OBJS})
OBJS += ${MOD_OBJS}

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

# Restore DIR to point back at the parent directory. Note that this happens
# after we "pop back out" of the recursively included sub-makefiles (if any).
#DIR := $(patsubst %/,%,$(dir ${DIR}))
#ifneq "$(strip ${DIR})" ""
DIR := $(dir $(patsubst %/,%,${DIR}))
#endif
