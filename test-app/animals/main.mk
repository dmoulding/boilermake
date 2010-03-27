# The libanimals.a library can normally be built by itself (without also
# building the "talk" program) by running "make libanimals.a" from within the
# "test-app" directory.
#
# This main.mk exists solely for the purpose of also allowing users to build the
# libanimals.a library by itself by running "make" from within the "animals"
# subdirectory.

BUILD_DIR  := ../build/animals
TARGET_DIR := ..

CXXFLAGS := -g -O0 -Wall -pipe

SUBMAKEFILES := animals.mk
