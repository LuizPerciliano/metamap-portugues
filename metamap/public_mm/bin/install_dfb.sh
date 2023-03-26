#! /bin/sh
# install_dfb.sh - Public MetaMap Data File Builder Install Program
#
# public_mm_dist/dev/public_mm/bin/install_dfb.sh, Thu Jul  2 10:02:11 2009, edit by Will Rogers
#
# This script reads environment variables BASEDIR and JAVA_HOME from
# parent process.

# Require that LVG is installed

echo "Is LVG installed? [yN]"
read RESPONSE
if [ "$RESPONSE" = "y" ]; then
    echo "running Data File Builder Install..."
    # Request location of LVG

    if [ "$LVG_DIR" = "" ]; then
	lvgprog=`which lvg`
	if [ $? -eq 0 ]; then
	    lvgbindir=`dirname $lvgprog`
	    RC_LVG_DIR=`dirname $lvgbindir`
	else
	    RC_LVG_DIR=""
	fi
    else
	RC_LVG_DIR=$LVG_DIR
    fi

    echo  "Enter home path of LVG [$RC_LVG_DIR]: " 
    read LVG_DIR
    if [ "$LVG_DIR" = "" ]; then
	LVG_DIR=$RC_LVG_DIR
    fi     

    echo Using $LVG_DIR for LVG_DIR.
    echo Using $LVG_DIR for LVG_DIR. >> ./install.log
    echo ""

    # modify scripts in $BASEDIR/scripts/dfbuilder and $BASEDIR/scripts/dfbuilderRRF/Variants
    VARIANTS_SCRIPTS=$BASEDIR/scripts/dfbuilderRRF/Variants
    for mmvscriptbase in ${VARIANTS_SCRIPTS}/*.in
    do
	mmvscript=`basename $mmvscriptbase .in`
	sed -e "s:@@lvgdir@@:$LVG_DIR:g" $mmvscriptbase > ${VARIANTS_SCRIPTS}/$mmvscript
	chmod +x ${VARIANTS_SCRIPTS}/$mmvscript
	if [ -x ${VARIANTS_SCRIPTS}/$mmvscript ]; then
	    echo ${VARIANTS_SCRIPTS}/$mmvscript generated.
	    echo ${VARIANTS_SCRIPTS}/$mmvscript generated. >> ./install.log
	fi
    done
    echo "Datafile Builder Setup is complete." 
    echo "Datafile Builder Setup is complete." >> ./install.log
else
    echo "LVG must be installed to use Data File Builder!  See the Lexical Tools"
    echo "Web Page to acquire LVG which is part of the Lexical Tools package:"
    echo "  http://lexsrv3.nlm.nih.gov/LexSysGroup/Summary/lexicalTools.html"
    exit 1
fi

