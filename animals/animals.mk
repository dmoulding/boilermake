TARGET := libanimals.a

SOURCES := animal.cc

SUBMAKEFILES := \
    cat/cat.mk \
    dog/dog.mk \
    mouse/mouse.mk
