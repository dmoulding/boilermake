MOD_NAME := chihuahua
MOD_OBJS := chihuahua.o
MOD_CXXFLAGS := -march=pentium3 -DTACO_BELL
MOD_INCDIRS := animal animal/dog

SUBMODULES :=

include addmodule.mk