# This file attempts to document all of the variables that can be specified in
# an easymake submakefile. Of all the variables, the only one that is
# absolutely required is "TARGET". However, it wouldn't really be useful to
# only specify "TARGET". Normally, at a minimum, some SOURCES and/or TGT_LDLIBS
# should also be defined.
#
# Many of the variable names begin with "SRC_" or "TGT_". These variables apply
# to the current list of source files or the current target, respectively.
#
# The "current" list of source files is the list of files specified on the
# "SOURCES" line in the *current* submakefile. The "SRC_*" variables cannot be
# applied to source files defined in some other submakefile.
#
# The "current" target could be a "TARGET" defined in the current submakefile,
# or it could be a "TARGET" defined in some ancestor makefile (see the
# description of TARGET below for more details).

# BUILD_DIR specifies the directory in which all intermediate build-generated
#   files (e.g. .o files) will be placed. The final targets (executables and/or
#   libraries) can be placed in a different directory (see TARGET_DIR).
#   A file hierarchy that mirrors the source hierarchy will be generated under
#   this directory.
#
#   It is advised to set this variable only once (so that all intermediate
#   build-generated files are placed under a common directory). Changing this
#   variable from one submakefile to the next is not recommended (and is not
#   guaranteed to work properly).
#
#   Default value: build
BUILD_DIR :=

# INCDIRS globally specifies include directories to be searched during source
#   compilation. These will apply to sources from all submakefiles and for all
#   targets. These should be specified as just directory names (i.e. they
#   should not be prefixed with a "-I". The paths should be specified relative
#   to the root of the project (i.e. the directory from which you run make).
#
#   Default value: <none>
INCDIRS :=

# DEFS globally specifies preprocessor definitions to be defined during source
#   compilation. These will apply to sources from all submakefiles and for all
#   targets. These should be specified exactly as they should be defined (i.e.
#   they should not be prefixed with a "-D").
#
#   Default value: <none>
DEFS :=

# SOURCES specifies one or more source files that are prerequesites of the
#   "current" target (the current target may be a target specified in the
#   same submakefile as the SOURCES variable, or it may be a target specified
#   in some ancestor makefile).
#
#   Currently supported sources are C and C++ sources ending with any of the
#   following filename extensions (if any desired extensions are not in the
#   lists below, adding additional supported extensions is trivial -- just add
#   them to C_SRC_EXTS and/or CXX_SRC_EXTS in the Makefile).
#
#   For C sources: .c
#
#   For C++ sources: .C .cc .cp .cpp .CPP .cxx .c++
#
#   Default value: <none>
SOURCES :=

# SRC_CFLAGS specifies compile flags to be applied to the C sources listed in
#   the current submakefile only. This can be used to augment the globally
#   applied CFLAGS for selected C sources.
#
#   For specifying include directories or preprocessor definitions SRC_INCDIRS
#   and SRC_DEFS (or their global equivalents, INCDIRS and DEFS) can often be
#   more convenient (you don't need to type all those extra "-I"s or "-D"s).
#
#   Examples of flags that are often specified here include "-pthread" and
#   the "-std=xxx" flags.
#
#   Default value: <none>
SRC_CFLAGS :=

# SRC_CXXFLAGS is like SRC_CFLAGS, but for C++ sources.
#
#   Default value: <none>
SRC_CXXFLAGS :=

# SRC_DEFS specifies preprocessor definitions to be defined during compilation
#   of sources listed in the current submakefile only. This can be used to
#   augment the globally applied DEFS for selected sources.
#
#   Default value: <none>
SRC_DEFS :=

# SRC_INCDIRS specifies include directories to be searched during compilation
#   of sources listed in the current submakefile only. This can be used to
#   augment the globally applied INCDIRS for selected sources. Unlike the
#   global INCDIRS variable, paths assigned to this variable should be relative
#   to the *current* submakefile's directory (not the root of the project).
#
#   Default value: <none>
SRC_INCDIRS :=

# SUBMAKEFILES specifies one or more submakefiles of the current submakefile.
#   This allows the construction of a makefile hierarchy, which makes it
#   possible to define multiple targets with unique sources and compiler/linker
#   flags.
#
#   For example, a group of source files that should all be compiled with a
#   common set of compile flags can be specified in their own submakefile that
#   specifies the SRC_CFLAGS variable. Or a new target, with its own list of
#   prerequesites and link-time libraries can be specified in a new
#   submakefile.
#
#   Default value: <none>
SUBMAKEFILES :=

# TARGET specifies that a new target is to be made by the Makefile. Targets can
#   be static libraries or executables (shared objects are considered
#   executables). Any target whose name ends with ".a" will be treated as a
#   static library. All others are treated as executables. By default, the
#   Makefile will build all targets if "make" is invoked without specifying a
#   target. This behavior can be overridden using the GNU Make variable
#   ".DEFAULT_GOAL", if desired. At least one target must be defined in order
#   to do anything useful.
#
#   The TARGET variable should be specified only *once* anywhere in the
#   makefile hierarchy for a given target name. Each time the TARGET variable
#   is specified, the Makefile interprets this to mean that a *new* target is
#   being defined. No two targets should have the same name.
#
#   All variables from submakefiles will apply to the "closest" target
#   specified in the submakefile hierarchy. For example, if a grandparent
#   makefile specifies a target named "foo" and a parent makefile specifies a
#   target "bar" while the child makefile does not specify a target, then any
#   sources or other variables specified in the child makefile will apply to
#   the target named "bar".
#
#   Default value: <none>
TARGET :=

# TARGET_DIR specifies the directory in which *all* final target files will be
#   placed. Intermediate build-generated files (.o files) are usually placed in
#   a different directory (see BUILD_DIR).
#
#   Like BUILD_DIR, it is advised to set this variable only once.
#
#   Default value: . (the top level directory)
TARGET_DIR :=

# TGT_LDFLAGS specifies flags that should be passed to the linker when linking
#   the target. The LDFLAGS variable can be used (e.g. from the command line)
#   to override flags specified here (i.e. these flags are specified first,
#   followed by LDFLAGS).
#
#   Examples of flags that are often specified here include "-L" and "-shared".
#
#   Default value: <none>
TGT_LDFLAGS :=

# TGT_LDLIBS specifies libraries (static or dynamic) that should be passed to
#   the linker when linking the target. Libraries should be listed using the
#   same format used on the traditional LDLIBS variable (e.g. to link with
#   librt.a you would list "-lrt").
#
#   Default value: <none>
TGT_LDLIBS :=

# TGT_LINKER specifies the program to be used for linking the target (applies
#   to executable targets only). If this option is not specified, the Makefile
#   will attempt to make a reasonable choice based upon the sources that are
#   prerequesites of the target (it will choose g++ if there are C++ sources,
#   otherwise it will choose cc).
#
#   Default value: <none>
TGT_LINKER :=

# TGT_POSTCLEAN specifies one or more actions to be performed after the target
#   has been cleaned. These should be entered as shell commands (normal GNU
#   Make processing applies, so you can use make variables in the commands).
#
#   See TGT_POSTMAKE below for more related information.
TGT_POSTCLEAN :=

# TGT_POSTMAKE specifies one or more actions to be performed after the target
#   has been made. These should be entered as shell commands (normal GNU Make
#   processing applies, so you can use make variables in the commands).
#
#   To specify a long series of commands, they can be separated by semicolons,
#   or pehaps it may be preferable to use the GNU Make "define" directive to
#   define the sequence of commands (with newlines allowed) and then refer to
#   the defined variable's name here. For example:
#
#     define MOVE_AND_LINK
#         mv foo bar
#         ln -s bar/foo
#     endef
#
#     TGT_POSTMAKE := ${MOVE_AND_LINK}
#
#   Default value: <none>
TGT_POSTMAKE :=

# TGT_PREREQS can be used to specify dependencies between targets. For example,
#   an executable target may depend on one or more static library targets
#   defined elsewhere. This variable can be used to tell Make that the
#   executable depends on those libraries.
#
#   Default value: <none>
TGT_PREREQS :=
