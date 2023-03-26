#!/bin/sh
# $Id: dfbuilder.profile.TEMPLATE,v 1.12 2006/12/19 21:31:26 wrogers Exp $
#
# <MMTX>/config/dfbuilder.profile -- setup dfbuilder environment
#

#         set up search path

#-----------------------------------------------------------
# MMTX PATH and CURRENT CLASSPATH 
#-----------------------------------------------------------

OSTYPE=`uname`

# MetaMap base directory
case $OSTYPE in
    CYGWIN_NT*)
	BASEDIR=/home/luizperciliano/metamap-portugues/metamap/public_mm
	CLASSPATH=$BASEDIR/lib/suppress.jar
	# convert classpath to Windows(tm) format
	CLASSPATH=`cygpath --path --windows $CLASSPATH`
	;;
    MINGW*)
	BASEDIR=/home/luizperciliano/metamap-portugues/metamap/public_mm
	BASEWDIR=`(cd /home/luizperciliano/metamap-portugues/metamap/public_mm && pwd -W)`
	CLASSPATH=$BASEDIR/lib/suppress.jar
	;;
    *)
	BASEDIR=/home/luizperciliano/metamap-portugues/metamap/public_mm
	CLASSPATH=$BASEDIR/lib/suppress.jar
	;;
esac
PATH=$BASEDIR/bin:$PATH

export BASEDIR
export PATH
export CLASSPATH

# set locale for all environments to "C"
LC_ALL=C
LC_COLLATE=C
export LC_ALL
export LC_COLLATE

KSYear=___KSYear
export KSYear

# fix for Berkeley DB shared library problem. 29oct2010 wjr
case $OSTYPE in
    Darwin*)
	DYLD_LIBRARY_PATH=$BASEDIR/bin:$BASEDIR/lib:${LD_LIBRARY_PATH}
	export DYLD_LIBRARY_PATH
	;;
    *)
	LD_LIBRARY_PATH=$BASEDIR/bin:$BASEDIR/lib:${LD_LIBRARY_PATH}
	export LD_LIBRARY_PATH
	;;
esac

case $OSTYPE in
    Linux) 
	if [ -e /bin/gawk ]; then 
	    AWK=gawk
	elif [ -e /use/bin/gawk ]; then 
	    AWK=gawk
	else
	    AWK=awk
        fi
	;;
    SunOS) AWK=nawk ;;
    CYGWIN_NT*) AWK=gawk ;;
    MINGW*) AWK=gawk ;;
    *) AWK=awk ;;
esac
export AWK
export OSTYPE

# end of script
