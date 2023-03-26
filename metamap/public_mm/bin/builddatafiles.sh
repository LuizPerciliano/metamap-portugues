#!/bin/bash
# $Id: builddatafiles.sh.TEMPLATE,v 1.25 2007/02/16 20:22:26 wrogers Exp $
#
# <BASEDIR>/bin/builddatafiles.sh -- setup dfbuilder environment
#
# * preparation of workspace for datafile builder
#
# data/2001/mmtx/semdef.txt                   -> data/01_custom/mmtx/semdef.txt
# 
# data/dfbuilder/2001/st.raw                  -> sourceData/01_custom/01metawordindex/st.raw
# data/dfbuilder/2001/suppressibles.txt       -> sourceData/01_custom/01metawordindex/suppressibles.txt
# data/dfbuilder/2001/MRCON.mesh              -> sourceData/01_custom/02treecodes/MRCON.mesh (link)
# data/dfbuilder/2001/infl.txt                -> sourceData/01_custom/03variants/infl.txt
# data/dfbuilder/2001/infl.txt.missed         -> sourceData/01_custom/03variants/infl.txt.missed
# 

#-----------------------------------------------------------
# MetaMap base directory and program path
#-----------------------------------------------------------
BASEDIR=/home/luizperciliano/metamap-portugues/metamap/public_mm
PATH=$BASEDIR/bin:$PATH

export BASEDIR
export PATH

case $OS in
    *NT*) 
	CMD=cp ; CMDFLAG=-p
	;;
    *)
	CMD=ln ; CMDFLAG=-s
	;;
esac

# environment variables

CUSTOM_TAG=Custom

# user input - > <MM Data Version Name>
ui_valid=false
until [ "$ui_valid" = "true" ]
do
  echo "Enter workspace name (DataVersionName)[default is $CUSTOM_TAG]:"
  ui_input="2022AB-PORTUGUES"
  case "$ui_input" in
    "")
      CUSTOM_TAG=$CUSTOM_TAG
    ;;
    *)
      CUSTOM_TAG=$ui_input
    ;;
  esac
  echo "Workspace will be placed in $BASEDIR/sourceData/$CUSTOM_TAG, is this okay? [yes]:"
  response="yes"
  if [ "$response" = "yes" -o "$response" = "" ] ; then
      ui_valid=true
  fi
done

# default Knowledge Source Year
KSYear=2016

echo ""
# Check in public_mm/DB for base (must exist) and strict or relaxed
# (one must exist) directories.
# 
echo "MetaMap Data Sets:"
index=0
for directory in $BASEDIR/DB/*; do
    # echo "checking directory $directory"    
    if [ -e "$directory/all_words" ]; then
	index=`expr $index + 1`
	echo "$index) $directory"
	resourcedir[$index]=$directory
    elif [ -e "$directory/all_words" ]; then
	index=`expr $index + 1`
	echo "$index) $directory"
	resourcedir[$index]=$directory
    fi
done
DB_DEFAULT_DIR=${resourcedir[$index]}
echo "Use which Data Set directory? [default: $index) $DB_DEFAULT_DIR]"
DB_SELECT=""
if [ "$DB_SELECT" = "" ]; then
    DFB_DBDIR=$DB_DEFAULT_DIR
else
    DFB_DBDIR=${resourcedir[$DB_SELECT]}
fi     
echo "$DFB_DBDIR has been selected."
echo ""
IFS=. read -r prefix DATA_VERSION DATA_YEAR MODEL <<< "$DFB_DBDIR"
# DATA_VERSION=`echo $DFB_DBDIR | awk 'BEGIN { FS = "." } { print $2 }'`
# DATA_YEAR=`echo $DFB_DBDIR | awk 'BEGIN { FS = "." } { print $3 }'`
# MODEL=`echo $DFB_DBDIR | awk 'BEGIN { FS = "." } { print $4 }'`
KSYear=`echo $DATA_YEAR | awk '{ print substr($1, 1, 4) }'`
RELEASE=`echo $DATA_YEAR | awk '{ print substr($1, 5, 2) }'`

# Check for base directory using user selection
basedir="DB/DB.${DATA_VERSION}.${DATA_YEAR}.base"
if [ -e $basedir ]; then
    echo "found base directory $basedir"
    echo "DATA_VERSION=$DATA_VERSION"
    echo "DATA_YEAR=$DATA_YEAR"
    echo "MODEL=$MODEL"
    echo "KSYear=$KSYear"
    echo "RELEASE=$RELEASE"
else
    echo "base directory $basedir for $DFB_DBDIR is missing."
fi

# Define environment variable MODELOPTION for filter_mrconso and
# mm_variants.
case $MODEL in
    relaxed)
	MODELOPTION="--relaxed_model";;
    strict)
	MODELOPTION="--strict_model";;
    default)
	MODELOPTION="--strict_model";;
esac

# Check lexicon/data for lexiconStatic????
echo ""
echo "MetaMap Lexicons:"
index=0
for file in $BASEDIR/lexicon/data/lexiconStatic*; do
    index=`expr $index + 1`
    echo "$index) $file"
    lexiconflatfile[$index]=$file
done
LEXICON_FLAT_FILE=${lexiconflatfile[$index]}
echo "Use which Lexicon file? [default: $index) $LEXICON_FLAT_FILE]"
LEX_SELECT=""
if [ "$LEX_SELECT" = "" ]; then
    LEXICON_FLAT_FILE=${lexiconflatfile[$index]}
else
    LEXICON_FLAT_FILE=${lexiconflatfile[$LEX_SELECT]}
fi     
echo "$LEXICON_FLAT_FILE has been selected."


# Check in public_mm/data/dfbuilder/* for latest inflVars.data,
# MRSAB.RRF, SM.DB, specialterms.txt, st.raw, suppressibles.txt files.
# Prompt user for selection; store selection in DFB_RESDIR.
echo "DFB Resources:"
index=0
for directory in $BASEDIR/data/dfbuilder/*; do
    # echo "checking directory $directory"    
    if [ -e "$directory/SM.DB" ]; then
	index=`expr $index + 1`
	echo "$index) $directory"
	resourcedir[$index]=$directory
    fi
done
RES_DEFAULT_DIR=${resourcedir[$index]}
	       
echo ""
echo "Use which dfbuilder resource directory? [default: $index) $RES_DEFAULT_DIR]"
RES_SELECT=""
if [ "$RES_SELECT" = "" ]; then
    DFB_RESDIR=$RES_DEFAULT_DIR
else
    DFB_RESDIR=${resourcedir[$RES_SELECT]}
fi     
echo "$DFB_RESDIR has been selected."
echo ""
# user input - <year>
ui_valid=false
until [ "$ui_valid" = "true" ]
do
  echo "Enter Knowledge Source year (<4 digit year>)[default is $KSYear]:"
  ui_input="2022"
  case "$ui_input" in
    "")
      KSYear=$KSYear
      ui_valid=true
    ;;
    *)
      KSYear=$ui_input
      ui_valid=true
    ;;
  esac
done

LEX_YEAR=$KSYear
# RELEASE="AA"
# DATA_YEAR="${KSYear}${RELEASE}"

# user input - <year>
ui_valid=false
until [ "$ui_valid" = "true" ]
do
  echo "Enter Knowledge Source Release (<2 letters> (usually: AA or AB)[default is $RELEASE]:"
  ui_input="AB"
  case "$ui_input" in
    "")
      RELEASE=$RELEASE
      ui_valid=true
    ;;
    *)
      RELEASE=$ui_input
      ui_valid=true
    ;;
  esac
done
export DATA_YEAR="${KSYear}${RELEASE}"

# save custom tag info for loaddatafiles in rc file 
cat > $BASEDIR/.datafilesrc <<'END_OF_FILE'
# .datafilesrc -- data file builder rc file
END_OF_FILE
echo "CUSTOM_TAG=$CUSTOM_TAG"     >> $BASEDIR/.datafilesrc
echo "export CUSTOM_TAG"          >> $BASEDIR/.datafilesrc
echo "KSYear=$KSYear"             >> $BASEDIR/.datafilesrc
echo "export KSYear"              >> $BASEDIR/.datafilesrc
echo "LEX_YEAR=$LEX_YEAR"         >> $BASEDIR/.datafilesrc
echo "export LEX_YEAR"            >> $BASEDIR/.datafilesrc
echo "DATA_YEAR=$DATA_YEAR"       >> $BASEDIR/.datafilesrc
echo "export DATA_YEAR"           >> $BASEDIR/.datafilesrc
echo "RELEASE=$RELEASE"           >> $BASEDIR/.datafilesrc
echo "export RELEASE"             >> $BASEDIR/.datafilesrc
echo "DATA_VERSION=$DATA_VERSION" >> $BASEDIR/.datafilesrc
echo "export DATA_VERSION"        >> $BASEDIR/.datafilesrc
echo "DATA_YEAR=$DATA_YEAR"       >> $BASEDIR/.datafilesrc
echo "export DATA_YEAR"           >> $BASEDIR/.datafilesrc
echo "MODEL=$MODEL"               >> $BASEDIR/.datafilesrc
echo "export MODEL"               >> $BASEDIR/.datafilesrc
echo "LEXICON_FLAT_FILE=$LEXICON_FLAT_FILE" >> $BASEDIR/.datafilesrc
echo "export=LEXICON_FLAT_FILE"   >> $BASEDIR/.datafilesrc
echo "# end of .datafilesrc"      >> $BASEDIR/.datafilesrc
# copy settings to custom_tag specific file.
cp $BASEDIR/.datafilesrc $BASEDIR/.datafilesrc.$CUSTOM_TAG
echo " "
echo "  This script builds the workspace and "
echo "  creates links to some of your source files."
echo " "
# create workspace directories

if [ -d $BASEDIR/sourceData/$CUSTOM_TAG/umls ] ; then
    echo "     Creating $BASEDIR/sourceData/$CUSTOM_TAG/01metawordindex/..."
    mkdir -p $BASEDIR/sourceData/$CUSTOM_TAG/01metawordindex
    mkdir -p $BASEDIR/sourceData/$CUSTOM_TAG/01metawordindex/Suppress
    mkdir -p $BASEDIR/sourceData/$CUSTOM_TAG/01metawordindex/Filter
    mkdir -p $BASEDIR/sourceData/$CUSTOM_TAG/01metawordindex/Generate
    mkdir -p $BASEDIR/sourceData/$CUSTOM_TAG/02treecodes
    mkdir -p $BASEDIR/sourceData/$CUSTOM_TAG/03variants
    mkdir -p $BASEDIR/sourceData/$CUSTOM_TAG/04synonyms
    mkdir -p $BASEDIR/sourceData/$CUSTOM_TAG/05abbrAcronyms
    cp $BASEDIR/bin/dfbuilder.profile $BASEDIR/sourceData/$CUSTOM_TAG/dfbuilder.profile
else
    echo "Error didn't find $BASEDIR/sourceData/$CUSTOM_TAG/umls directory, aborting..."
    exit 1
fi

# workspace directory paths
WORKSPACE=$BASEDIR/sourceData/$CUSTOM_TAG
MWI=$WORKSPACE/01metawordindex
TREECODES=$WORKSPACE/02treecodes
VARIANTS=$WORKSPACE/03variants
SYNONYMS=$WORKSPACE/04synonyms
ABBR_ACRONYMS=$WORKSPACE/05abbrAcronyms

UMLSDIR=$WORKSPACE/umls

echo "     Preparing workspace..."

# link user's UMLS files into workspace
UMLSFILE=$UMLSDIR/MRCONSO.RRF
LINKFILE=$MWI/MRCONSO.RRF
if [ -f $UMLSFILE ] ; then
    $CMD $CMDFLAG $UMLSFILE $LINKFILE
else
   echo "file $UMLSFILE is missing, aborting..."
   exit 1
fi

UMLSFILE=$UMLSDIR/MRSTY.RRF
if [ -f $UMLSFILE ] ; then
    $CMD $CMDFLAG $UMLSFILE $MWI
else
   echo "file $UMLSFILE is missing, aborting..."
   exit 1
fi

UMLSFILE=$UMLSDIR/MRRANK.RRF
if [ -f $UMLSFILE ] ; then
    $CMD $CMDFLAG $UMLSFILE $MWI
else
    echo "file $UMLSFILE is missing, using distribution supplied MRRANK ..."
    UMLSFILE=$DFB_RESDIR/MRRANK.RRF
    if [ -f $UMLSFILE ] ; then
	$CMD $CMDFLAG $UMLSFILE $MWI
    else
	echo "file $UMLSFILE is missing, aborting..."
	exit 1
    fi
fi

UMLSFILE=$UMLSDIR/MRSAB.RRF
if [ -f $UMLSFILE ] ; then
    $CMD $CMDFLAG $UMLSFILE $MWI
else
    echo "file $UMLSFILE is missing, using distribution supplied MRSAB ..."
    UMLSFILE=$DFB_RESDIR/MRSAB
    if [ -f $UMLSFILE ] ; then
	$CMD $CMDFLAG $UMLSFILE $MWI
    else
	echo "file $UMLSFILE is missing, aborting..."
	exit 1
    fi
fi

UMLSFILE=$UMLSDIR/SM.DB
if [ -f $UMLSFILE ] ; then
    $CMD $CMDFLAG $UMLSFILE $SYNONYMS/SM.DB.orig
else
    echo "file $UMLSFILE is missing, using distribution supplied SM.DB ..."
    UMLSFILE=$DFB_RESDIR/SM.DB
    if [ -f $UMLSFILE ] ; then
	$CMD $CMDFLAG $UMLSFILE $SYNONYMS/SM.DB.orig
    else
	echo "file $UMLSFILE is missing, aborting..."
	exit 1
    fi
fi

# link distribution MRCON.mesh and MRSAT into treecodes
UMLSFILE=$UMLSDIR/MRSAT.RRF
if [ -f $UMLSFILE ] ; then
    $CMD $CMDFLAG $UMLSFILE $TREECODES
else
   echo "WARNING: file $UMLSFILE is missing, continuing..."
fi

UMLSFILE=$UMLSDIR/MRCONSO.mesh
if [ -f $UMLSFILE ] ; then
    $CMD $CMDFLAG $UMLSFILE $TREECODES
else
    UMLSFILE=$DFB_RESDIR/MRCONSO.mesh
    if [ -f $UMLSFILE ] ; then
	$CMD $CMDFLAG $UMLSFILE $TREECODES
    else
	echo "file $UMLSFILE is missing, aborting..."
	exit 1
    fi
fi

# Move user-specified inflection and semantic type definitions to 
# custom dataset.

# cp -R $BASEDIR/data/$KSYear/lexicon                 $BASEDIR/data/$CUSTOM_TAG/
# These are not used in a loaded model, just to build a new model
#cp $BASEDIR/data/$KSYear/lexicon/infl.txt            $BASEDIR/data/$CUSTOM_TAG/lexicon/
#cp $BASEDIR/data/$KSYear/lexicon/infl.txt.missed     $BASEDIR/data/$CUSTOM_TAG/lexicon/
#cp $BASEDIR/data/$KSYear/mmtx/semdef.txt            $BASEDIR/data/$CUSTOM_TAG/mmtx

# copy data into workspace
cp $DFB_RESDIR/st.raw            $MWI
cp $DFB_RESDIR/suppressibles.txt $MWI/Suppress/
cp $DFB_RESDIR/specialterms.txt  $MWI/Suppress/
cp $BASEDIR/data/dfbuilder/Hierarchy.Susanne.TQ      $TREECODES
# cp $BASEDIR/data/$KSYear/lexicon/infl.txt            $VARIANTS
# cp $BASEDIR/data/$KSYear/lexicon/infl.txt.missed     $VARIANTS
# The new files are deployed each year in the lexicon dir not the dfbuilder dir
# cp $DFB_RESDIR/infl.txt          $VARIANTS
# cp $DFB_RESDIR/infl.txt.missed   $VARIANTS
# cp $DFB_RESDIR/inflVars.data.ascii $VARIANTS

# copy scripts into workspace
SCRIPTS=$BASEDIR/scripts/dfbuilderRRF
AASCRIPTS=$SCRIPTS/AbbrAcronyms
MWISCRIPTS=$SCRIPTS/Metawordindex
SYNSCRIPTS=$SCRIPTS/Synonyms
TCSCRIPTS=$SCRIPTS/Treecodes
VARSCRIPTS=$SCRIPTS/Variants

cp $MWISCRIPTS/01CreateWorkFiles      $MWI
chmod +x $MWI/01CreateWorkFiles
cp $MWISCRIPTS/02Suppress             $MWI
chmod +x $MWI/02Suppress
cp $MWISCRIPTS/03FilterPrep           $MWI
chmod +x $MWI/03FilterPrep
cp $MWISCRIPTS/04FilterRelaxed        $MWI
chmod +x $MWI/04FilterRelaxed
cp $MWISCRIPTS/04FilterStrict         $MWI
chmod +x $MWI/04FilterStrict
cp $MWISCRIPTS/04FilterStrictMore     $MWI
chmod +x $MWI/04FilterStrictMore
cp $MWISCRIPTS/04FilterStrictCheck     $MWI
chmod +x $MWI/04FilterStrictCheck
cp $MWISCRIPTS/04FilterShared         $MWI
chmod +x $MWI/04FilterShared
cp $MWISCRIPTS/05GenerateMWIFiles     $MWI
chmod +x $MWI/05GenerateMWIFiles
cp $MWISCRIPTS/filter_mrconso_ALL     $MWI
chmod +x $MWI/filter_mrconso_ALL
cp $MWISCRIPTS/consolidate_info_lines $MWI
chmod +x $MWI/consolidate_info_lines
cp $MWISCRIPTS/allocate_files         $MWI
chmod +x $MWI/allocate_files
cp $MWISCRIPTS/chunk_file             $MWI
chmod +x $MWI/chunk_file
cp $MWISCRIPTS/create_mrrank          $MWI
chmod +x $MWI/create_mrrank

cp $MWISCRIPTS/Filter/0ExpandIndex              $MWI/Filter/
chmod +x $MWI/Filter/0ExpandIndex
cp $MWISCRIPTS/Filter/split_filtered_mrconso    $MWI/Filter/
chmod +x $MWI/Filter/split_filtered_mrconso
cp $MWISCRIPTS/Filter/write_filter_mrconso_info $MWI/Filter/
chmod +x $MWI/Filter/write_filter_mrconso_info

cp $MWISCRIPTS/Filter/gen_CUI_srcs              $MWI/Filter/
chmod +x $MWI/Filter/gen_CUI_srcs
cp $MWISCRIPTS/Filter/gen_CUI_srcs_sts          $MWI/Filter/
chmod +x $MWI/Filter/gen_CUI_srcs_sts
cp $MWISCRIPTS/Filter/gen_CUI_STs               $MWI/Filter/
chmod +x $MWI/Filter/gen_CUI_STs

cp $MWISCRIPTS/Generate/0Generate1              $MWI/Generate/
chmod +x $MWI/Generate/0Generate1
cp $MWISCRIPTS/Generate/0Generate2              $MWI/Generate/
chmod +x $MWI/Generate/0Generate2
cp $MWISCRIPTS/Generate/0GenerateWideTable      $MWI/Generate/
chmod +x $MWI/Generate/0GenerateWideTable
cp $MWISCRIPTS/Generate/0GenerateLineCounts     $MWI/Generate/
chmod +x $MWI/Generate/0GenerateLineCounts
cp $MWISCRIPTS/Generate/0GenerateRenameToWide   $MWI/Generate/
chmod +x $MWI/Generate/0GenerateRenameToWide

cp $TCSCRIPTS/01GenerateTreecodes    $TREECODES
chmod +x $TREECODES/01GenerateTreecodes
cp $TCSCRIPTS/02Preliminary          $TREECODES
chmod +x $TREECODES/02Preliminary
cp $TCSCRIPTS/03Mesh                 $TREECODES
chmod +x $TREECODES/03Mesh
cp $TCSCRIPTS/04Mesh                 $TREECODES
chmod +x $TREECODES/04Mesh
cp $TCSCRIPTS/05Final                $TREECODES
chmod +x $TREECODES/05Final

cp $VARSCRIPTS/01GenerateVariants        $VARIANTS
chmod +x $VARIANTS/01GenerateVariants
cp $VARSCRIPTS/0doit.metalab $VARIANTS
cp $VARSCRIPTS/0doit0.lexlab $VARIANTS
cp $VARSCRIPTS/0doit1.lexlab $VARIANTS
cp $VARSCRIPTS/0doit.xwords  $VARIANTS
cp $VARSCRIPTS/0doit.lvglab  $VARIANTS
cp $VARSCRIPTS/stats.awk                 $VARIANTS

cp $SYNSCRIPTS/01GenerateSynonyms        $SYNONYMS
cp $SYNSCRIPTS/write_syns                $SYNONYMS
cp $SYNSCRIPTS/write_syns.perl           $SYNONYMS
cp $SYNSCRIPTS/0dowidths                 $SYNONYMS
cp $SYNSCRIPTS/maxline.awk               $SYNONYMS

cp $AASCRIPTS/01GenerateAbbrAcronyms $ABBR_ACRONYMS
cp $AASCRIPTS/extract_abbr.perl      $ABBR_ACRONYMS
cp $AASCRIPTS/write_aas              $ABBR_ACRONYMS
cp $AASCRIPTS/write_aas.perl         $ABBR_ACRONYMS
cp $AASCRIPTS/bogus_AAs              $ABBR_ACRONYMS

# copy modified version of dfbuilder.profile to workspace
# cp $BASEDIR/bin/dfbuilder.profile  $WORKSPACE
sed 's/___KSYear/'$KSYear'/g' $BASEDIR/bin/dfbuilder.profile  >$WORKSPACE/dfbuilder.profile

echo ""                            >> $WORKSPACE/dfbuilder.profile
echo "# Environment Variables:"    >> $WORKSPACE/dfbuilder.profile
echo ""                            >> $WORKSPACE/dfbuilder.profile
echo "CUSTOM_TAG=$CUSTOM_TAG"      >> $WORKSPACE/dfbuilder.profile
echo "export CUSTOM_TAG"           >> $WORKSPACE/dfbuilder.profile
echo "SUBSET=$CUSTOM_TAG"          >> $WORKSPACE/dfbuilder.profile
echo "export SUBSET"               >> $WORKSPACE/dfbuilder.profile
echo "KSYear=$KSYear"              >> $WORKSPACE/dfbuilder.profile
echo "export KSYear"               >> $WORKSPACE/dfbuilder.profile
echo "CURR_YEAR_4=$KSYear"         >> $WORKSPACE/dfbuilder.profile
echo "export CURR_YEAR_4"          >> $WORKSPACE/dfbuilder.profile
echo "CURR_RELEASE_LEVEL=$RELEASE" >> $WORKSPACE/dfbuilder.profile
echo "export CURR_RELEASE_LEVEL"   >> $WORKSPACE/dfbuilder.profile
echo "DATA_VERSION=$DATA_VERSION"  >> $WORKSPACE/dfbuilder.profile
echo "export DATA_VERSION"         >> $WORKSPACE/dfbuilder.profile
echo "DATA_YEAR=$DATA_YEAR"        >> $WORKSPACE/dfbuilder.profile
echo "export DATA_YEAR"            >> $WORKSPACE/dfbuilder.profile
echo "MODEL=$MODEL"                >> $WORKSPACE/dfbuilder.profile
echo "export MODEL"                >> $WORKSPACE/dfbuilder.profile
echo "# NOTE: MODELOPTION is currently not supported in filter_mrconso and mm_variants" >> $WORKSPACE/dfbuilder.profile
echo "MODELOPTION=$MODELOPTION"    >> $WORKSPACE/dfbuilder.profile
echo "export MODELOPTION"          >> $WORKSPACE/dfbuilder.profile
echo "LEXICON_FLAT_FILE=$LEXICON_FLAT_FILE" >> $WORKSPACE/dfbuilder.profile
echo "export=LEXICON_FLAT_FILE"    >> $WORKSPACE/dfbuilder.profile
echo ""                            >> $WORKSPACE/dfbuilder.profile
echo "# end of dfbuilder.profile"  >> $WORKSPACE/dfbuilder.profile

chmod +x $WORKSPACE/dfbuilder.profile

echo "done."
echo " "
echo " To begin creating data files: "
echo "     Go to $MWI"
echo "     Start the first script: 01CreateWorkFiles"
echo " "
# end of script
