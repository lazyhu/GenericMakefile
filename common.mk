
####### Generally should not need to edit below this line #######
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

# Path to the debug/release build directory
DBUILD_PATH = obj/debug
RBUILD_PATH = obj/release

# Combine compiler and linker flags
debug: export CXXFLAGS := $(CXXFLAGS) $(COMPILE_FLAGS) $(DCOMPILE_FLAGS)
debug: export LDFLAGS := $(LDFLAGS) $(LINK_FLAGS) $(DLINK_FLAGS)
release: export CXXFLAGS := $(CXXFLAGS) $(COMPILE_FLAGS) $(RCOMPILE_FLAGS)
release: export LDFLAGS := $(LDFLAGS) $(LINK_FLAGS) $(RLINK_FLAGS)

# Build and output paths
debug: export BUILD_PATH := $(DBUILD_PATH)
release: export BUILD_PATH := $(RBUILD_PATH)
clean : export BUILD_PATH := $(DBUILD_PATH)
rclean: export BUILD_PATH := $(RBUILD_PATH)

# Find source files in the source directory, sorted by most recently modified
SOURCES = $(shell find $(SRC_DIRS) -name '*.$(SRC_EXT)' -printf '%T@\t%p\n' | sort -k 1nr | cut -f2-)

# Set the object file names, with the source directory stripped
# from the path, and the build path prepended in its place
OBJECTS = $(SOURCES:%.$(SRC_EXT)=$(BUILD_PATH)/%.o)
# Set the dependency files that will be used to add header dependencies
DEPS = $(OBJECTS:.o=.d) 

# Debug build for gdb debugging
.PHONY: debug
debug: dirs
	@$(MAKE) -f $(firstword $(MAKEFILE_LIST)) all --no-print-directory

# Standard, non-optimized release build
.PHONY: release
release: dirs
	@$(MAKE) -f $(firstword $(MAKEFILE_LIST)) all --no-print-directory

# Create the directories used in the build
.PHONY: dirs
dirs:
	@echo "# creating directories"
	$(CMD_PREFIX)mkdir -p $(dir $(OBJECTS))
	$(CMD_PREFIX)mkdir -p $(BUILD_PATH)

# Removes all build files
.PHONY: clean
clean:
	@$(MAKE) -f $(firstword $(MAKEFILE_LIST)) all_clean --no-print-directory

.PHONY: rclean
rclean:
	@$(MAKE) -f $(firstword $(MAKEFILE_LIST)) all_clean --no-print-directory

all_clean:
	@echo "# cleaning"
	$(CMD_PREFIX)$(RM) $(BIN_NAME)
	$(CMD_PREFIX)$(RM) $(BUILD_PATH)/$(BIN_NAME)
	$(CMD_PREFIX)$(RM) $(SOURCES:%.$(SRC_EXT)=$(BUILD_PATH)/%.o)
	$(CMD_PREFIX)$(RM) $(SOURCES:%.$(SRC_EXT)=$(BUILD_PATH)/%.d)

# Main rule, checks the executable and symlinks to the output
all: $(BUILD_PATH)/$(BIN_NAME)
	@echo "# making symlink: $(BIN_NAME) -> $<"
	$(CMD_PREFIX)$(RM) $(BIN_NAME)
	$(CMD_PREFIX)ln -s $(BUILD_PATH)/$(BIN_NAME) $(BIN_NAME)

# Link the executable
$(BUILD_PATH)/$(BIN_NAME): $(OBJECTS)
	@echo "# linking: $@"
	$(CMD_PREFIX)$(CXX) $(OBJECTS) $(LDFLAGS) -o $@

# Add dependency files, if they exist
-include $(DEPS)

# Source file rules
# After the first compilation they will be joined with the rules from the
# dependency files to provide header dependencies
$(BUILD_PATH)/%.o: %.$(SRC_EXT)
	@echo "# compiling: $< -> $@"
	$(CMD_PREFIX)$(CXX) $(CXXFLAGS) $(INCLUDES) -MP -MMD -c $< -o $@
