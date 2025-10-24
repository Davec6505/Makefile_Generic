# Simple Makefile for PIC32MZ project
# Name of the project binary
MODULE     := CS23

# Default target when running 'make' with no arguments
.DEFAULT_GOAL := build

# Device configuration
# The device is expected to be a PIC32MZ family device.
DEVICE     := 32MZ2048EFH100

# Build configuration: Debug or Release
# Controls output directory structure and optimization level
# Usage: make all BUILD_CONFIG=Debug    (debug build with -g3 -O0)
#        make all BUILD_CONFIG=Release  (balanced build with -g -O1)
#        make all                       (defaults to Release: -g -O1)
BUILD_CONFIG ?= Release

# Optimization level control (optional override for Release builds)
# Usage: make all OPT_LEVEL=2    (use -O2 instead of default -O1)
#        make all OPT_LEVEL=3    (use -O3 for maximum optimization)
#        make all                (uses default -O1)
# Note: Only affects Release builds; Debug always uses -O0
OPT_LEVEL ?= 1

# Debug flags control: set DEBUG_MOTION_BUFFER=1 to enable debug output
# Usage: make all DEBUG_MOTION_BUFFER=1  (enable motion buffer debug messages)
#        make all BUILD_CONFIG=Debug     (Debug builds have it enabled by default)
#        make all                        (disabled by default)
DEBUG_MOTION_BUFFER ?= 0

# Junction look-ahead control: set to 1 to force exact-stop (disable junction blending)
# Usage: make all DISABLE_JUNCTION_LOOKAHEAD=1
# Notes: Root controls policy; sub-Makefile consumes and maps to -DDEBUG_DISABLE_JUNCTION_LOOKAHEAD
DISABLE_JUNCTION_LOOKAHEAD ?= 0

# Library control: set USE_SHARED_LIB=1 to link against pre-built library
# Usage: make shared_lib             (builds libCS23shared.a from libs/*.c)
#        make all USE_SHARED_LIB=1    (links executable against library)
#        make all                     (compiles all sources directly)
USE_SHARED_LIB ?= 0

# Memory configuration for dynamic allocation
# These control heap and stack sizes for the PIC32MZ application
HEAP_SIZE  := 65536    # 64KB heap for dynamic memory allocation
STACK_SIZE := 65536    # 64KB stack for function calls and local variables

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
#	DFP_LOCATION := C:/Users/Automation/.mchp_packs
	DFP_LOCATION := C:/Program Files/Microchip/MPLABX/v6.25/packs
else
    COMPILER_LOCATION := /opt/microchip/xc32/v4.60/bin
    DFP_LOCATION := /opt/microchip/mplabx/v6.25/packs
endif
DFP := $(DFP_LOCATION)/Microchip/PIC32MZ-EF_DFP/1.4.168
#DFP := $(DFP_LOCATION)/Microchip/PIC32MZ-EF_DFP/1.5.173
#C:/Users/Automation/.mchp_packs/Microchip/PIC32MZ-EF_DFP/1.5.173

# Simple Unix-style build system
BUILD=make
BUILD_DIR=make build_dir

# Default target: incremental build (only rebuilds changed files)
build:
	@echo "######  INCREMENTAL BUILD ($(BUILD_CONFIG))  ########"
ifeq ($(USE_SHARED_LIB),1)
	@echo "######  (Using pre-built shared library)  ########"
endif
	cd srcs && $(BUILD) COMPILER_LOCATION="$(COMPILER_LOCATION)" DFP_LOCATION="$(DFP_LOCATION)" DFP="$(DFP)" DEVICE=$(DEVICE) MODULE=$(MODULE) HEAP_SIZE=$(HEAP_SIZE) STACK_SIZE=$(STACK_SIZE) USE_SHARED_LIB=$(USE_SHARED_LIB) BUILD_CONFIG=$(BUILD_CONFIG) OPT_LEVEL=$(OPT_LEVEL) DEBUG_MOTION_BUFFER=$(DEBUG_MOTION_BUFFER) DISABLE_JUNCTION_LOOKAHEAD=$(DISABLE_JUNCTION_LOOKAHEAD)
	@echo "###### BIN TO HEX ########"
	cd bins/$(BUILD_CONFIG) && "$(COMPILER_LOCATION)/xc32-bin2hex" $(MODULE)
	@echo "######  BUILD COMPLETE (bins/$(BUILD_CONFIG)/$(MODULE).hex)  ########"

# Clean + full rebuild
all: clean build
	@echo "######  FULL REBUILD COMPLETE  ########"

# Build shared library from libs/*.c files
shared_lib:
	@echo "######  BUILDING SHARED LIBRARY ($(BUILD_CONFIG))  ########"
	cd srcs && $(BUILD) shared_lib COMPILER_LOCATION="$(COMPILER_LOCATION)" DFP_LOCATION="$(DFP_LOCATION)" DFP="$(DFP)" DEVICE=$(DEVICE) MODULE=$(MODULE) BUILD_CONFIG=$(BUILD_CONFIG) OPT_LEVEL=$(OPT_LEVEL) DEBUG_MOTION_BUFFER=$(DEBUG_MOTION_BUFFER) DISABLE_JUNCTION_LOOKAHEAD=$(DISABLE_JUNCTION_LOOKAHEAD)
	@echo "######  SHARED LIBRARY COMPLETE (libs/$(BUILD_CONFIG)/libCS23shared.a)  ########"

# Quiet build - shows only errors, warnings, and completion status
quiet:
	@echo "######  QUIET BUILD (errors/warnings only)  ########"
ifeq ($(OS),Windows_NT)
	@powershell -NoProfile -ExecutionPolicy Bypass -Command \
	"\$$output = & { Push-Location srcs; make COMPILER_LOCATION='$(COMPILER_LOCATION)' DFP_LOCATION='$(DFP_LOCATION)' DFP='$(DFP)' DEVICE=$(DEVICE) MODULE=$(MODULE) HEAP_SIZE=$(HEAP_SIZE) STACK_SIZE=$(STACK_SIZE) 2>&1; Pop-Location }; \
	\$$filtered = \$$output | Select-String -Pattern 'error|warning' -CaseSensitive:\$$false; \
	if (\$$filtered) { \$$filtered | Write-Host -ForegroundColor Red }; \
	if (\$$LASTEXITCODE -eq 0) { \
		cd bins; & '$(COMPILER_LOCATION)/xc32-bin2hex' $(MODULE) | Out-Null; \
		if (\$$LASTEXITCODE -eq 0) { Write-Host '######  BUILD COMPLETE (no errors)  ########' -ForegroundColor Green } \
		else { Write-Host '######  HEX CONVERSION FAILED  ########' -ForegroundColor Red; exit 1 } \
	} else { Write-Host '######  BUILD FAILED  ########' -ForegroundColor Red; exit 1 }"
else
	@cd srcs && $(BUILD) COMPILER_LOCATION="$(COMPILER_LOCATION)" DFP_LOCATION="$(DFP_LOCATION)" DFP="$(DFP)" DEVICE=$(DEVICE) MODULE=$(MODULE) HEAP_SIZE=$(HEAP_SIZE) STACK_SIZE=$(STACK_SIZE) 2>&1 | grep -iE 'error|warning' || echo "No errors or warnings"
	@if [ $$? -eq 0 ]; then cd bins && "$(COMPILER_LOCATION)/xc32-bin2hex" $(MODULE) >/dev/null 2>&1 && echo "######  BUILD COMPLETE  ########"; fi
endif

build_dir:
	@echo "###### BUILDING DIRECTORIES FOR OUTPUT BINARIES #######"
	cd srcs && $(BUILD_DIR) BUILD_CONFIG=$(BUILD_CONFIG)
	@echo "############ BUILDING DIRECTORIES COMPLETED ###########"

debug:
	@echo "####### DEBUGGING OUTPUTS #######"
	cd srcs && $(BUILD) debug COMPILER_LOCATION="$(COMPILER_LOCATION)" DFP_LOCATION="$(DFP_LOCATION)" DFP="$(DFP)" DEVICE=$(DEVICE) MODULE=$(MODULE) HEAP_SIZE=$(HEAP_SIZE) STACK_SIZE=$(STACK_SIZE)

platform:
	@echo "####### PLATFORM INFO #######"
	cd srcs && $$(BUILD) platform COMPILER_LOCATION="$(COMPILER_LOCATION)" DFP_LOCATION="$(DFP_LOCATION)" DFP="$(DFP)" DEVICE=$(DEVICE) MODULE=$(MODULE)

clean:
	@echo "####### CLEANING OUTPUTS #######"
ifeq ($(OS),Windows_NT)
	@powershell -NoProfile -Command "cd srcs; make clean DRY_RUN=$(DRY_RUN) BUILD_CONFIG=$(BUILD_CONFIG)"
else
	cd srcs && $(MAKE) clean DRY_RUN=$(DRY_RUN) BUILD_CONFIG=$(BUILD_CONFIG)
endif

clean_all:
	@echo "####### CLEANING ALL BUILD CONFIGURATIONS #######"
ifeq ($(OS),Windows_NT)
	@powershell -NoProfile -Command "cd srcs; make clean BUILD_CONFIG=Debug DRY_RUN=$(DRY_RUN)"
	@powershell -NoProfile -Command "cd srcs; make clean BUILD_CONFIG=Release DRY_RUN=$(DRY_RUN)"
else
	cd srcs && $(MAKE) clean BUILD_CONFIG=Debug DRY_RUN=$(DRY_RUN)
	cd srcs && $(MAKE) clean BUILD_CONFIG=Release DRY_RUN=$(DRY_RUN)
endif

rem_dir:
	@echo "####### REMOVING BUILD DIRECTORIES #######"
	cd srcs && $(BUILD) rem_dir DRY_RUN=$(DRY_RUN) DEL_PATH=$(DIR_PATH)

mk_dir:
	@echo "####### CREATING BUILD DIRECTORIES #######"
	cd srcs && $(BUILD) mk_dir DIR_PATH=$(DIR_PATH)

install:
	cd srcs && $(BUILD) install

flash:
	@echo "#######LOADING OUTPUTS#######"
	cd bins && sudo ../../MikroC_bootloader_lnx/bins/mikro_hb $(MODULE).hex
	@echo "#######LOAD COMPLETE#######"

dfp_dir:
	@echo "####### DFP DIRECTORY #######"
	@echo $(DFP)

debug_path:
	@echo "####### DEBUGGING PATHS #######"
	cd srcs && $(BUILD) debug_path $(DIR_PATH)



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
	@powershell -Command "Select-String -Pattern '$(PATTERN)' -Path 'srcs\*' -Recurse || Write-Host 'No matches found'"
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

help: cmdlets
ifeq ($(OS),Windows_NT)
	@powershell -NoProfile -Command "\
	Write-Host '######################################## BUILD COMMANDS ############################################' -ForegroundColor Green; \
	Write-Host ''; \
	Write-Host '--- QUICK START ---' -ForegroundColor Cyan; \
	Write-Host 'make                     ' -ForegroundColor Yellow -NoNewline; Write-Host ' - Incremental build (fast - only changed files, Release config).' -ForegroundColor White; \
	Write-Host 'make all                 ' -ForegroundColor Yellow -NoNewline; Write-Host ' - Full rebuild (clean + build from scratch, Release config).' -ForegroundColor White; \
	Write-Host 'make BUILD_CONFIG=Debug  ' -ForegroundColor Yellow -NoNewline; Write-Host ' - Incremental Debug build (-g3 -O0, full symbols).' -ForegroundColor White; \
	Write-Host 'make all BUILD_CONFIG=Debug' -ForegroundColor Yellow -NoNewline; Write-Host ' - Full Debug rebuild (clean + build).' -ForegroundColor White; \
	Write-Host ''; \
	Write-Host '--- BUILD CONFIGURATIONS ---' -ForegroundColor Cyan; \
	Write-Host 'BUILD_CONFIG=Release     ' -ForegroundColor Yellow -NoNewline; Write-Host ' - Balanced build: -g -O1 (default, suitable for debugging + performance).' -ForegroundColor White; \
	Write-Host 'BUILD_CONFIG=Debug       ' -ForegroundColor Yellow -NoNewline; Write-Host ' - Debug build: -g3 -O0 (maximum debug symbols, no optimization).' -ForegroundColor White; \
	Write-Host ''; \
	Write-Host '--- OPTIMIZATION OVERRIDE (Release only) ---' -ForegroundColor Cyan; \
	Write-Host 'make OPT_LEVEL=1         ' -ForegroundColor Yellow -NoNewline; Write-Host ' - Release with -O1 optimization (default).' -ForegroundColor White; \
	Write-Host 'make OPT_LEVEL=2         ' -ForegroundColor Yellow -NoNewline; Write-Host ' - Release with -O2 optimization (recommended for production).' -ForegroundColor White; \
	Write-Host 'make OPT_LEVEL=3         ' -ForegroundColor Yellow -NoNewline; Write-Host ' - Release with -O3 optimization (maximum speed).' -ForegroundColor White; \
	Write-Host ''; \
	Write-Host '--- DIRECTORY MANAGEMENT ---' -ForegroundColor Cyan; \
	Write-Host 'make build_dir           ' -ForegroundColor Yellow -NoNewline; Write-Host ' - Test directory creation (DRY_RUN=1 default, no action).' -ForegroundColor White; \
	Write-Host 'make build_dir DRY_RUN=0 ' -ForegroundColor Yellow -NoNewline; Write-Host ' - Create build directories (bins/Debug, bins/Release, objs/, libs/).' -ForegroundColor White; \
	Write-Host ''; \
	Write-Host '--- CLEAN TARGETS ---' -ForegroundColor Cyan; \
	Write-Host 'make clean               ' -ForegroundColor Yellow -NoNewline; Write-Host ' - Clean current BUILD_CONFIG outputs (Debug or Release).' -ForegroundColor White; \
	Write-Host 'make clean_all           ' -ForegroundColor Yellow -NoNewline; Write-Host ' - Clean both Debug and Release configurations.' -ForegroundColor White; \
	Write-Host ''; \
	Write-Host '--- LIBRARY BUILDS ---' -ForegroundColor Cyan; \
	Write-Host 'make shared_lib          ' -ForegroundColor Yellow -NoNewline; Write-Host ' - Build shared library from libs/*.c files.' -ForegroundColor White; \
	Write-Host 'make all USE_SHARED_LIB=1' -ForegroundColor Yellow -NoNewline; Write-Host ' - Build executable linked against pre-built library.' -ForegroundColor White; \
	Write-Host ''; \
	Write-Host '--- FILTERED OUTPUT ---' -ForegroundColor Cyan; \
	Write-Host 'make quiet               ' -ForegroundColor Yellow -NoNewline; Write-Host ' - Build with filtered output (errors/warnings only).' -ForegroundColor White; \
	Write-Host ''; \
	Write-Host '--- UTILITIES ---' -ForegroundColor Cyan; \
	Write-Host 'make platform            ' -ForegroundColor Yellow -NoNewline; Write-Host ' - Show platform information (OS, paths, toolchain).' -ForegroundColor White; \
	Write-Host 'make help                ' -ForegroundColor Yellow -NoNewline; Write-Host ' - Show this help message.' -ForegroundColor White; \
	Write-Host ''; \
	Write-Host '--- EXAMPLES ---' -ForegroundColor Cyan; \
	Write-Host 'make                     ' -ForegroundColor Yellow -NoNewline; Write-Host ' - Quick incremental build (Release, -O1).' -ForegroundColor White; \
	Write-Host 'make all OPT_LEVEL=3     ' -ForegroundColor Yellow -NoNewline; Write-Host ' - Full rebuild with maximum optimization (Release, -O3).' -ForegroundColor White; \
	Write-Host 'make BUILD_CONFIG=Debug  ' -ForegroundColor Yellow -NoNewline; Write-Host ' - Incremental build with full debug symbols (Debug, -O0).' -ForegroundColor White; \
	Write-Host 'make clean_all           ' -ForegroundColor Yellow -NoNewline; Write-Host ' - Clean both Debug and Release before committing.' -ForegroundColor White; \
	Write-Host ''; \
	Write-Host '#####################################################################################################' -ForegroundColor Green"
else
	@echo -e "\033[0;32m######################################## BUILD COMMANDS ############################################\033[0m"
	@echo ""
	@echo -e "\033[0;36m--- QUICK START ---\033[0m"
	@echo -e "\033[0;33mmake                     \033[0m - Incremental build (fast - only changed files, Release config)."
	@echo -e "\033[0;33mmake all                 \033[0m - Full rebuild (clean + build from scratch, Release config)."
	@echo -e "\033[0;33mmake BUILD_CONFIG=Debug  \033[0m - Incremental Debug build (-g3 -O0, full symbols)."
	@echo -e "\033[0;33mmake all BUILD_CONFIG=Debug\033[0m - Full Debug rebuild (clean + build)."
	@echo ""
	@echo -e "\033[0;36m--- BUILD CONFIGURATIONS ---\033[0m"
	@echo -e "\033[0;33mBUILD_CONFIG=Release     \033[0m - Balanced build: -g -O1 (default, suitable for debugging + performance)."
	@echo -e "\033[0;33mBUILD_CONFIG=Debug       \033[0m - Debug build: -g3 -O0 (maximum debug symbols, no optimization)."
	@echo ""
	@echo -e "\033[0;36m--- OPTIMIZATION OVERRIDE (Release only) ---\033[0m"
	@echo -e "\033[0;33mmake OPT_LEVEL=1         \033[0m - Release with -O1 optimization (default)."
	@echo -e "\033[0;33mmake OPT_LEVEL=2         \033[0m - Release with -O2 optimization (recommended for production)."
	@echo -e "\033[0;33mmake OPT_LEVEL=3         \033[0m - Release with -O3 optimization (maximum speed)."
	@echo ""
	@echo -e "\033[0;36m--- DIRECTORY MANAGEMENT ---\033[0m"
	@echo -e "\033[0;33mmake build_dir           \033[0m - Test directory creation (DRY_RUN=1 default, no action)."
	@echo -e "\033[0;33mmake build_dir DRY_RUN=0 \033[0m - Create build directories (bins/Debug, bins/Release, objs/, libs/)."
	@echo ""
	@echo -e "\033[0;36m--- CLEAN TARGETS ---\033[0m"
	@echo -e "\033[0;33mmake clean               \033[0m - Clean current BUILD_CONFIG outputs (Debug or Release)."
	@echo -e "\033[0;33mmake clean_all           \033[0m - Clean both Debug and Release configurations."
	@echo ""
	@echo -e "\033[0;36m--- LIBRARY BUILDS ---\033[0m"
	@echo -e "\033[0;33mmake shared_lib          \033[0m - Build shared library from libs/*.c files."
	@echo -e "\033[0;33mmake all USE_SHARED_LIB=1\033[0m - Build executable linked against pre-built library."
	@echo ""
	@echo -e "\033[0;36m--- FILTERED OUTPUT ---\033[0m"
	@echo -e "\033[0;33mmake quiet               \033[0m - Build with filtered output (errors/warnings only)."
	@echo ""
	@echo -e "\033[0;36m--- UTILITIES ---\033[0m"
	@echo -e "\033[0;33mmake platform            \033[0m - Show platform information (OS, paths, toolchain)."
	@echo -e "\033[0;33mmake help                \033[0m - Show this help message."
	@echo ""
	@echo -e "\033[0;36m--- EXAMPLES ---\033[0m"
	@echo -e "\033[0;33mmake                     \033[0m - Quick incremental build (Release, -O1)."
	@echo -e "\033[0;33mmake all OPT_LEVEL=3     \033[0m - Full rebuild with maximum optimization (Release, -O3)."
	@echo -e "\033[0;33mmake BUILD_CONFIG=Debug  \033[0m - Incremental build with full debug symbols (Debug, -O0)."
	@echo -e "\033[0;33mmake clean_all           \033[0m - Clean both Debug and Release before committing."
	@echo ""
	@echo -e "\033[0;32m#####################################################################################################\033[0m"
endif



.PHONY: all quiet build_dir clean install find-source grep-pattern list-files debug platform cmdlets shared_lib 


# TODOS
# add make all 2>&1 | Select-String -Pattern "error:|warning:|BUILD COMPLETE" as a feature.