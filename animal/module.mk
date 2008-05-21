MOD_NAME := animal
MOD_OBJS := animal.o
MOD_INCDIRS :=

MOD_LIB := libanimal.a

SUBMODULES := cat dog mouse

include addmodule.mk
