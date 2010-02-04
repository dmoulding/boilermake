TARGET := libanimals.a

SOURCES := \
    animal.cc \
    cat/cat.cc \
    dog/dog.cc \
    mouse/mouse.cc

SRC_INCDIRS := .

# chihuahua has its own submakefile because it has a specific SRC_DEFS that we
# want to apply only to it
SUBMAKEFILES := dog/chihuahua/chihuahua.mk
