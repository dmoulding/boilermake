TARGET := talk

MOD_INCDIRS := \
    animals/cat \
    animals/dog \
    animals/dog/chihuahua \
    animals/mouse

PRELIBS := libanimals.a

SRCS := talk.cc

SUBMODULES := animals/animals.mk
