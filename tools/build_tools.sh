#!/bin/bash

# Update
svn up $MY_TOOLS_DIR

# Build
$MY_TOOLS_DIR/bin/scripts/cvlink update
(cd $MY_TOOLS_DIR/linux-comp && ../dobuild everything_comp.all)
(cd $MY_TOOLS_DIR/linux-ide && ../dobuild everything_ide.all)
(cd $MY_TOOLS_DIR/trg && ./build_lib -fixbuildlinks -arm64 -86 -linux86 -68e -tricore -ppc -v800 -mips -arm -int86 -intcoldfire -intarm64 -intppc -intmips -intarm)
