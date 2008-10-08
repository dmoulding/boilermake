TARGET := talk

OBJS := talk.o

LIBS := libanimals.a

MOD_INCDIRS := \
    animals/cat \
    animals/dog \
    animals/dog/chihuahua \
    animals/mouse

SUBMODULES := animals/animals.mk
