# Colors for output
RED :='\033[0;31m'
GREEN 	:='\033[0;32m'
BLUE 	:='\033[0;34m'
YELLOW 	:='\033[1;33m'
NC 		:='\033[0m' # No Color


# These variables should be passed from the root Makefile
#  Control flags
DRY_RUN ?= 1
DIR_PATH ?= ../

# DFP (Device Family Pack) configuration
DFP_DIR := $(DFP)
DFP_INCLUDE := $(DFP)/include

# Helper variables for cross-platform compatibility
space := $(empty) $(empty)
comma := ,

# Detect operating system for cross-platform compatibility
ifeq ($(OS),Windows_NT)
	detected_OS := Windows
ifeq ($(DRY_RUN),1)
	MKDIR = powershell -Command "New-Item -ItemType Directory -Path '$(subst /,\,$(1))' -Force | Out-Null; Write-Host 'Created directory: $(subst /,\,$(1))' -ForegroundColor Red"
	RMDIR = powershell -Command "if (Test-Path '$(subst /,\,$(1))') { Write-Host 'Would delete: ' + '$(subst /,\,$(1))' -ForegroundColor Red }"
	MOVE =  powershell -Command "if (Test-Path '$(subst /,\,$(1))') { Write-Host 'Would move: ' + '$(subst /,\,$(1))' + ' to ' + '$(subst /,\,$(2))' -ForegroundColor Red }"
else
	MKDIR = powershell -Command "New-Item -ItemType Directory -Path '$(subst /,\,$(1))' -Force | Out-Null"
	RMDIR = powershell -Command "if (Test-Path '$(subst /,\,$(1))') {Write-Host 'Deleted: ' + '$(subst /,\,$(1))' -ForegroundColor Green; Remove-Item -Recurse -Force '$(subst /,\,$(1))' }"
	MOVE = powershell -Command "if (Test-Path '$(subst /,\,$(1))') { Move-Item -Path '$(subst /,\,$(1))' -Destination '$(subst /,\,$(2))' -Force }"
#	MOVE = if exist "$(subst /,\,$(1))" move "$(subst /,\,$(1))" "$(subst /,\,$(2))"
endif
endif

# RM command with dry run and logging support to remove files matching a pattern in a directory
ifeq ($(OS),Windows_NT)
	RM = powershell -NoProfile -ExecutionPolicy Bypass -Command \
	"\$$dryRun = '$(DRY_RUN)' -eq '1'; \
	\$$logPath = \$$env:LOG_PATH; \
	\$$items = Get-ChildItem -Path '$(subst /,\,$(1))' -Recurse -Filter '$(2)' -ErrorAction SilentlyContinue; \
	foreach (\$$item in \$$items) { \
		if (\$$dryRun) { \
		Write-Host ('Would delete: ' + \$$item.FullName) -ForegroundColor Red; \
		if (\$$logPath) { Add-Content -Path \$$logPath -Value ('Would delete: ' + \$$item.FullName) } \
		} else { \
		Remove-Item \$$item.FullName -Force -ErrorAction SilentlyContinue; \
		if (Test-Path \$$item.FullName) { \
			Write-Host ('Warning: Could not delete ' + \$$item.FullName) -ForegroundColor Yellow; \
			if (\$$logPath) { Add-Content -Path \$$logPath -Value ('Warning: Could not delete ' + \$$item.FullName) } \
		} else { \
			Write-Host ('Deleted: ' + \$$item.FullName) -ForegroundColor Green; \
			if (\$$logPath) { Add-Content -Path \$$logPath -Value ('Deleted: ' + \$$item.FullName) } \
		} \
		} \
	}"
	PATH_SEP = \\
	NULL_DEVICE = nul
else
	detected_OS := $(shell uname -s)
	MKDIR = mkdir -p $(1)
	RMDIR = rm -rf $(1)
	RM = bash -c '\
		DRY_RUN=$(DRY_RUN); \
		TARGET_DIR="$(1)"; \
		FILTER="$(2)"; \
		COUNT=0; \
		for FILE in $$(find $$TARGET_DIR -type f -name "$$FILTER"); do \
		if [ "$$DRY_RUN" = "1" ]; then \
			echo -e "$(RED)Would delete:$(NC) $$FILE"; \
		else \
			rm -f "$$FILE"; \
			if [ -e "$$FILE" ]; then \
			echo -e "$(YELLOW)Warning: Could not delete:$(NC) $$FILE"; \
			else \
			echo -e "$(GREEN)Deleted:$(NC) $$FILE"; \
			fi; \
		fi; \
		COUNT=$$((COUNT + 1)); \
		done; \
		echo -e "$(NC)Total files processed:$(NC) $$COUNT"'

	MOVE = if [ -f "$(1)" ]; then mv "$(1)" "$(2)"; fi
	PATH_SEP = /
	NULL_DEVICE = /dev/null
endif

# Project directories expected in the project.
# These directories are created if they do not exist when "make build_dir" is run.
# The directories are used to store object files, binaries, source files, include files, and other files.
# The directories are created relative to the project root directory.
# The project root directory is expected to be one level above the srcs directory.
# The project root directory is expected to contain the srcs, objs, incs, bins, libs, and other directories.
# The objs directory is used to store object files.
# The incs directory is used to store header files.
# The bins directory is used to store binaries.
# The libs directory is used to store static libraries (.a files).
# The other directory is used to store other files such as maps and XML files.
ROOT     := ..

# Build configuration: Default, Debug, or Release
# Controls optimization level and output directory structure
BUILD_CONFIG ?= Default

# Output directories based on configuration
BASE_BIN_DIR  := $(ROOT)/bins
BASE_LIB_DIR  := $(ROOT)/libs
BASE_OBJ_DIR  := $(ROOT)/objs
BASE_OUT_DIR  := $(ROOT)/other

BIN_DIR  := $(BASE_BIN_DIR)/$(BUILD_CONFIG)
LIB_DIR  := $(BASE_LIB_DIR)/$(BUILD_CONFIG)
OBJ_DIR  := $(BASE_OBJ_DIR)/$(BUILD_CONFIG)
OUT_DIR  := $(BASE_OUT_DIR)/$(BUILD_CONFIG)

INC_DIR  := $(ROOT)/incs
SRC_DIR  := $(ROOT)/srcs

# Library control: set USE_SHARED_LIB=1 to link against pre-built library
# If enabled, builds library from libs/*.c and links against it
# If disabled, compiles all sources directly into executable
USE_SHARED_LIB ?= 0


# Source files and object files
# The source files are expected to be in the srcs directory & sub-directories.
# The source files are expected to have the .c extension.
# The object file list is created from the SRCS variable with the .o extension inplaceof the .c extension.
# Dynamically find all .c files using Make functions (up to 6 levels deep for peripheral libraries)
define get_c_files
$(wildcard $(1)/*.c) $(wildcard $(1)/*/*.c) $(wildcard $(1)/*/*/*.c) $(wildcard $(1)/*/*/*/*.c) $(wildcard $(1)/*/*/*/*/*.c) $(wildcard $(1)/*/*/*/*/*/*.c)
endef
# Get all source files and filter out test files for production CNC build
ALL_SRCS := $(call get_c_files,$(SRC_DIR))
EXCLUDED_FILES := $(SRC_DIR)/gcode_test_app.c $(SRC_DIR)/gcode_test_framework.c $(SRC_DIR)/gcode_parser_dma.c

# Library source files (placed in BASE_LIB_DIR folder - these can be built as separate library)
LIB_SRCS := $(wildcard $(BASE_LIB_DIR)/*.c)
LIB_OBJS := $(LIB_SRCS:$(BASE_LIB_DIR)/%.c=$(OBJ_DIR)/libs/%.o)

# Main application sources (exclude library sources if USE_SHARED_LIB=1)
ifeq ($(USE_SHARED_LIB),1)
    # Link against pre-built library - exclude library sources from main build
    SRCS := $(filter-out $(EXCLUDED_FILES),$(ALL_SRCS))
    OBJS := $(SRCS:$(SRC_DIR)/%.c=$(OBJ_DIR)/%.o)
    # Add library to link command
    LINK_LIBS := -L"$(LIB_DIR)" -lCS23shared
else
    # Compile everything directly (include library sources in main build)
    SRCS := $(filter-out $(EXCLUDED_FILES),$(ALL_SRCS))
    OBJS := $(SRCS:$(SRC_DIR)/%.c=$(OBJ_DIR)/%.o)
    OBJS += $(LIB_OBJS)
    LINK_LIBS :=
endif


# The assembly files are expected to be in the srcs directory & sub-directories.
# Dynamically find all .S files using Make functions (up to 4 levels deep)
define get_s_files
$(wildcard $(1)/*.S) $(wildcard $(1)/*/*.S) $(wildcard $(1)/*/*/*.S) $(wildcard $(1)/*/*/*/*.S)
endef
ASM := $(call get_s_files,$(SRC_DIR))
ASMS := $(ASM:$(SRC_DIR)/%.S=$(OBJ_DIR)/%.o)

# The assembly object files are created from the ASM variable with the .o extension inplace of the .S extension.
# The assembly object files are added to the OBJS variable.
# This allows the assembly files to be compiled and linked with the C source files.
# The assembly files are expected to be in the srcs directory & sub-directories.
# The assembly files are expected to have the .S extension.
# The assembly files are expected to be compiled with the same compiler as the C source files.
# The assembly files are expected to be compiled with the same flags as the C source files.
OBJS += $(ASMS)

# Compiler and flags
COMPILER  := c99
ifeq ($(COMPILER),c99)
CC := "$(COMPILER_LOCATION)/xc32-gcc"
MCU := -mprocessor=$(DEVICE)
STD := c99

# Optimization level (passed from root Makefile, defaults to 1)
OPT_LEVEL ?= 1

# Configuration-specific compiler flags
# Only validate BUILD_CONFIG when actually building (not for build_dir, clean, etc.)
ifneq ($(filter-out build_dir clean clean_all rem_dir mk_dir debug debug_path,$(MAKECMDGOALS)),)
  ifeq ($(BUILD_CONFIG),Debug)
      # Debug: Full debug symbols, no optimization, debug defines
      OPT_FLAGS := -g3 -O0
      CONFIG_DEFINES := -DDEBUG -DXPRJ_Debug=Debug
      # Debug builds enable DEBUG_MOTION_BUFFER by default
      DEBUG_MOTION_BUFFER := 1
      $(info *** DEBUG BUILD: -g3 -O0 with debug symbols ***)
  else ifeq ($(BUILD_CONFIG),Release)
      # Release: Uses OPT_LEVEL from root Makefile (default: -O1)
      OPT_FLAGS := -g -O$(OPT_LEVEL)
      CONFIG_DEFINES := -DXPRJ_Release=Release
      $(info *** RELEASE BUILD: -g -O$(OPT_LEVEL) ***)
  else
      # Invalid configuration - error out
      $(error Invalid BUILD_CONFIG: $(BUILD_CONFIG). Use Debug or Release)
  endif
endif

# Add DEBUG_MOTION_BUFFER if enabled (either from root Makefile or Debug build)
ifeq ($(DEBUG_MOTION_BUFFER),1)
    CONFIG_DEFINES += -DDEBUG_MOTION_BUFFER
    $(info *** DEBUG_MOTION_BUFFER enabled ***)
endif

# Map root policy flag to compile-time define to optionally force exact-stop behavior
ifeq ($(DISABLE_JUNCTION_LOOKAHEAD),1)
    CONFIG_DEFINES += -DDEBUG_DISABLE_JUNCTION_LOOKAHEAD
    $(info *** DEBUG_DISABLE_JUNCTION_LOOKAHEAD (exact-stop) enabled ***)
endif

FLAGS := -Werror -Wall -MP -MMD $(CONFIG_DEFINES)

else
CC := "$(COMPILER_LOCATION)/xc32"
MCU := -mprocessor=$(DEVICE)
STD := c90
endif


# Assign all Include directories dynamically, first run "make build_dir" from terminal.
# Get all directories under INC_DIR recursively (up to 4 levels deep)
define get_inc_dirs
$(sort $(dir $(wildcard $(1)/*/)) $(dir $(wildcard $(1)/*/*/)) $(dir $(wildcard $(1)/*/*/*/)) $(dir $(wildcard $(1)/*/*/*/*/)))
endef

INC_SUBDIRS := $(call get_inc_dirs,$(INC_DIR))
# Remove trailing slashes and add -I prefix for each directory
INC_FLAGS := $(foreach d,$(patsubst %/,%,$(INC_SUBDIRS)),-I"$(d)")
INCS := -I"$(INC_DIR)" $(INC_FLAGS) -I"$(DFP_INCLUDE)"


#Direct the compiler outputs for .o files from .c or .cpp code  -x c
DIRECT_OBJ := $(CC) $(OPT_FLAGS) -c $(MCU) -ffunction-sections -fdata-sections -fno-common $(INCS) $(FLAGS) -mdfp="$(DFP)"
			

LINKER_SCRIPT := $(DFP)/xc32/$(DEVICE)/p$(DEVICE).ld
DIRECT_LINK := $(CC) $(MCU) -nostartfiles $(CONFIG_DEFINES) -mdfp="$(DFP)" -Wl,--defsym=__MPLAB_BUILD=1,--script="$(LINKER_SCRIPT)",--defsym=_min_heap_size=$(HEAP_SIZE),--defsym=_min_stack_size=$(STACK_SIZE),--gc-sections,--no-code-in-dinit,--no-dinit-in-serial-mem,-Map="$(OUT_DIR)/$(BUILD_CONFIG).map",--memorysummary,$(OUT_DIR)/memoryfile.xml 



DIRECT_ASM := -c $(CONFIG_DEFINES) -Wa,--defsym=__MPLAB_BUILD=1,-MD=$(OBJ_DIR)/startup/startup.o.asm.d,--gdwarf-2 -mdfp="$(DFP)" -MMD -MF $(OBJ_DIR)/startup/startup.o.d

# Default target: build executable
$(BIN_DIR)/$(MODULE): $(OBJS)
	@echo "Building project for $(DEVICE)"
ifeq ($(USE_SHARED_LIB),1)
	@echo "Linking with pre-built shared library: libCS23shared.a"
	$(DIRECT_LINK) -o $@ $^ $(LINK_LIBS)
else
	@echo "Linking object files to create the final executable"
	$(DIRECT_LINK) -o $@ $^
endif
	@echo "Build complete. Output is in $(BIN_DIR)"

# Compile all source files to object files
$(OBJ_DIR)/%.o: $(SRC_DIR)/%.c
	@echo "Compiling $< to $@"
	@$(call MKDIR,$(dir $@))
	$(DIRECT_OBJ) -MF $(@:.o=.d) $< -o $@
	@echo "Object file created: $@"

# Compile library source files (from BASE_LIB_DIR folder - not config-specific)
$(OBJ_DIR)/libs/%.o: $(BASE_LIB_DIR)/%.c
	@echo "Compiling library source $< to $@"
	@$(call MKDIR,$(dir $@))
	$(DIRECT_OBJ) -MF $(@:.o=.d) $< -o $@
	@echo "Library object file created: $@"

$(OBJ_DIR)/%.o: $(SRC_DIR)/%.S
	@echo "Compiling assembly file $< to object file $@"
	@$(call MKDIR,$(dir $@))
	$(CC) $(MCU) $(DIRECT_ASM) -o $@ $<
	@echo "Object file created: $@"

# Build shared library from libs/*.c files
$(LIB_DIR)/libCS23shared.a: $(LIB_OBJS)
	@echo "Creating shared library from $(words $(LIB_OBJS)) object file(s)"
	@echo "Library sources: $(LIB_SRCS)"
	@$(call MKDIR,$(LIB_DIR))
	"$(COMPILER_LOCATION)/xc32-ar" rcs $@ $^
	@echo "Shared library created: $@"
	@echo "Library size:"
ifeq ($(OS),Windows_NT)
	@powershell -Command "Get-Item '$@' | Select-Object Name, @{Name='Size(KB)';Expression={[math]::Round(\$$_.Length/1KB,2)}}"
else
	@ls -lh $@
endif

# Target to build only the shared library
shared_lib: $(LIB_DIR)/libCS23shared.a
	@echo "Shared library build complete!"



.PHONY: clean build_dir debug help platform rem_dir shared_lib

# Show platform-specific configuration
platform:
	@echo "Cross-platform build configuration:"
	@echo "  Detected OS: $(detected_OS)"
	@echo "  Path separator: $(PATH_SEP)"
	@echo "  Null device: $(NULL_DEVICE)"
	@echo "  MKDIR command: $(value MKDIR)"
	@echo "  RMDIR command: $(value RMDIR)"
	@echo "  RM command: $(value RM)"
	@echo "  MOVE command: $(value MOVE)"

# Create the build directories if they do not exist
# This target is used to create the necessary directories for the build process.
# It creates the OBJ_DIR, BIN_DIR, SRC_DIR, INC_DIR, and OUT_DIR
# It also creates subdirectories in OBJ_DIR and INC_DIR for each subdirectory in SRC_DIR
# This is useful for organizing the build output and include files.
# To run this target, use: make build_dir
# Get all directories under SRC_DIR dynamically (similar to how we get source files)
SRC_DIRS := $(sort $(dir $(wildcard $(SRC_DIR)/*/)) $(dir $(wildcard $(SRC_DIR)/*/*/)) $(dir $(wildcard $(SRC_DIR)/*/*/*/)) $(dir $(wildcard $(SRC_DIR)/*/*/*/*/)))
# Filter out startup directory from automatic creation and convert to relative paths
SRC_SUBDIRS := $(sort $(filter-out startup/,$(SRC_DIRS:$(SRC_DIR)/%=%)))

build_dir: 
	@echo "Creating build directories ($(detected_OS))"
	@echo "Creating base directories..."
	@$(call MKDIR,$(BASE_BIN_DIR))
	@$(call MKDIR,$(BASE_LIB_DIR))
	@$(call MKDIR,$(BASE_OBJ_DIR))
	@$(call MKDIR,$(BASE_OUT_DIR))
	@$(call MKDIR,$(SRC_DIR))
	@$(call MKDIR,$(INC_DIR))
	@echo "Creating bins/Debug and bins/Release for final executables..."
	@$(call MKDIR,$(BASE_BIN_DIR)/Debug)
	@$(call MKDIR,$(BASE_BIN_DIR)/Release)
	@echo "Creating configuration-specific working directories for $(BUILD_CONFIG)..."
	@$(call MKDIR,$(LIB_DIR))
	@$(call MKDIR,$(OBJ_DIR))
	@$(call MKDIR,$(OUT_DIR))
	@echo "Creating subdirectories in OBJ_DIR and INC_DIR based on SRC_DIR structure"
	@$(foreach subdir,$(SRC_SUBDIRS),$(call MKDIR,$(OBJ_DIR)/$(subdir)) && $(call MKDIR,$(INC_DIR)/$(subdir)) &&) echo "Created peripheral directories"
	@echo "Moving header files from src subdirectories to corresponding inc subdirectories"
	@$(foreach subdir,$(SRC_SUBDIRS),$(foreach header,$(wildcard $(SRC_DIR)/$(subdir)*.h),$(call MOVE,$(header),$(INC_DIR)/$(subdir)) &&)) echo "Headers moved"
	@echo "Build directories created successfully"




clean:
	@echo "Cleaning up object files, binaries, and libraries ($(detected_OS)) with DRY_RUN=$(DRY_RUN)"
	@$(call RM,$(BIN_DIR),*)
	@$(call RM,$(LIB_DIR),*.a)
	@$(call RM,$(OBJ_DIR),*.o)
	@$(call RM,$(OUT_DIR),*)
	@echo "Clean complete."


define clear_build_dir
	-@rm -rf $(BIN_DIR)/* $(OBJ_DIR)/* $(OUT_DIR)/* 2>/dev/null || true
endef

rem_dir:
	@echo "DRY_RUN is $(DRY_RUN). The following directories would be removed: $(DIR_PATH)"
	@$(call RMDIR,$(DIR_PATH))

mk_dir:
	@echo "Creating directory: $(DIR_PATH)"
	@$(call MKDIR,$(DIR_PATH))


###################################################################################################
##			                                     DEBUGGING 							             ##
###################################################################################################
# Function to convert paths based on OS
# Usage: $(call TEST,YourPathHere)
ifeq ($(detected_OS), Windows)
TEST = $(subst /,\,$(1))
else
TEST = $(1)
endif
debug_path:
	@echo "Debugging path variables: $(DIR_PATH)"
	@echo "$(DIR_PATH) => $(call TEST,$(DIR_PATH))"



# Display the source files, object files, and include directories
debug:
	@echo "Build system debug info ($(detected_OS)):"
	@echo "Build configuration: $(BUILD_CONFIG)"
	@echo "Use shared library: $(USE_SHARED_LIB)"
	@echo "Executable target: $(BIN_DIR)/$(MODULE)"
	@echo "Library target: $(LIB_DIR)/libCS23shared.a"
	@echo "Optimization flags: $(OPT_FLAGS)"
	@echo "Config defines: $(CONFIG_DEFINES)"
	@echo "Source files:"
	@$(foreach src,$(SRCS),echo "  $(src)" &&) echo ""
	@echo "Object files:"
	@$(foreach obj,$(OBJS),echo "  $(obj)" &&) echo ""
	@echo "Include directories:"
	@$(foreach inc,$(subst -I",,$(subst ",,$(INCS))),echo "  -I"$(inc)"" &&) echo ""
	@echo "Include subdirectories found:"
	@$(foreach dir,$(INC_SUBDIRS),echo "  $(dir)" &&) echo ""
	@echo "Include flags generated:"
	@$(foreach flag,$(INC_FLAGS),echo "  $(flag)" &&) echo ""
	@echo "Source subdirectories found:"
	@$(foreach dir,$(SRC_SUBDIRS),echo "  $(dir)" &&) echo ""
	@echo "DFP Include path:"
	@echo "  $(DFP_INCLUDE)"
	@echo "Linker script:"
	@echo "  $(LINKER_SCRIPT)"


# For xc32 Compiler help with less use: make help less
# For xc32 Compiler help without less use: make help
help:
	@echo "Displaying help information for xc32-gcc"
ifeq ($(filter less,$(MAKECMDGOALS)),less)
	xc32-gcc --help | less
else
	xc32-gcc --help
endif




##################################################################################################
##                       Table 5-6. Kind-of-Output Control Options								##
##################################################################################################
# Option      |  Definition
# -----------------------------------------------------------------------------------------------
# -c          |  Stop compilation before the link step, producing an intermediate file.
# -E          |  Stop compilation after preprocessing, producing a preprocessed file.
# --help      |  Print a description of the command line options.
# -o file     |Place the output in a file with the specified name.
# -S          |  Stop compilation before the assembly step, producing an assembly file output.
# -specs=file |  Overrides the standard specs file.
# -v          |  Print the commands executed during each stage of compilation.
# --version   |  Show version information then quit.
# -x          |  Specify the language of a source file regardless of its file extension.
#################################################################################################


#################################################################################################
##								Understanding Color Codes 							           ##		
#################################################################################################
# The color code '\033[0;31m' is used to set the text color to red in terminal output.
# It is composed of several components that define the color and style of the text.
# Here is a breakdown of the '\033[0;31m' color code:
# ----------------------------------------------------------------------------------------------
# -Component    	| Meaning
# ----------------------------------------------------------------------------------------------
# \033				| Escape character (octal for ASCII 27, same as \e)
# [					| Begins the control sequence
# 0					| Reset all attributes (like bold, underline, etc.)
# ;					| Separator between attributes
# 31				| Set foreground text color to red
# m					| Marks the end of the formatting sequence

#################################################################################################
##								Common Color Codes '\033[0;31m'					              ##	
#################################################################################################
# -Color		|Foreground	|Background
# -----------------------------------------------------------------------------------------------
# -Black		|30		    |40
# -Red			|31		    |41
# -Green		|32		    |42
# -Yellow		|33		    |43
# -Blue			|34		    |44
# -Magenta		|35		    |45
# -Cyan			|36		    |46
# -White		|37		    |47
# -Gray			|90		    |100
# -Light Red	|91		    |101
# -Light Green	|92		    |102
# -Light Yellow|93		    |103
# -Light Blue	|94		    |104
# -Light Magenta|95		    |105
# -Light Cyan	|96		    |106
# -Light White	|97		    |107
# -----------------------------------------------------------------------------------------------
#################################################################################################
##✨											Style Codes 								   ✨##
#################################################################################################
# -Style		|	Code
# -----------------------------------------------------------------------------------------------
# -Reset		|	0
# -Bold			|	1
# -Underline	|	4
# -Blink		|	5
# -Reverse		|	7
# -Concealed	|	8
# -----------------------------------------------------------------------------------------------
#################################################################################################