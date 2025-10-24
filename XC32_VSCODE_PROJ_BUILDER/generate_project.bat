@echo off
:: PIC32MZ Project Generator - Windows Batch Version
:: Cross-platform project generator for PIC32MZ embedded projects

setlocal enabledelayedexpansion

:: Default values
set "DEVICE=32MZ1024EFH064"
set "OUTPUT_DIR=."

:: Check arguments
if "%~1"=="" (
    echo Usage: %~nx0 ^<project_name^> [device] [output_directory] [mikroc]
    echo.
    echo Arguments:
    echo   project_name     Name of the project to generate ^(required^)
    echo   device          PIC32MZ device ^(default: 32MZ1024EFH064^)
    echo   output_directory Output directory ^(default: current directory^)
    echo   mikroc          Include startup files for MikroC compatibility ^(optional^)
    echo.
    echo Examples:
    echo   %~nx0 MyProject
    echo   %~nx0 MyProject 32MZ2048EFH064
    echo   %~nx0 MyProject 32MZ1024EFH064 C:\Projects
    echo   %~nx0 MyProject 32MZ1024EFH064 C:\Projects mikroc
    goto :eof
)

set "PROJECT_NAME=%~1"
if not "%~2"=="" set "DEVICE=%~2"
if not "%~3"=="" set "OUTPUT_DIR=%~3"

:: Check for mikroc option
set "INCLUDE_STARTUP=false"
if /i "%~4"=="mikroc" set "INCLUDE_STARTUP=true"

set "PROJECT_ROOT=%OUTPUT_DIR%\%PROJECT_NAME%"

echo PIC32MZ Project Generator
echo ==========================
echo Project Name: %PROJECT_NAME%
echo Device: %DEVICE%
echo Output Directory: %PROJECT_ROOT%
if "%INCLUDE_STARTUP%"=="true" echo MikroC support: ENABLED
echo.

:: Create directories
echo Creating directory structure...
mkdir "%PROJECT_ROOT%" 2>nul
mkdir "%PROJECT_ROOT%\srcs" 2>nul
mkdir "%PROJECT_ROOT%\incs" 2>nul
mkdir "%PROJECT_ROOT%\objs" 2>nul
mkdir "%PROJECT_ROOT%\bins" 2>nul
mkdir "%PROJECT_ROOT%\other" 2>nul
mkdir "%PROJECT_ROOT%\docs" 2>nul
if "%INCLUDE_STARTUP%"=="true" (
    mkdir "%PROJECT_ROOT%\srcs\startup" 2>nul
    echo   + Added startup directory for MikroC support
)
echo ✓ Directory structure created

:: Create root Makefile
echo Creating root Makefile...
(
echo # Name of the project binary
echo MODULE    	:= %PROJECT_NAME%
echo.
echo # Device configuration
echo DEVICE 		:= %DEVICE%
echo.
echo # Cross-platform compiler and DFP paths
echo ifeq ^($(OS^),Windows_NT^)
echo     COMPILER_LOCATION := C:/Program Files/Microchip/xc32/v4.60/bin
echo     DFP_LOCATION := C:/Program Files/Microchip/MPLABX/v6.25/packs
echo else
echo     COMPILER_LOCATION := /opt/microchip/xc32/v4.60/bin
echo     DFP_LOCATION := /opt/microchip/mplabx/v6.25/packs
echo endif
echo DFP := $(DFP_LOCATION^)/Microchip/PIC32MZ-EF_DFP/1.4.168
echo.
echo # Build system
echo BUILD=make
echo CLEAN=make clean
echo BUILD_DIR=make build_dir
echo.
echo all:
echo 	@echo "######  BUILDING   ########"
echo 	cd srcs ^&^& $(BUILD^) COMPILER_LOCATION="$(COMPILER_LOCATION^)" DFP_LOCATION="$(DFP_LOCATION^)" DFP="$(DFP^)" DEVICE=$(DEVICE^) MODULE=$(MODULE^)
echo 	@echo "###### BIN TO HEX ########"
echo 	cd bins ^&^& "$(COMPILER_LOCATION^)/xc32-bin2hex" $(MODULE^)
echo 	@echo "######  BUILD COMPLETE   ########"
echo.
echo build_dir:
echo 	@echo "#######BUILDING DIRECTORIES FOR OUTPUT BINARIES#######"
echo 	cd srcs ^&^& $(BUILD_DIR^)
echo.
echo debug:
echo 	@echo "#######DEBUGGING OUTPUTS#######"
echo 	cd srcs ^&^& $(BUILD^) debug COMPILER_LOCATION="$(COMPILER_LOCATION^)" DFP_LOCATION="$(DFP_LOCATION^)" DFP="$(DFP^)" DEVICE=$(DEVICE^) MODULE=$(MODULE^)
echo.
echo platform:
echo 	@echo "#######PLATFORM INFO#######"
echo 	cd srcs ^&^& $(BUILD^) platform COMPILER_LOCATION="$(COMPILER_LOCATION^)" DFP_LOCATION="$(DFP_LOCATION^)" DFP="$(DFP^)" DEVICE=$(DEVICE^) MODULE=$(MODULE^)
echo.
echo clean:
echo 	@echo "####### CLEANING OUTPUTS #######"
echo 	cd srcs ^&^& $(CLEAN^)
echo 	@echo "####### REMOVING BUILD ARTIFACTS #######"
echo ifeq ^($(OS^),Windows_NT^)
echo 	@if exist "bins\\*" del /q "bins\\*" ^>nul 2^>^&1
echo 	@if exist "objs\\*" rmdir /s /q "objs" ^>nul 2^>^&1 ^&^& mkdir "objs" ^>nul 2^>^&1
echo 	@if exist "other\\*" del /q "other\\*" ^>nul 2^>^&1
echo else
echo 	@rm -rf bins/* objs/* other/* 2^>/dev/null ^|^| true
echo endif
echo.
echo .PHONY: all build_dir clean debug platform
) > "%PROJECT_ROOT%\Makefile"
:: Create srcs Makefile
echo Creating srcs Makefile...
(
echo # Simple Makefile for PIC32MZ project
echo # DFP ^(Device Family Pack^) configuration
echo DFP_DIR := $^(DFP^)
echo DFP_INCLUDE := $^(DFP^)/include
echo.
echo # Detect operating system for cross-platform compatibility
echo ifeq ^($^(OS^),Windows_NT^)
echo     detected_OS := Windows
echo     MKDIR = if not exist "^$^(subst /,\\,$^(1^)^)" mkdir "^$^(subst /,\\,$^(1^)^)"
echo     RMDIR = if exist "^$^(subst /,\\,$^(1^)^)" rmdir /s /q "^$^(subst /,\\,$^(1^)^)"
echo     RM = if exist "^$^(subst /,\\,$^(1^)^)" del /q "^$^(subst /,\\,$^(1^)^)"
echo     NULL_DEVICE = nul
echo else
echo     detected_OS := $^(shell uname -s^)
echo     MKDIR = mkdir -p $^(1^)
echo     RMDIR = rm -rf $^(1^)
echo     RM = rm -f $^(1^)
echo     NULL_DEVICE = /dev/null
echo endif
echo.
echo # Project directories
echo ROOT     := ..
echo OBJ_DIR  := $^(ROOT^)/objs
echo INC_DIR  := $^(ROOT^)/incs
echo BIN_DIR  := $^(ROOT^)/bins
echo SRC_DIR  := $^(ROOT^)/srcs
echo OUT_DIR  := $^(ROOT^)/other
echo.
echo # Source files ^(only current directory^)
echo SRCS := $^(wildcard *.c^)
echo OBJS := $^(SRCS:%.c=$^(OBJ_DIR^)/%.o^)
echo.
echo # Compiler and flags
echo CC := "$^(COMPILER_LOCATION^)/xc32-gcc"
echo MCU := -mprocessor=$^(DEVICE^)
echo FLAGS := -Werror -Wall -MP -MMD -g -O1 -ffunction-sections -fdata-sections -fno-common
echo.
echo # Include directories ^(simple structure^)
echo INCS := -I"$^(INC_DIR^)" -I"$^(DFP_INCLUDE^)"
echo.
echo # Compiler command for object files
echo COMPILE_OBJ := $^(CC^) -x c -c $^(MCU^) $^(FLAGS^) $^(INCS^) -DXPRJ_default=default -mdfp="$^(DFP^)"
echo.
echo # Linker script and command
echo LINKER_SCRIPT := $^(DFP^)/xc32/$^(DEVICE^)/p32MZ1024EFH064.ld
echo LINK_CMD := $^(CC^) $^(MCU^) -nostartfiles -DXPRJ_default=default -mdfp="$^(DFP^)" \
echo             -Wl,--defsym=__MPLAB_BUILD=1,--script="$^(LINKER_SCRIPT^)",--defsym=_min_heap_size=512,--gc-sections,--no-code-in-dinit,--no-dinit-in-serial-mem,-Map="$^(OUT_DIR^)/production.map",--memorysummary,$^(OUT_DIR^)/memoryfile.xml
echo.
echo # Default target
echo $^(BIN_DIR^)/$^(MODULE^): $^(OBJS^)
echo 	@echo "Linking $^(MODULE^) for $^(DEVICE^)"
echo 	$^(LINK_CMD^) -o $@ $^ 
echo 	@echo "Build complete: $@"
echo.
echo # Compile C source files
echo $^(OBJ_DIR^)/%.o: %.c
echo 	@echo "Compiling $< to $@"
echo 	@$^(call MKDIR,$^(dir $@^)^)
echo 	$^(COMPILE_OBJ^) -MF $^(@:.o=.d^) $< -o $@
echo.
echo .PHONY: clean build_dir debug help platform
echo.
echo # Create build directories
echo build_dir: 
echo 	@echo "Creating build directories ^($^(detected_OS^)^)"
echo 	@$^(call MKDIR,$^(OBJ_DIR^)^)
echo 	@$^(call MKDIR,$^(BIN_DIR^)^)
echo 	@$^(call MKDIR,$^(OUT_DIR^)^)
echo 	@echo "Build directories created"
echo.
echo # Debug information
echo debug:
echo 	@echo "Build system debug info ^($^(detected_OS^)^):"
echo 	@echo "Source files: $^(SRCS^)"
echo 	@echo "Object files: $^(OBJS^)"
echo 	@echo "Include dirs: $^(INCS^)"
echo 	@echo "DFP Include: $^(DFP_INCLUDE^)"
echo 	@echo "Linker script: $^(LINKER_SCRIPT^)"
echo.
echo # Platform info
echo platform:
echo 	@echo "Cross-platform build configuration:"
echo 	@echo "  Detected OS: $^(detected_OS^)"
echo 	@echo "  Compiler: $^(CC^)"
echo 	@echo "  Device: $^(DEVICE^)"
echo.
echo # Help
echo help:
echo 	@echo "Available targets:"
echo 	@echo "  all ^(default^) - Build the project"
echo 	@echo "  build_dir     - Create build directories"
echo 	@echo "  clean         - Clean build artifacts"
echo 	@echo "  debug         - Show debug information"
echo 	@echo "  platform      - Show platform information"
echo 	@echo "  help          - Show this help"
echo.
echo # Clean
echo clean:
echo 	@echo "Cleaning build artifacts ^($^(detected_OS^)^)"
echo 	@$^(call RM,$^(BIN_DIR^)/*^) 2^>$^(NULL_DEVICE^) ^|^| true
echo 	@$^(call RMDIR,$^(OBJ_DIR^)^) 2^>$^(NULL_DEVICE^) ^|^| true
echo 	@$^(call MKDIR,$^(OBJ_DIR^)^)
echo 	@$^(call RM,$^(OUT_DIR^)/*^) 2^>$^(NULL_DEVICE^) ^|^| true
echo 	@echo "Clean complete"
) > "%PROJECT_ROOT%\srcs\Makefile"
echo ✓ Srcs Makefile created

:: Create basic template files
echo Creating template files...

:: main.c in srcs
(
echo /*******************************************************************************
echo   Main Source File - %PROJECT_NAME%
echo  *******************************************************************************/
echo.
echo #include ^<stddef.h^>
echo #include ^<stdbool.h^>
echo #include ^<stdlib.h^>
echo #include ^<stdint.h^>
echo #include "definitions.h"
echo.
echo int main ^( void ^)
echo {
echo     /* Initialize all modules */
echo     SYS_Initialize ^( NULL ^);
echo.
echo     while ^( true ^)
echo     {
echo         /* Your application code here */
echo     }
echo.
echo     return ^( EXIT_FAILURE ^);
echo }
) > "%PROJECT_ROOT%\srcs\main.c"

:: main.c
(
echo /*******************************************************************************
echo   Main Source File - %PROJECT_NAME%
echo  *******************************************************************************/
echo.
echo #include ^<stddef.h^>
echo #include ^<stdbool.h^>
echo #include ^<stdlib.h^>
echo #include ^<stdint.h^>
echo #include "definitions.h"
echo.
echo int main ^( void ^)
echo {
echo     /* Initialize all modules */
echo     SYS_Initialize ^( NULL ^);
echo.
echo     while ^( true ^)
echo     {
echo         /* Your application code here */
echo     }
echo.
echo     return ^( EXIT_FAILURE ^);
echo }
) > "%PROJECT_ROOT%\srcs\main.c"

:: README.md
(
echo # %PROJECT_NAME%
echo.
echo PIC32MZ Embedded Project using XC32 Compiler
echo.
echo ## Device
echo - **Microcontroller**: %DEVICE%
echo - **Compiler**: XC32 v4.60+
echo.
echo ## Building
echo.
echo ```bash
echo make
echo ```
echo.
echo ## Useful Commands
echo.
echo - `make` - Build the project
echo - `make clean` - Clean build artifacts
echo - `make debug` - Show build configuration
echo - `make platform` - Show cross-platform settings
echo.
echo Generated by PIC32MZ Project Generator
) > "%PROJECT_ROOT%\README.md"

:: .gitignore
(
echo # Build outputs
echo objs/
echo bins/
echo other/
echo *.o
echo *.d
echo *.hex
echo *.elf
echo *.map
echo *.xml
echo.
echo # IDE files
echo *.X/
echo .generated_files/
echo.
echo # System files
echo .DS_Store
echo Thumbs.db
) > "%PROJECT_ROOT%\.gitignore"

echo ✓ Template files created

:: Create startup files if mikroc option is enabled
if "%INCLUDE_STARTUP%"=="true" (
    echo Creating startup files for MikroC support...
    
    :: Check if startup.S already exists
    if not exist "%PROJECT_ROOT%\srcs\startup\startup.S" (
        :: Create startup.S file
        (
        echo /*******************************************************************************
        echo   System Startup File
        echo  *******************************************************************************/
        echo.
        echo #include ^<xc.h^>
        echo.
        echo     .section .vector_0,code, keep
        echo     .equ __vector_spacing_0, 0x00000001
        echo     .align 4
        echo     .set nomips16
        echo     .set noreorder
        echo     .ent __vector_0
        echo __vector_0:
        echo     j  _startup
        echo     nop
        echo     .end __vector_0
        echo     .size __vector_0, .-__vector_0
        echo.
        echo     .section .startup,code, keep
        echo     .align 4
        echo     .set nomips16
        echo     .set noreorder
        echo     .ent _startup
        echo _startup:
        echo     # Add your startup code here
        echo     # Jump to main
        echo     la   $t0, main
        echo     jr   $t0
        echo     nop
        echo     .end _startup
        echo     .size _startup, .-_startup
        ) > "%PROJECT_ROOT%\srcs\startup\startup.S"
        echo ✓ Created startup file: %PROJECT_ROOT%\srcs\startup\startup.S
    ) else (
        echo ✓ Startup file already exists: %PROJECT_ROOT%\srcs\startup\startup.S
    )
    
    echo ✓ Startup files processed
)

echo.
echo ✅ Project '%PROJECT_NAME%' generated successfully!
echo 📁 Location: %PROJECT_ROOT%
echo.
echo Next steps:
echo   cd %PROJECT_NAME%
echo   make build_dir
echo   make
echo.
if "%INCLUDE_STARTUP%"=="true" (
    echo MikroC startup files included for bootloader compatibility! 🚀
) else (
    echo The project is ready for development! 🚀
)

endlocal
