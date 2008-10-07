TARGET := libanimals.a

OBJS := animal.o

SUBMODULES := \
    cat/cat.mk \
    dog/dog.mk \
    mouse/mouse.mk

#include addmodule.mk
