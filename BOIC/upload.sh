#!/bin/sh
# oracle jre ref URL 
# https://sdlc-esd.oracle.com/ESD6/JSCDL/jdk/8u281-b09/89d678f2be164786b292527658ca1605/jre-8u281-linux-x64.tar.gz?GroupName=JSC&FilePath=/ESD6/JSCDL/jdk/8u281-b09/89d678f2be164786b292527658ca1605/jre-8u281-linux-x64.tar.gz&BHost=javadl.sun.com&File=jre-8u281-linux-x64.tar.gz&AuthParam=1612939773_38e920070174b543f23d3047da6bef43&ext=.gz
export JAVAHOME="/usr/bin/jre1.8.0_281"
export PATH="$PATH;$JAVAHOME/bin"
/usr/bin/jre1.8.0_281/bin/javaws ./launch.jnlp