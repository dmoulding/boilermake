TARGET := talk

TGT_LDFLAGS := -L${TARGET_DIR}
TGT_LDLIBS  := -lanimals
TGT_PREREQS := libanimals.a

SOURCES := talk.cc

SRC_INCDIRS := \
    animals \
    animals/cat \
    animals/dog \
    animals/dog/chihuahua \
    animals/mouse
