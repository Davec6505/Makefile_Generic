#!/bin/bash
# PIC32MZ Project Generator - Simple Structure
# Cross-platform project generator for PIC32MZ embedded projects

# Color definitions for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

usage() {
    echo "Usage: $0 <project_name> [device] [output_directory] [mikroc]"
    echo ""
    echo "Arguments:"
    echo "  project_name     Name of the project to generate (required)"
    echo "  device          PIC32MZ device (default: 32MZ1024EFH064)"
    echo "  output_directory Output directory (default: current directory)"
    echo "  mikroc          Include startup files for MikroC compatibility (optional)"
    echo ""
    echo "Examples:"
    echo "  $0 MyProject"
    echo "  $0 MyProject 32MZ2048EFH064"
    echo "  $0 MyProject 32MZ1024EFH064 /home/projects"
    echo "  $0 MyProject 32MZ1024EFH064 /home/projects mikroc"
}

create_directories() {
    local project_root="$1"
    local include_startup="$2"
    
    echo -e "${BLUE}Creating directory structure...${NC}"
    
    # Create simple directory structure - first level only
    mkdir -p "$project_root"/{srcs,incs,objs,bins,other,docs}
    
    # Add startup directory if mikroc option is enabled
    if [ "$include_startup" = "true" ]; then
        mkdir -p "$project_root/srcs/startup"
        echo -e "${YELLOW}  + Added startup directory for MikroC support${NC}"
    fi
    
    echo -e "${GREEN}✓ Directory structure created${NC}"
}

create_root_makefile() {
    local project_root="$1"
    local project_name="$2"
    local device="$3"
    
    echo -e "${BLUE}Creating root Makefile...${NC}"
    
    cat > "$project_root/Makefile" << EOF
# Name of the project binary
MODULE    	:= $project_name

# Device configuration
DEVICE 		:= $device

# Cross-platform compiler and DFP paths
ifeq (\$(OS),Windows_NT)
    COMPILER_LOCATION := C:/Program Files/Microchip/xc32/v4.60/bin
    DFP_LOCATION := C:/Program Files/Microchip/MPLABX/v6.25/packs
else
    COMPILER_LOCATION := /opt/microchip/xc32/v4.60/bin
    DFP_LOCATION := /opt/microchip/mplabx/v6.25/packs
endif
DFP := \$(DFP_LOCATION)/Microchip/PIC32MZ-EF_DFP/1.4.168

# Build system
BUILD=make
CLEAN=make clean
BUILD_DIR=make build_dir

all:
	@echo "######  BUILDING   ########"
	cd srcs && \$(BUILD) COMPILER_LOCATION="\$(COMPILER_LOCATION)" DFP_LOCATION="\$(DFP_LOCATION)" DFP="\$(DFP)" DEVICE=\$(DEVICE) MODULE=\$(MODULE)
	@echo "###### BIN TO HEX ########"
	cd bins && "\$(COMPILER_LOCATION)/xc32-bin2hex" \$(MODULE)
	@echo "######  BUILD COMPLETE   ########"

build_dir:
	@echo "#######BUILDING DIRECTORIES FOR OUTPUT BINARIES#######"
	cd srcs && \$(BUILD_DIR)

debug:
	@echo "#######DEBUGGING OUTPUTS#######"
	cd srcs && \$(BUILD) debug COMPILER_LOCATION="\$(COMPILER_LOCATION)" DFP_LOCATION="\$(DFP_LOCATION)" DFP="\$(DFP)" DEVICE=\$(DEVICE) MODULE=\$(MODULE)

platform:
	@echo "#######PLATFORM INFO#######"
	cd srcs && \$(BUILD) platform COMPILER_LOCATION="\$(COMPILER_LOCATION)" DFP_LOCATION="\$(DFP_LOCATION)" DFP="\$(DFP)" DEVICE=\$(DEVICE) MODULE=\$(MODULE)

clean:
	@echo "####### CLEANING OUTPUTS #######"
	cd srcs && \$(CLEAN)
	@echo "####### REMOVING BUILD ARTIFACTS #######"
ifeq (\$(OS),Windows_NT)
	@if exist "bins\\*" del /q "bins\\*" >nul 2>&1
	@if exist "objs\\*" rmdir /s /q "objs" >nul 2>&1 && mkdir "objs" >nul 2>&1
	@if exist "other\\*" del /q "other\\*" >nul 2>&1
else
	@rm -rf bins/* objs/* other/* 2>/dev/null || true
endif

.PHONY: all build_dir clean debug platform
EOF
    
    echo -e "${GREEN}✓ Root Makefile created${NC}"
}

create_srcs_makefile() {
    local project_root="$1"
    local include_startup="$2"
    
    if [ "$include_startup" = "true" ]; then
        cat > "$project_root/srcs/Makefile" << 'EOF'
# Simple Makefile for PIC32MZ project with startup support
# DFP (Device Family Pack) configuration
DFP_DIR := $(DFP)
DFP_INCLUDE := $(DFP)/include

# Detect operating system for cross-platform compatibility
ifeq ($(OS),Windows_NT)
    detected_OS := Windows
    MKDIR = if not exist "$(subst /,\,$(1))" mkdir "$(subst /,\,$(1))"
    RMDIR = if exist "$(subst /,\,$(1))" rmdir /s /q "$(subst /,\,$(1))"
    RM = if exist "$(subst /,\,$(1))" del /q "$(subst /,\,$(1))"
    NULL_DEVICE = nul
else
    detected_OS := $(shell uname -s)
    MKDIR = mkdir -p $(1)
    RMDIR = rm -rf $(1)
    RM = rm -f $(1)
    NULL_DEVICE = /dev/null
endif

# Project directories
ROOT     := ..
OBJ_DIR  := $(ROOT)/objs
INC_DIR  := $(ROOT)/incs
BIN_DIR  := $(ROOT)/bins
SRC_DIR  := $(ROOT)/srcs
OUT_DIR  := $(ROOT)/other

# Source files (current directory and startup)
SRCS := $(wildcard *.c) $(wildcard startup/*.c)
OBJS := $(SRCS:%.c=$(OBJ_DIR)/%.o)

# Assembly files in startup directory
ASM_SRCS := $(wildcard startup/*.S)
ASM_OBJS := $(ASM_SRCS:%.S=$(OBJ_DIR)/%.o)
OBJS += $(ASM_OBJS)

# Compiler and flags
CC := "$(COMPILER_LOCATION)/xc32-gcc"
MCU := -mprocessor=$(DEVICE)
FLAGS := -Werror -Wall -MP -MMD -g -O1 -ffunction-sections -fdata-sections -fno-common

# Include directories (simple structure)
INCS := -I"$(INC_DIR)" -I"$(DFP_INCLUDE)"

# Compiler command for object files
COMPILE_OBJ := $(CC) -x c -c $(MCU) $(FLAGS) $(INCS) -DXPRJ_default=default -mdfp="$(DFP)"

# Assembly compiler command
COMPILE_ASM := $(CC) $(MCU) -c -DXPRJ_default=default -Wa,--defsym=__MPLAB_BUILD=1,--gdwarf-2 -mdfp="$(DFP)" -MMD

# Linker script and command
LINKER_SCRIPT := $(DFP)/xc32/$(DEVICE)/p32MZ1024EFH064.ld
LINK_CMD := $(CC) $(MCU) -nostartfiles -DXPRJ_default=default -mdfp="$(DFP)" \
            -Wl,--defsym=__MPLAB_BUILD=1,--script="$(LINKER_SCRIPT)",--defsym=_min_heap_size=512,--gc-sections,--no-code-in-dinit,--no-dinit-in-serial-mem,-Map="$(OUT_DIR)/production.map",--memorysummary,$(OUT_DIR)/memoryfile.xml

# Default target
$(BIN_DIR)/$(MODULE): $(OBJS)
	@echo "Linking $(MODULE) for $(DEVICE)"
	$(LINK_CMD) -o $@ $^ 
	@echo "Build complete: $@"

# Compile C source files
$(OBJ_DIR)/%.o: %.c
	@echo "Compiling $< to $@"
	@$(call MKDIR,$(dir $@))
	$(COMPILE_OBJ) -MF $(@:.o=.d) $< -o $@

# Compile assembly files
$(OBJ_DIR)/%.o: %.S
	@echo "Compiling assembly $< to $@"
	@$(call MKDIR,$(dir $@))
	$(COMPILE_ASM) -MF $(@:.o=.d) $< -o $@

.PHONY: clean build_dir debug help platform

# Create build directories
build_dir: 
	@echo "Creating build directories ($(detected_OS))"
	@$(call MKDIR,$(OBJ_DIR))
	@$(call MKDIR,$(OBJ_DIR)/startup)
	@$(call MKDIR,$(BIN_DIR))
	@$(call MKDIR,$(OUT_DIR))
	@echo "Build directories created"

# Debug information
debug:
	@echo "Build system debug info ($(detected_OS)):"
	@echo "Source files: $(SRCS)"
	@echo "Assembly files: $(ASM_SRCS)"
	@echo "Object files: $(OBJS)"
	@echo "Include dirs: $(INCS)"
	@echo "DFP Include: $(DFP_INCLUDE)"
	@echo "Linker script: $(LINKER_SCRIPT)"

# Platform info
platform:
	@echo "Cross-platform build configuration:"
	@echo "  Detected OS: $(detected_OS)"
	@echo "  Compiler: $(CC)"
	@echo "  Device: $(DEVICE)"
	@echo "  Startup support: ENABLED"

# Help
help:
	@echo "Available targets:"
	@echo "  all (default) - Build the project"
	@echo "  build_dir     - Create build directories"
	@echo "  clean         - Clean build artifacts"
	@echo "  debug         - Show debug information"
	@echo "  platform      - Show platform information"
	@echo "  help          - Show this help"

# Clean
clean:
	@echo "Cleaning build artifacts ($(detected_OS))"
	@$(call RM,$(BIN_DIR)/*) 2>$(NULL_DEVICE) || true
	@$(call RMDIR,$(OBJ_DIR)) 2>$(NULL_DEVICE) || true
	@$(call MKDIR,$(OBJ_DIR))
	@$(call RM,$(OUT_DIR)/*) 2>$(NULL_DEVICE) || true
	@echo "Clean complete"
EOF
    else
        cat > "$project_root/srcs/Makefile" << 'EOF'
# Simple Makefile for PIC32MZ project
# DFP (Device Family Pack) configuration
DFP_DIR := $(DFP)
DFP_INCLUDE := $(DFP)/include

# Detect operating system for cross-platform compatibility
ifeq ($(OS),Windows_NT)
    detected_OS := Windows
    MKDIR = if not exist "$(subst /,\,$(1))" mkdir "$(subst /,\,$(1))"
    RMDIR = if exist "$(subst /,\,$(1))" rmdir /s /q "$(subst /,\,$(1))"
    RM = if exist "$(subst /,\,$(1))" del /q "$(subst /,\,$(1))"
    NULL_DEVICE = nul
else
    detected_OS := $(shell uname -s)
    MKDIR = mkdir -p $(1)
    RMDIR = rm -rf $(1)
    RM = rm -f $(1)
    NULL_DEVICE = /dev/null
endif

# Project directories
ROOT     := ..
OBJ_DIR  := $(ROOT)/objs
INC_DIR  := $(ROOT)/incs
BIN_DIR  := $(ROOT)/bins
SRC_DIR  := $(ROOT)/srcs
OUT_DIR  := $(ROOT)/other

# Source files (only current directory)
SRCS := $(wildcard *.c)
OBJS := $(SRCS:%.c=$(OBJ_DIR)/%.o)

# Compiler and flags
CC := "$(COMPILER_LOCATION)/xc32-gcc"
MCU := -mprocessor=$(DEVICE)
FLAGS := -Werror -Wall -MP -MMD -g -O1 -ffunction-sections -fdata-sections -fno-common

# Include directories (simple structure)
INCS := -I"$(INC_DIR)" -I"$(DFP_INCLUDE)"

# Compiler command for object files
COMPILE_OBJ := $(CC) -x c -c $(MCU) $(FLAGS) $(INCS) -DXPRJ_default=default -mdfp="$(DFP)"

# Linker script and command
LINKER_SCRIPT := $(DFP)/xc32/$(DEVICE)/p32MZ1024EFH064.ld
LINK_CMD := $(CC) $(MCU) -nostartfiles -DXPRJ_default=default -mdfp="$(DFP)" \
            -Wl,--defsym=__MPLAB_BUILD=1,--script="$(LINKER_SCRIPT)",--defsym=_min_heap_size=512,--gc-sections,--no-code-in-dinit,--no-dinit-in-serial-mem,-Map="$(OUT_DIR)/production.map",--memorysummary,$(OUT_DIR)/memoryfile.xml

# Default target
$(BIN_DIR)/$(MODULE): $(OBJS)
	@echo "Linking $(MODULE) for $(DEVICE)"
	$(LINK_CMD) -o $@ $^ 
	@echo "Build complete: $@"

# Compile C source files
$(OBJ_DIR)/%.o: %.c
	@echo "Compiling $< to $@"
	@$(call MKDIR,$(dir $@))
	$(COMPILE_OBJ) -MF $(@:.o=.d) $< -o $@

.PHONY: clean build_dir debug help platform

# Create build directories
build_dir: 
	@echo "Creating build directories ($(detected_OS))"
	@$(call MKDIR,$(OBJ_DIR))
	@$(call MKDIR,$(BIN_DIR))
	@$(call MKDIR,$(OUT_DIR))
	@echo "Build directories created"

# Debug information
debug:
	@echo "Build system debug info ($(detected_OS)):"
	@echo "Source files: $(SRCS)"
	@echo "Object files: $(OBJS)"
	@echo "Include dirs: $(INCS)"
	@echo "DFP Include: $(DFP_INCLUDE)"
	@echo "Linker script: $(LINKER_SCRIPT)"

# Platform info
platform:
	@echo "Cross-platform build configuration:"
	@echo "  Detected OS: $(detected_OS)"
	@echo "  Compiler: $(CC)"
	@echo "  Device: $(DEVICE)"

# Help
help:
	@echo "Available targets:"
	@echo "  all (default) - Build the project"
	@echo "  build_dir     - Create build directories"
	@echo "  clean         - Clean build artifacts"
	@echo "  debug         - Show debug information"
	@echo "  platform      - Show platform information"
	@echo "  help          - Show this help"

# Clean
clean:
	@echo "Cleaning build artifacts ($(detected_OS))"
	@$(call RM,$(BIN_DIR)/*) 2>$(NULL_DEVICE) || true
	@$(call RMDIR,$(OBJ_DIR)) 2>$(NULL_DEVICE) || true
	@$(call MKDIR,$(OBJ_DIR))
	@$(call RM,$(OUT_DIR)/*) 2>$(NULL_DEVICE) || true
	@echo "Clean complete"
EOF
    else
        cat > "$project_root/srcs/Makefile" << 'EOF'
# Simple Makefile for PIC32MZ project
# DFP (Device Family Pack) configuration
DFP_DIR := $(DFP)
DFP_INCLUDE := $(DFP)/include

# Detect operating system for cross-platform compatibility
ifeq ($(OS),Windows_NT)
    detected_OS := Windows
    MKDIR = if not exist "$(subst /,\,$(1))" mkdir "$(subst /,\,$(1))"
    RMDIR = if exist "$(subst /,\,$(1))" rmdir /s /q "$(subst /,\,$(1))"
    RM = if exist "$(subst /,\,$(1))" del /q "$(subst /,\,$(1))"
    NULL_DEVICE = nul
else
    detected_OS := $(shell uname -s)
    MKDIR = mkdir -p $(1)
    RMDIR = rm -rf $(1)
    RM = rm -f $(1)
    NULL_DEVICE = /dev/null
endif

# Project directories
ROOT     := ..
OBJ_DIR  := $(ROOT)/objs
INC_DIR  := $(ROOT)/incs
BIN_DIR  := $(ROOT)/bins
SRC_DIR  := $(ROOT)/srcs
OUT_DIR  := $(ROOT)/other

# Source files (only current directory)
SRCS := $(wildcard *.c)
OBJS := $(SRCS:%.c=$(OBJ_DIR)/%.o)

# Compiler and flags
CC := "$(COMPILER_LOCATION)/xc32-gcc"
MCU := -mprocessor=$(DEVICE)
FLAGS := -Werror -Wall -MP -MMD -g -O1 -ffunction-sections -fdata-sections -fno-common

# Include directories (simple structure)
INCS := -I"$(INC_DIR)" -I"$(DFP_INCLUDE)"

# Compiler command for object files
COMPILE_OBJ := $(CC) -x c -c $(MCU) $(FLAGS) $(INCS) -DXPRJ_default=default -mdfp="$(DFP)"

# Linker script and command
LINKER_SCRIPT := $(DFP)/xc32/$(DEVICE)/p32MZ1024EFH064.ld
LINK_CMD := $(CC) $(MCU) -nostartfiles -DXPRJ_default=default -mdfp="$(DFP)" \
            -Wl,--defsym=__MPLAB_BUILD=1,--script="$(LINKER_SCRIPT)",--defsym=_min_heap_size=512,--gc-sections,--no-code-in-dinit,--no-dinit-in-serial-mem,-Map="$(OUT_DIR)/production.map",--memorysummary,$(OUT_DIR)/memoryfile.xml

# Default target
$(BIN_DIR)/$(MODULE): $(OBJS)
	@echo "Linking $(MODULE) for $(DEVICE)"
	$(LINK_CMD) -o $@ $^ 
	@echo "Build complete: $@"

# Compile C source files
$(OBJ_DIR)/%.o: %.c
	@echo "Compiling $< to $@"
	@$(call MKDIR,$(dir $@))
	$(COMPILE_OBJ) -MF $(@:.o=.d) $< -o $@

.PHONY: clean build_dir debug help platform

# Create build directories
build_dir: 
	@echo "Creating build directories ($(detected_OS))"
	@$(call MKDIR,$(OBJ_DIR))
	@$(call MKDIR,$(BIN_DIR))
	@$(call MKDIR,$(OUT_DIR))
	@echo "Build directories created"

# Debug information
debug:
	@echo "Build system debug info ($(detected_OS)):"
	@echo "Source files: $(SRCS)"
	@echo "Object files: $(OBJS)"
	@echo "Include dirs: $(INCS)"
	@echo "DFP Include: $(DFP_INCLUDE)"
	@echo "Linker script: $(LINKER_SCRIPT)"

# Platform info
platform:
	@echo "Cross-platform build configuration:"
	@echo "  Detected OS: $(detected_OS)"
	@echo "  Compiler: $(CC)"
	@echo "  Device: $(DEVICE)"

# Help
help:
	@echo "Available targets:"
	@echo "  all (default) - Build the project"
	@echo "  build_dir     - Create build directories"
	@echo "  clean         - Clean build artifacts"
	@echo "  debug         - Show debug information"
	@echo "  platform      - Show platform information"
	@echo "  help          - Show this help"

# Clean
clean:
	@echo "Cleaning build artifacts ($(detected_OS))"
	@$(call RM,$(BIN_DIR)/*) 2>$(NULL_DEVICE) || true
	@$(call RMDIR,$(OBJ_DIR)) 2>$(NULL_DEVICE) || true
	@$(call MKDIR,$(OBJ_DIR))
	@$(call RM,$(OUT_DIR)/*) 2>$(NULL_DEVICE) || true
	@echo "Clean complete"
EOF
    fi

    echo -e "${GREEN}✓ Srcs Makefile created${NC}"
}

create_startup_files() {
    local project_root="$1"
    local project_name="$2"
    local startup_file="$project_root/srcs/startup/startup.S"
    
    echo -e "${BLUE}Creating startup files for MikroC support...${NC}"
    
    # Only create startup.S if it doesn't exist
    if [ ! -f "$startup_file" ]; then
        # Create startup.S file
        cat > "$startup_file" << 'EOF'
/*******************************************************************************
  System Startup File

  File Name:
    startup.S

  Summary:
    System startup code for PIC32MZ microcontrollers.

  Description:
    This file contains the startup code that gets executed after reset.
*******************************************************************************/

#include <xc.h>

    .section .vector_0,code, keep
    .equ __vector_spacing_0, 0x00000001
    .align 4
    .set nomips16
    .set noreorder
    .ent __vector_0
__vector_0:
    j  _startup
    nop
    .end __vector_0
    .size __vector_0, .-__vector_0

    .section .startup,code, keep
    .align 4
    .set nomips16
    .set noreorder
    .ent _startup
_startup:
    # Add your startup code here
    # Jump to main
    la   $t0, main
    jr   $t0
    nop
    .end _startup
    .size _startup, .-_startup
EOF
        echo -e "${GREEN}✓ Created startup file: $startup_file${NC}"
    else
        echo -e "${YELLOW}✓ Startup file already exists: $startup_file${NC}"
    fi

    echo -e "${GREEN}✓ Startup files processed${NC}"
}

create_template_files() {
    local project_root="$1"
    local project_name="$2"
    local device="$3"
    
    echo -e "${BLUE}Creating template files...${NC}"
    
    # Create main.c in srcs
    cat > "$project_root/srcs/main.c" << EOF
/*******************************************************************************
  Main Source File

  Company:
    Your Company Name

  File Name:
    main.c

  Summary:
    This file contains the "main" function for $project_name.

  Description:
    This file contains the "main" function for the project.
 *******************************************************************************/

#include <stddef.h>                     // Defines NULL
#include <stdbool.h>                    // Defines true
#include <stdlib.h>                     // Defines EXIT_FAILURE
#include <stdint.h>                     // Defines uint32_t, uintptr_t
#include "definitions.h"                // SYS function prototypes

int main ( void )
{
    /* Initialize all modules */
    SYS_Initialize ( NULL );

    while ( true )
    {
        // Your application code here
    }

    /* Execution should not come here during normal operation */
    return ( EXIT_FAILURE );
}
EOF

    # Create README.md
    cat > "$project_root/README.md" << EOF
# $project_name

PIC32MZ Embedded Project using XC32 Compiler

## Device
- **Microcontroller**: $device
- **Compiler**: XC32 v4.60+
- **IDE**: MPLAB X (optional)

## Project Structure

\`\`\`
$project_name/
├── Makefile              # Root build file
├── README.md            # This file
├── srcs/                # Source files
│   ├── Makefile         # Source build configuration
│   └── main.c           # Main application
├── incs/                # Header files (MCC Harmony generated)
├── objs/                # Object files (generated)
├── bins/                # Binary outputs (generated)
├── other/               # Maps, XML files (generated)
└── docs/                # Documentation
\`\`\`

**Note**: The following files are generated by MCC Harmony and not included in the initial template:
- \`incs/definitions.h\` - System definitions
- \`incs/device.h\` - Device configuration  
- \`incs/interrupts.h\` - Interrupt definitions
- \`incs/toolchain_specifics.h\` - Toolchain specific definitions
- \`srcs/initialization.c\` - System initialization
- \`srcs/interrupts.c\` - Interrupt handlers
- \`srcs/exceptions.c\` - Exception handlers

## Building

### All Platforms
\`\`\`bash
make
\`\`\`

The build system automatically detects your platform and uses appropriate commands.

## Useful Commands

- \`make\` - Build the project
- \`make clean\` - Clean build artifacts
- \`make debug\` - Show build configuration
- \`make platform\` - Show cross-platform settings
- \`make build_dir\` - Create directory structure

## Cross-Platform Support

This project automatically detects Windows, Linux, and macOS and adjusts build commands accordingly.

## Generated by PIC32MZ Project Generator
EOF

    # Create .gitignore
    cat > "$project_root/.gitignore" << 'EOF'
# Build outputs
objs/
bins/
other/
*.o
*.d
*.hex
*.elf
*.map
*.xml

# IDE files
*.X/
.generated_files/

# System files
.DS_Store
Thumbs.db
EOF

    echo -e "${GREEN}✓ Template files created${NC}"
}

# Main execution
main() {
    # Check arguments
    if [ $# -lt 1 ]; then
        usage
        exit 1
    fi

    PROJECT_NAME="$1"
    DEVICE="${2:-32MZ1024EFH064}"
    OUTPUT_DIR="${3:-.}"
    MIKROC="${4:-}"
    
    # Check if mikroc option is provided
    INCLUDE_STARTUP="false"
    if [ "$MIKROC" = "mikroc" ] || [ "$4" = "mikroc" ]; then
        INCLUDE_STARTUP="true"
    fi
    
    PROJECT_ROOT="$OUTPUT_DIR/$PROJECT_NAME"

    echo -e "${YELLOW}PIC32MZ Project Generator${NC}"
    echo "=========================="
    echo -e "${BLUE}Project Name:${NC} $PROJECT_NAME"
    echo -e "${BLUE}Device:${NC} $DEVICE"
    echo -e "${BLUE}Output Directory:${NC} $(realpath "$PROJECT_ROOT" 2>/dev/null || echo "$PROJECT_ROOT")"
    if [ "$INCLUDE_STARTUP" = "true" ]; then
        echo -e "${BLUE}MikroC support:${NC} ENABLED"
    fi
    echo ""

    # Create project
    create_directories "$PROJECT_ROOT" "$INCLUDE_STARTUP"
    create_root_makefile "$PROJECT_ROOT" "$PROJECT_NAME" "$DEVICE"
    create_srcs_makefile "$PROJECT_ROOT" "$INCLUDE_STARTUP"
    create_template_files "$PROJECT_ROOT" "$PROJECT_NAME" "$DEVICE"
    
    # Create startup files if mikroc option is enabled
    if [ "$INCLUDE_STARTUP" = "true" ]; then
        create_startup_files "$PROJECT_ROOT" "$PROJECT_NAME"
    fi

    echo ""
    echo -e "${GREEN}✅ Project '$PROJECT_NAME' generated successfully!${NC}"
    echo -e "${BLUE}📁 Location:${NC} $(realpath "$PROJECT_ROOT" 2>/dev/null || echo "$PROJECT_ROOT")"
    echo ""
    echo -e "${YELLOW}Next steps:${NC}"
    echo "  cd $PROJECT_NAME"
    echo "  make build_dir"
    echo "  make"
    echo ""
    if [ "$INCLUDE_STARTUP" = "true" ]; then
        echo -e "${GREEN}MikroC startup files included for bootloader compatibility! 🚀${NC}"
    else
        echo -e "${GREEN}The project is ready for development! 🚀${NC}"
    fi
}

# Run main function
main "$@"
