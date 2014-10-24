# modified from https://github.com/mbcrawfo/GenericMakefile #

####### PROJECT SETTINGS #######
# The name of the executable to be created
BIN_NAME := test.exe
# Compiler used
CXX ?= g++
# Extension of source files used in the project
SRC_EXT = cpp
# Path to the source directory, relative to the makefile
SRC_DIRS = src/core src/hello src/test
# General compiler flags
COMPILE_FLAGS = -Wall -Wextra -Wno-unused-parameter
# Additional release-specific flags
RCOMPILE_FLAGS = -D NDEBUG
# Additional debug-specific flags
DCOMPILE_FLAGS = -D DEBUG -g
# Add additional include paths
INCLUDES = -I ./
# General linker settings
LINK_FLAGS = 
# Additional release-specific linker settings
RLINK_FLAGS = 
# Additional debug-specific linker settings
DLINK_FLAGS = 
####### END PROJECT SETTINGS #######

include common.mk
