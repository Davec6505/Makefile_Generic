#!/usr/bin/env python3
"""
PIC32MZ XC32 Project Generator
Automatically creates a complete embedded project structure with cross-platform Makefiles
"""

import os
import sys
import argparse
from pathlib import Path

class PIC32ProjectGenerator:
    def __init__(self):
        self.project_name = ""
        self.device = "32MZ1024EFH064"
        self.project_root = ""
        
    def create_directory_structure(self, include_startup=False):
        """Create the simple directory structure - first level only"""
        dirs = [
            "srcs",
            "incs",
            "objs",
            "bins",
            "other",
            "docs"
        ]
        
        # Add startup directory if mikroc option is enabled
        if include_startup:
            dirs.extend([
                "srcs/startup"
            ])
        
        for dir_path in dirs:
            full_path = os.path.join(self.project_root, dir_path)
            Path(full_path).mkdir(parents=True, exist_ok=True)
            print(f"Created directory: {full_path}")
    
    def create_root_makefile(self):
        """Create the root Makefile with cross-platform support"""
        content = f'''# Name of the project binary
MODULE    	:= {self.project_name}

# Device configuration
# The device is expected to be a PIC32MZ family device.
DEVICE 		:= {self.device}

# Compiler location and DFP (Device Family Pack) location
# The compiler location is expected to be the path to the xc32-gcc compiler.
# The DFP location is expected to be the path to the Microchip Device Family Pack.
# The DFP is used to provide the necessary header files and libraries for the specific device.
# The DFP is expected to be installed in the MPLAB X IDE installation directory.
# The DFP is expected to be in the packs directory of the MPLAB X IDE installation directory.
# The DFP is expected to be in the format of Microchip/PIC32MZ-EF_DFP/1.4.168.
# Cross-platform compiler and DFP paths
ifeq ($(OS),Windows_NT)
    COMPILER_LOCATION := C:/Program Files/Microchip/xc32/v4.60/bin
    DFP_LOCATION := C:/Program Files/Microchip/MPLABX/v6.25/packs
else
    COMPILER_LOCATION := /opt/microchip/xc32/v4.60/bin
    DFP_LOCATION := /opt/microchip/mplabx/v6.25/packs
endif
DFP := $(DFP_LOCATION)/Microchip/PIC32MZ-EF_DFP/1.4.168

# Simple Unix-style build system
BUILD=make
CLEAN=make clean
BUILD_DIR=make build_dir

all:
	@echo "######  BUILDING   ########"
	cd srcs && $(BUILD) COMPILER_LOCATION="$(COMPILER_LOCATION)" DFP_LOCATION="$(DFP_LOCATION)" DFP="$(DFP)" DEVICE=$(DEVICE) MODULE=$(MODULE)
	@echo "###### BIN TO HEX ########"
	cd bins && "$(COMPILER_LOCATION)/xc32-bin2hex" $(MODULE)
	@echo "######  BUILD COMPLETE   ########"

build_dir:
	@echo "#######BUILDING DIRECTORIES FOR OUTPUT BINARIES#######"
	cd srcs && $(BUILD_DIR)

debug:
	@echo "#######DEBUGGING OUTPUTS#######"
	cd srcs && $(BUILD) debug COMPILER_LOCATION="$(COMPILER_LOCATION)" DFP_LOCATION="$(DFP_LOCATION)" DFP="$(DFP)" DEVICE=$(DEVICE) MODULE=$(MODULE)

platform:
	@echo "#######PLATFORM INFO#######"
	cd srcs && $(BUILD) platform COMPILER_LOCATION="$(COMPILER_LOCATION)" DFP_LOCATION="$(DFP_LOCATION)" DFP="$(DFP)" DEVICE=$(DEVICE) MODULE=$(MODULE)

clean:
	@echo "####### CLEANING OUTPUTS #######"
	cd srcs && $(CLEAN)
	@echo "####### REMOVING BUILD ARTIFACTS #######"
ifeq ($(OS),Windows_NT)
	@if exist "bins\\*" del /q "bins\\*" >nul 2>&1
	@if exist "objs\\*" rmdir /s /q "objs" >nul 2>&1 && mkdir "objs" >nul 2>&1
	@if exist "other\\*" del /q "other\\*" >nul 2>&1
else
	@rm -rf bins/* objs/* other/* 2>/dev/null || true
endif

install:
	cd srcs && $(BUILD) install

flash:
	@echo "#######LOADING OUTPUTS#######"
	cd bins && sudo ../../MikroC_bootloader_lnx/bins/mikro_hb $(MODULE).hex
	@echo "#######LOAD COMPLETE#######"

dfp_dir:
	@echo "####### DFP DIRECTORY #######"
	@echo $(DFP)

help:
	@echo "####### HELP #######"
	cd srcs && $(BUILD) help
	@echo "#####################"

# Unix-style utility targets (cross-platform)
find-source:
	@echo "####### FINDING SOURCE FILES #######"
ifeq ($(OS),Windows_NT)
	@powershell -Command "Get-ChildItem -Recurse srcs -Include *.c,*.h | Select-Object -ExpandProperty FullName"
else
	@find srcs -name "*.c" -o -name "*.h"
endif

grep-pattern:
	@echo "####### SEARCHING FOR PATTERN (usage: make grep-pattern PATTERN=your_pattern) #######"
ifeq ($(OS),Windows_NT)
	@powershell -Command "Select-String -Pattern '$(PATTERN)' -Path 'srcs\\*' -Recurse || Write-Host 'No matches found'"
else
	@grep -r "$(PATTERN)" srcs/ || echo "No matches found"
endif

list-files:
	@echo "####### LISTING PROJECT FILES #######"
ifeq ($(OS),Windows_NT)
	@dir /b
else
	@ls -la
endif

.PHONY: all build_dir clean install find-source grep-pattern list-files debug platform
'''
        makefile_path = os.path.join(self.project_root, "Makefile")
        with open(makefile_path, 'w', encoding='utf-8', newline='\n') as f:
            f.write(content)
        print(f"Created root Makefile: {makefile_path}")
    
    def create_srcs_makefile(self, include_startup=False):
        """Create the srcs/Makefile with simple structure"""
        if include_startup:
            content = '''# Simple Makefile for PIC32MZ project with startup support
# DFP (Device Family Pack) configuration
DFP_DIR := $(DFP)
DFP_INCLUDE := $(DFP)/include

# Detect operating system for cross-platform compatibility
ifeq ($(OS),Windows_NT)
    detected_OS := Windows
    MKDIR = if not exist "$(subst /,\\,$(1))" mkdir "$(subst /,\\,$(1))"
    RMDIR = if exist "$(subst /,\\,$(1))" rmdir /s /q "$(subst /,\\,$(1))"
    RM = if exist "$(subst /,\\,$(1))" del /q "$(subst /,\\,$(1))"
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
LINK_CMD := $(CC) $(MCU) -nostartfiles -DXPRJ_default=default -mdfp="$(DFP)" \\
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
'''
        else:
            content = '''# Simple Makefile for PIC32MZ project
# DFP (Device Family Pack) configuration
DFP_DIR := $(DFP)
DFP_INCLUDE := $(DFP)/include

# Detect operating system for cross-platform compatibility
ifeq ($(OS),Windows_NT)
    detected_OS := Windows
    MKDIR = if not exist "$(subst /,\\,$(1))" mkdir "$(subst /,\\,$(1))"
    RMDIR = if exist "$(subst /,\\,$(1))" rmdir /s /q "$(subst /,\\,$(1))"
    RM = if exist "$(subst /,\\,$(1))" del /q "$(subst /,\\,$(1))"
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
LINK_CMD := $(CC) $(MCU) -nostartfiles -DXPRJ_default=default -mdfp="$(DFP)" \\
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
'''
        makefile_path = os.path.join(self.project_root, "srcs", "Makefile")
        with open(makefile_path, 'w', encoding='utf-8', newline='\n') as f:
            f.write(content)
        print(f"Created srcs Makefile: {makefile_path}")

    def create_template_files(self):
        """Create template source files"""
        
        # Create definitions.h
        definitions_content = f'''/*******************************************************************************
  System Definitions

  File Name:
    definitions.h

  Summary:
    {self.project_name} system definitions.

  Description:
    This file contains the system-wide prototypes and definitions for {self.project_name}.

 *******************************************************************************/

#ifndef DEFINITIONS_H
#define DEFINITIONS_H

// *****************************************************************************
// *****************************************************************************
// Section: Included Files
// *****************************************************************************
// *****************************************************************************
#include <stddef.h>
#include <stdbool.h>
#include <stdint.h>

// *****************************************************************************
// *****************************************************************************
// Section: System Service Definitions
// *****************************************************************************
// *****************************************************************************

// *****************************************************************************
// *****************************************************************************
// Section: System Initialization Function
// *****************************************************************************
// *****************************************************************************
#ifdef __cplusplus  // Provide C++ Compatibility
extern "C" {{
#endif

void SYS_Initialize( void * data );

#ifdef __cplusplus
}}
#endif

#endif /* DEFINITIONS_H */
'''
        
        # Create template source files in srcs directory
        
        # Create main.c in srcs
        main_content = f'''/*******************************************************************************
  Main Source File

  Company:
    Your Company Name

  File Name:
    main.c

  Summary:
    This file contains the "main" function for {self.project_name}.

  Description:
    This file contains the "main" function for the project. The
    "main" function calls the "SYS_Initialize" function to initialize the state
    machines of all modules in the system
 *******************************************************************************/

// *****************************************************************************
// *****************************************************************************
// Section: Included Files
// *****************************************************************************
// *****************************************************************************

#include <stddef.h>                     // Defines NULL
#include <stdbool.h>                    // Defines true
#include <stdlib.h>                     // Defines EXIT_FAILURE
#include <stdint.h>                     // Defines uint32_t, uintptr_t
#include "definitions.h"                // SYS function prototypes

// *****************************************************************************
// *****************************************************************************
// Variables 
// *****************************************************************************
// *****************************************************************************

// *****************************************************************************
// *****************************************************************************
// Section: Main Entry Point
// *****************************************************************************
// *****************************************************************************

int main ( void )
{{
    /* Initialize all modules */
    SYS_Initialize ( NULL );

    while ( true )
    {{
        /* Maintain state machines of all polled MPLAB Harmony modules. */
        //SYS_Tasks ( );
        
        // Your application code here
    }}

    /* Execution should not come here during normal operation */
    return ( EXIT_FAILURE );
}}

/*******************************************************************************
 End of File
*/
'''
        
        # Create initialization.c in srcs
        init_content = f'''/*******************************************************************************
  System Initialization File

  File Name:
    initialization.c

  Summary:
    This file contains source code necessary to initialize the system.

  Description:
    This file contains source code necessary to initialize the system for {self.project_name}.
 *******************************************************************************/

#include "definitions.h"
#include "device.h"

void SYS_Initialize ( void* data )
{{
    /* Add your system initialization code here */
    
    // Initialize peripherals
    // CLK_Initialize();
    // GPIO_Initialize();
    // Add other peripheral initializations as needed
}}
'''
        
        # Create device.h
        device_content = f'''/*******************************************************************************
  Device Configuration Header

  File Name:
    device.h

  Summary:
    Device specific definitions for {self.project_name}

  Description:
    This file contains device specific definitions and includes.
*******************************************************************************/

#ifndef DEVICE_H
#define DEVICE_H

#include <xc.h>
#include <sys/attribs.h>

// Device specific configurations can be added here

#endif /* DEVICE_H */
'''
        
        # Create README.md
        readme_content = f'''# {self.project_name}

PIC32MZ Embedded Project using XC32 Compiler

## Device
- **Microcontroller**: {self.device}
- **Compiler**: XC32 v4.60+
- **IDE**: MPLAB X (optional)

## Project Structure

```
{self.project_name}/
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
```

**Note**: The following files are generated by MCC Harmony and not included in the initial template:
- `incs/definitions.h` - System definitions
- `incs/device.h` - Device configuration  
- `incs/interrupts.h` - Interrupt definitions
- `incs/toolchain_specifics.h` - Toolchain specific definitions
- `srcs/initialization.c` - System initialization
- `srcs/interrupts.c` - Interrupt handlers
- `srcs/exceptions.c` - Exception handlers

## Building

### Windows
```bash
make
```

### Linux/macOS
```bash
make
```

The build system automatically detects your platform and uses appropriate commands.

## Useful Commands

- `make` - Build the project
- `make clean` - Clean build artifacts
- `make debug` - Show build configuration
- `make platform` - Show cross-platform settings
- `make build_dir` - Create directory structure
- `make find-source` - List all source files
- `make help` - Show compiler help

## Cross-Platform Support

This project automatically detects Windows, Linux, and macOS and adjusts build commands accordingly. No modifications needed when switching platforms.

## Generated by PIC32MZ Project Generator
Generated on: {sys.platform}
'''
        
        # Write files (excluding MCC Harmony generated files)
        files_to_create = [
            ("srcs/main.c", main_content),
            ("README.md", readme_content)
        ]
        
        for file_path, content in files_to_create:
            full_path = os.path.join(self.project_root, file_path)
            with open(full_path, 'w', encoding='utf-8', newline='\n') as f:
                f.write(content)
            print(f"Created template file: {full_path}")

    def create_gitignore(self):
        """Create .gitignore for the project"""
        gitignore_content = '''# Build outputs
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
*.mcp
*.mcw
*.mcs
*.mcpar
*.X/
.generated_files/

# System files
.DS_Store
Thumbs.db
*.tmp
*.temp
*.swp
*.swo
*~

# Python cache (for generator script)
__pycache__/
*.pyc
*.pyo
'''
        gitignore_path = os.path.join(self.project_root, ".gitignore")
        with open(gitignore_path, 'w', encoding='utf-8', newline='\n') as f:
            f.write(gitignore_content)
        print(f"Created .gitignore: {gitignore_path}")

    def create_startup_files(self):
        """Create startup files for mikroc compatibility - only if they don't exist"""
        startup_s_path = os.path.join(self.project_root, "srcs", "startup", "startup.S")
        
        # Only create startup.S if it doesn't exist
        if not os.path.exists(startup_s_path):
            # Create startup.S file
            startup_s_content = '''/*******************************************************************************
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
'''

            with open(startup_s_path, 'w', encoding='utf-8', newline='\n') as f:
                f.write(startup_s_content)
            print(f"Created startup file: {startup_s_path}")
        else:
            print(f"Startup file already exists: {startup_s_path}")

    def generate_project(self, project_name, device="32MZ1024EFH064", output_dir=".", mikroc=False):
        """Generate complete project structure"""
        self.project_name = project_name
        self.device = device
        self.project_root = os.path.join(output_dir, project_name)
        
        print(f"Generating PIC32MZ project: {project_name}")
        print(f"Target device: {device}")
        print(f"Output directory: {os.path.abspath(self.project_root)}")
        if mikroc:
            print("MikroC support: ENABLED")
        print("-" * 50)
        
        # Create root directory
        Path(self.project_root).mkdir(parents=True, exist_ok=True)
        
        # Generate project structure
        self.create_directory_structure(include_startup=mikroc)
        self.create_root_makefile()
        self.create_srcs_makefile(include_startup=mikroc)
        self.create_template_files()
        self.create_gitignore()
        
        # Create startup files if mikroc option is enabled
        if mikroc:
            self.create_startup_files()
        
        print("-" * 50)
        print(f"✅ Project '{project_name}' generated successfully!")
        print(f"📁 Location: {os.path.abspath(self.project_root)}")
        print("")
        print("Next steps:")
        print(f"  cd {project_name}")
        print("  make build_dir")
        print("  make")
        print("")
        if mikroc:
            print("MikroC startup files included for bootloader compatibility! 🚀")
        else:
            print("The project is ready for development! 🚀")

def main():
    parser = argparse.ArgumentParser(description='PIC32MZ XC32 Project Generator')
    parser.add_argument('project_name', help='Name of the project to generate')
    parser.add_argument('--device', '-d', default='32MZ1024EFH064', 
                       help='PIC32MZ device (default: 32MZ1024EFH064)')
    parser.add_argument('--output', '-o', default='.', 
                       help='Output directory (default: current directory)')
    parser.add_argument('--mikroc', action='store_true',
                       help='Include startup directory and files for MikroC compatibility')
    
    args = parser.parse_args()
    
    generator = PIC32ProjectGenerator()
    generator.generate_project(args.project_name, args.device, args.output, args.mikroc)

if __name__ == "__main__":
    main()
