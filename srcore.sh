#!/usr/bin/env bash

# This file is part of The RetroPie Project
#
# The RetroPie Project is the legal property of its developers, whose names are
# too numerous to list here. Please refer to the COPYRIGHT.md file distributed with this source.
#
# See the LICENSE.md file at the top-level directory of this distribution and
# at https://raw.githubusercontent.com/RetroPie/RetroPie-Setup/master/LICENSE.md
#

rp_module_id="srcore"
rp_module_desc="srcore - Septerra Core: Legacy of the Creator port"
rp_module_licence="MIT https://github.com/M-HT/SR/blob/master/README.md"
rp_module_help="To compile properly, this port requires Septerra Core v1.04.\n\nInstall Septerra Core on your PC and copy the whole folder to /home/pi \nIt needs to have Septerra104.exe"
rp_module_section="exp"
rp_module_flags="noinstclean"


function depends_srcore() {
   getDepends build-essential git scons automake gdc llvm libsdl2-dev libmpg123-dev libquicktime-dev libjudy-dev libsdl2-mixer-dev
  
}

function sources_srcore() {
	 if [ -d "/home/pi/RetroPie/roms/ports/Septerra Core" ]
    then
	cp -R "/home/pi/RetroPie/roms/ports/Septerra Core" "$md_build"
        else
	dialog --msgbox "Unable to find the Septerra Core folder Please copy from your PC to $roms/ports." 0 0
	md_ret_errors+=("Failed: Couldn't find Septerra104.exe.")
    fi    
 	cd "/home/pi/RetroPie-Setup/tmp/build/srcore/Septerra Core"
	mv septerra.exe Septerra104.exe
	cd ..
	gitPullOrClone "$md_build/SR" https://github.com/M-HT/SR.git
	
	#cp -R "$md_build/SR" "/home/pi/SR"
	
 mkdir -p llvmorg

   wget https://github.com/llvm/llvm-project/releases/download/llvmorg-8.0.1/clang+llvm-8.0.1-armv7a-linux-gnueabihf.tar.xz
   tar xvJf clang+llvm-8.0.1-armv7a-linux-gnueabihf.tar.xz -C /home/pi/RetroPie-Setup/tmp/build/srcore/llvmorg
}

function build_srcore() {
   
	cd "$md_build/SR/SRW/udis86-1.7.2"
	aclocal
	automake
	./configure
	make
	
	 sed -i -e 's/#define OUTPUT_TYPE  OUT_X86/#define OUTPUT_TYPE  OUT_LLASM/' "/home/pi/RetroPie-Setup/tmp/build/srcore/SR/SRW/SR_defs.h"
	sed -i -e 's/ values.length = fd.size;/values.length = to!uint(fd.size);/' "/home/pi/RetroPie-Setup/tmp/build/srcore/SR/llasm/llasm.d"

	cd ..
	scons

	cp "/home/pi/RetroPie-Setup/tmp/build/srcore/SR/SRW/SRW.exe"  "/home/pi/RetroPie-Setup/tmp/build/srcore/SR/SRW-games/Septerra Core/SRW"

	cp "/home/pi/RetroPie-Setup/tmp/build/srcore/Septerra Core/Septerra104.exe" "/home/pi/RetroPie-Setup/tmp/build/srcore/SR/SRW-games/Septerra Core/SRW/Septerra104.exe"
	
	chown 777 "/home/pi/RetroPie-Setup/tmp/build/srcore/SR"

	cd "$md_build/SR/SRW-games/Septerra Core/SRW"
	./build-llasm.sh

	cp "Septerra.llasm" "/home/pi/RetroPie-Setup/tmp/build/srcore/SR/games/Septerra Core/SR-Septerra/llasm"

	cp *.llinc "/home/pi/RetroPie-Setup/tmp/build/srcore/SR/games/Septerra Core/SR-Septerra/llasm"

	cd "/home/pi/RetroPie-Setup/tmp/build/srcore/SR/llasm"
	./komp.sh

	cd

	cd "/home/pi/RetroPie-Setup/tmp/build/srcore/SR/games/Septerra Core/SR-Septerra"
 	PATH=/home/pi/RetroPie-Setup/tmp/build/srcore/llvmorg/clang+llvm-8.0.1-armv7a-linux-gnueabihf/bin:$PATH:../../../llasm scons	
	 
	}