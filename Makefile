################################################################################
# Copyright (c) 2022, DigiDNA
# All rights reserved
#
# Unauthorised copying of this copyrighted work, via any medium is strictly
# prohibited.
# Proprietary and confidential.
################################################################################

PATH_MAKEFILE := $(abspath $(lastword $(MAKEFILE_LIST)))
DIR_MAKEFILE  := $(dir $(PATH_MAKEFILE))

DIR_TMP    := $(DIR_MAKEFILE)tmp/
DIR_BIN    := $(DIR_MAKEFILE)bin/
DIR_BUILD  := $(DIR_MAKEFILE)build/
DIR_CONFIG := $(DIR_MAKEFILE)config/

GIT_swiftformat             := https://github.com/DigiDNA/SwiftFormat.git
XCODE_PROJ_swiftformat      := SwiftFormat.xcodeproj
XCODE_SCHEME_swiftformat    := "SwiftFormat (Command Line Tool)"
EXEC_swiftformat            := $(DIR_BUILD)swiftformat/Build/Products/Release/swiftformat
CONFIG_swiftformat_ddna     := $(DIR_CONFIG)swiftformat-ddna
CONFIG_swiftformat_mit      := $(DIR_CONFIG)swiftformat-mit

all: swiftformat_ddna
	
	@:

mit: swiftformat_mit
	
	@:
	
swiftformat_%: _EXEC_   = $($(patsubst %,EXEC_%,$(patsubst %_$*,%,$@)))
swiftformat_%: _CONFIG_ = $($(patsubst %,CONFIG_%,$@))
swiftformat_%: _FILES_  = SWIFT_RESPONSE_FILE_PATH_${CURRENT_VARIANT}_${ARCHS}
swiftformat_%: update_swiftformat build_swiftformat
	
	@if [ -f $(_EXEC_) ]; then $(_EXEC_) --config "$(_CONFIG_)" --filelist "${$(_FILES_)}"; fi
	
.SECONDEXPANSION:

build_%: _XCODE_PROJ_   = $($(patsubst build_%,XCODE_PROJ_%,$@))
build_%: _XCODE_SCHEME_ = $($(patsubst build_%,XCODE_SCHEME_%,$@))
build_%: _DIR_TMP_      = $(patsubst build_%,$(DIR_TMP)%,$@)
build_%: _DIR_BUILD_    = $(patsubst build_%,$(DIR_BUILD)%,$@)
build_%:
	
	@if [ -d $(_DIR_TMP_) ]; then xcodebuild -project "$(_DIR_TMP_)/$(_XCODE_PROJ_)" -scheme $(_XCODE_SCHEME_) -derivedDataPath $(_DIR_BUILD_) -configuration Release build DEVELOPMENT_TEAM=J5PR93692Y ONLY_ACTIVE_ARCH=NO GCC_INSTRUMENT_PROGRAM_FLOW_ARCS=NO; fi

update_%: $$(DIR_TMP)$$*
	
	@if nc -zw1 github.com 443; then                                \
		cd $(DIR_TMP)$* && git pull;                                \
		cd $(DIR_TMP)$* && git submodule update --init --recursive; \
	fi

$(DIR_TMP)%: _GIT_ = $($(patsubst $(DIR_TMP)%,GIT_%,$@))
$(DIR_TMP)%:
	
	@if nc -zw1 github.com 443; then git clone --recursive $(_GIT_) $(@); fi
