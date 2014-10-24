# modified from https://github.com/mbcrawfo/GenericMakefile #

#### PROJECT SETTINGS ####
# The name of the executable to be created
BIN_NAME := hello.exe
# Compiler used
CXX ?= g++
# Extension of source files used in the project
SRC_EXT = cpp
# Path to the source directory, relative to the makefile
SRC_DIRS = dir_a dir_b
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
#### END PROJECT SETTINGS ####

# Generally should not need to edit below this line

# Shell used in this makefile
# bash is used for 'echo -en'
SHELL = /bin/bash
# Clear built-in rules
.SUFFIXES:

# Verbose option, to output compile and link commands
export V := true
export CMD_PREFIX := @
ifeq ($(V),true)
	CMD_PREFIX :=
endif

# Combine compiler and linker flags
release: export CXXFLAGS := $(CXXFLAGS) $(COMPILE_FLAGS) $(RCOMPILE_FLAGS)
release: export LDFLAGS := $(LDFLAGS) $(LINK_FLAGS) $(RLINK_FLAGS)
debug: export CXXFLAGS := $(CXXFLAGS) $(COMPILE_FLAGS) $(DCOMPILE_FLAGS)
debug: export LDFLAGS := $(LDFLAGS) $(LINK_FLAGS) $(DLINK_FLAGS)

# Build and output paths
release: export BUILD_PATH := obj/release
debug: export BUILD_PATH := obj/debug

# Find all source files in the source directory, sorted by most
# recently modified
SOURCES = $(shell find $(SRC_DIRS) -name '*.$(SRC_EXT)' -printf '%T@\t%p\n' | sort -k 1nr | cut -f2-)

# Set the object file names, with the source directory stripped
# from the path, and the build path prepended in its place
OBJECTS = $(SOURCES:%.$(SRC_EXT)=$(BUILD_PATH)/%.o)
# Set the dependency files that will be used to add header dependencies
DEPS = $(OBJECTS:.o=.d) 

# Debug build for gdb debugging
.PHONY: debug
debug: dirs
	@echo "Beginning debug build"
	@$(MAKE) -f $(lastword $(MAKEFILE_LIST)) all --no-print-directory

# Standard, non-optimized release build
.PHONY: release
release: dirs
	@echo "Beginning release build"
	@$(MAKE) -f $(lastword $(MAKEFILE_LIST)) all --no-print-directory

# Create the directories used in the build
.PHONY: dirs
dirs:
	@echo "Creating directories"
	@mkdir -p $(dir $(OBJECTS))
	@mkdir -p $(BUILD_PATH)

# Removes all build files
.PHONY: clean
clean:
	@echo "Deleting $(BIN_NAME) symlink"
	@$(RM) $(BIN_NAME)
	@echo "Deleting directories"
	@$(RM) -r obj

# Main rule, checks the executable and symlinks to the output
all: $(BUILD_PATH)/$(BIN_NAME)
	@echo "Making symlink: $(BIN_NAME) -> $<"
	@$(RM) $(BIN_NAME)
	@ln -s $(BUILD_PATH)/$(BIN_NAME) $(BIN_NAME)

# Link the executable
$(BUILD_PATH)/$(BIN_NAME): $(OBJECTS)
	@echo "Linking: $@"
	$(CMD_PREFIX)$(CXX) $(OBJECTS) $(LDFLAGS) -o $@

# Add dependency files, if they exist
-include $(DEPS)

# Source file rules
# After the first compilation they will be joined with the rules from the
# dependency files to provide header dependencies
$(BUILD_PATH)/%.o: %.$(SRC_EXT)
	@echo "Compiling: $< -> $@"
	$(CMD_PREFIX)$(CXX) $(CXXFLAGS) $(INCLUDES) -MP -MMD -c $< -o $@

