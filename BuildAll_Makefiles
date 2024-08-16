
BUILD=make
CLEAN=make clean
BUILD_DIR=make build_dir
#THIRDP_LIB_PATH=/usr/local/mylibs/

all:
	@echo "###### BUILDING  ########"
	+(cd src/employee; $(BUILD))
	+(cd src/employee; $(BUILD) install)
	+(cd src/db_mgr; $(BUILD))
	+(cd src/ui_controller; $(BUILD))

3rd-party-libs:
#	(cd src/3rd_party/libzmq; $(BUILD) install)

build_dir:
	@echo "#######BUILDING DIRECTORIES FOR OUTPUT BINARIES#######"
	(cd src/employee; $(BUILD_DIR))
	(cd src/db_mgr; $(BUILD_DIR))
	(cd src/ui_controller; $(BUILD_DIR))

clean:
	@echo "#######BUILDING DIRECTORIES FOR OUTPUT BINARIES#######"
	(cd src/employee; $(CLEAN))
	(cd src/db_mgr; $(CLEAN))
	(cd src/ui_controller; $(CLEAN))

install:
	(cd src/employee; $(BUILD) install)
	(cd src/db_mgr; $(BUILD) install)
	(cd src/ui_controller; $(BUILD) install)

.PHONY: all 3rd-party-libs build_dir clean install
