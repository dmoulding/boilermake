# The main makefile fragment MUST define the final executable name.
OUT := ../animals.exe

# The main makefile fragment MAY define a top-level output directory. If an
# output directory is specified, it MUST be terminated with a slash (/).
OUTDIR := build/

# The main makefile fragment SHOULD define default C/C++ compiler flags.
CXXFLAGS := -g -O0

# The main makefile fragment SHOULD define default linker flags.
LDFLAGS :=

# The main makefile fragment MUST NOT have a module name.
MOD_NAME :=
MOD_OBJS := main.o
MOD_INCDIRS := !all

SUBMODULES := animal

# The main makefile fragment MUST define .DEFAULT_GOAL as ${OUTDIR}${OUT}
.DEFAULT_GOAL := ${OUTDIR}${OUT}

include addmodule.mk
