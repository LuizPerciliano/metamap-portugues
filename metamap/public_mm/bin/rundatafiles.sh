#!/bin/sh
# $Id: rundatafiles.sh.TEMPLATE,v 1.3 2003/04/01 14:54:49 divita Exp $
#
# <MMTX>/config/rundatafiles.sh -- run dfbuilder filtering step
#

#         set up search path

#-----------------------------------------------------------
# MetaMap base directory and program path
#-----------------------------------------------------------
BASEDIR=/home/luizperciliano/metamap-portugues/metamap/public_mm
PATH=$BASEDIR/bin:$PATH

export BASEDIR
export PATH

# environment variables

# set custom tag if user set variable previously
CUSTOM_TAG=unknown
# load rc file if present
if [ -r $BASEDIR/.datafilesrc ]; then
  . $BASEDIR/.datafilesrc
fi

if [ $CUSTOM_TAG = "unknown" ]; then
    CUSTOM_TAG=01_custom
fi
# user input - <year>_<model>
ui_valid=false
until [ "$ui_valid" = "true" ]
  do
  echo "Enter custom tag for model data [default is $CUSTOM_TAG]:"
  read ui_input
  case "$ui_input" in
      "")
      CUSTOM_TAG=$CUSTOM_TAG
      ;;
      *)
      CUSTOM_TAG=$ui_input
      ;;
  esac
  echo "output data files will be placed in $BASEDIR/sourceData/$CUSTOM_TAG, is this okay? [yes]:"
  read response
  if [ "$response" = "yes" -o "$response" = "" ] ; then
      ui_valid=true
  fi
done

# model switch variables
STRICT_MODEL=yes
MODERATE_MODEL=no
RELAXED_MODEL=no

echo "which models would you like to run?"
echo "would you like to run the strict model? [$STRICT_MODEL]: "
read response
if [ "$response" = "yes" -o "$response" = "" ] ; then
    STRICT_MODEL=yes
else
    STRICT_MODEL=no
fi
# echo "would you like to run the moderate model? [$MODERATE_MODEL]: "
# read response
# if [ "$response" = "yes" ] ; then
#     MODERATE_MODEL=$response
# fi
echo "would you like to run the relaxed model? [$RELAXED_MODEL]: "
read response
if [ "$response" = "yes" ] ; then
    RELAXED_MODEL=$response
fi
echo "model setttings:"
echo " STRICT_MODEL=$STRICT_MODEL"
echo " MODERATE_MODEL=$MODERATE_MODEL"
echo " RELAXED_MODEL=$RELAXED_MODEL"

# workspace directory paths
WORKSPACE=${BASEDIR}/sourceData/${CUSTOM_TAG}
MWI=${WORKSPACE}/01metawordindex
TREECODES=${WORKSPACE}/02treecodes
VARIANTS=${WORKSPACE}/03variants
SYNONYMS=$WORKSPACE/04synonyms
ABBR_ACRONYMS=$WORKSPACE/05abbrAcronyms
UMLSDIR=${WORKSPACE}/umls

#
# generate MWI files
#

# run 01CreateWorkFiles
cd $MWI
echo "creating work files..."
./01CreateWorkFiles
echo "done."

cd $MWI
./02Suppress

echo "Preparing workspace for Filtering..."
cd $MWI
./03FilterPrep

if [ "$RELAXED_MODEL" = "yes" ] ; then
  # run 04FilterRelaxed
  echo "Filtering relaxed model..."
  cd $MWI
  ./04FilterRelaxed
fi

if [ "$MODERATE_MODEL" = "yes" ] ; then
  # run 04FilterModerate
  echo "Filtering moderate model..."
  cd $MWI
  ./04FilterModerate
fi

if [ "$STRICT_MODEL" = "yes" ] ; then
  # run 04FilterStrict
  echo "Filtering strict model..."
  cd $MWI
  # was: ./04FilterStrict
  ./04FilterStrictParallel
  ./04FilterStrictParallelComplete
fi

# run 05GenerateMWIFiles
echo "generating metaword index files"
cd $MWI
./05GenerateMWIFiles

# run 01GenerateTreecodes
echo "generating treecode files"
cd $TREECODES
./01GenerateTreecodes

# run 01GenerateVariants
echo "generating variants"
cd $VARIANTS
./01GenerateVariants

# run 01GenerateSynonyms
echo "generating synonyms"
cd $SYNONYMS
./01GenerateSynonyms

# run 01GenerateAbbrAcronyms
echo "generating abbreviations and acronyms"
cd $ABBR_ACRONYMS
./01GenerateAbbrAcronyms

# end of script
