#!/bin/sh
# $Id: loaddatafiles.sh.TEMPLATE,v 1.21 2007/02/16 17:54:38 wrogers Exp $
#
# <MMTX>/config/loaddatafiles.sh -- setup dfbuilder files into database
#
# *** population of dataset after running datafile builder
# 
# mwifiles: all_words.txt concept_cui.txt concept_st.txt cui_sui.txt first_words.txt first_words_of_one.txt first_words_of_two.txt sui_cui.txt sui_nmstr_str.txt
# 
# sourceData/01_custom/01metawordindex/model.[relaxed|moderate|strict]/[mwifiles] -> data/01_custom/[relaxed|moderate|strict]/[mwifiles]
# sourceData/01_custom/02treecodes/treecodes.txt                                  -> data/01_custom/mmtx/treecodes.txt
# sourceData/01_custom/03variants/fullVars.txt                                    -> data/01_custom/lexicon/fullVars.txt
# 

#-----------------------------------------------------------
# MetaMap base directory and program path
#-----------------------------------------------------------
BASEDIR=/home/luizperciliano/metamap-portugues/metamap/public_mm
PATH=$BASEDIR/bin:$PATH
export LD_LIBRARY_PATH=$BASEDIR/lib

SYSTEM=`uname`

export BASEDIR
export PATH

# set custom tag if user set variable previously
CUSTOM_TAG=unknown
# load rc file if present
if [ -r $BASEDIR/.datafilesrc ]; then
  . $BASEDIR/.datafilesrc
fi

if [ $CUSTOM_TAG = "unknown" ]; then
    CUSTOM_TAG=01_custom
fi

if [ -z "$LEX_YEAR" ]; then
    LEX_YEAR=2016
fi

if [ -z "$DATA_YEAR" ]; then
    DATA_YEAR=2016AA
fi

# Ask user for custom tag for dataset.
# user input - <year>_<model>
ui_valid=false
until [ "$ui_valid" = "true" ]
  do
  echo "Enter workspace name (<year>_<source>) for model data [default is $CUSTOM_TAG]:"
  read ui_input
  case "$ui_input" in
      "")
      CUSTOM_TAG=$CUSTOM_TAG
      ;;
      *)
      CUSTOM_TAG=$ui_input
      ;;
  esac
  echo "  Data files to be loaded will be read from $BASEDIR/sourceData/$CUSTOM_TAG, is this okay? [yes]:"
  read response
   if [ "$response" = "yes" -o "$response" = "" ] ; then
      ui_valid=true
  fi
done

# load any setting specific to CUSTOM_TAG
. $BASEDIR/.datafilesrc.$CUSTOM_TAG

# Ask user for datayear of dataset.
# user input - <year><release>, for example: 2016AA
ui_valid=false
until [ "$ui_valid" = "true" ]
  do
  echo "Enter data year name (<year><release>) for model data [default is $DATA_YEAR]:"
  read ui_input
  case "$ui_input" in
      "")
      DATA_YEAR=$DATA_YEAR
      ;;
      *)
      DATA_YEAR=$ui_input
      ;;
  esac
  echo "The final DB files will reside in $BASEDIR/DB/DB.$CUSTOM_TAG.$DATA_YEAR.<model>, is this okay? [yes]:"
  read response
   if [ "$response" = "yes" -o "$response" = "" ] ; then
      ui_valid=true
  fi
done
     
# workspace directory paths
WORKSPACE=$BASEDIR/sourceData/$CUSTOM_TAG
MWI=$WORKSPACE/01metawordindex
TREECODES=$WORKSPACE/02treecodes
VARIANTS=$WORKSPACE/03variants
SYNONYMS=$WORKSPACE/04synonyms
ACROABBR=$WORKSPACE/05abbrAcronyms
SOURCEINFO=$MWI/Filter
UMLSDIR=$WORKSPACE/umls

# Check existing model directories for valid models if model directory
# exists and all necessary files are present, then ask user if
# model dataset should be loaded.

LOAD_RELAXED=no
LOAD_MODERATE=no
LOAD_STRICT=no
selected=""

# make base directory 
mkdir -p $BASEDIR/DB/DB.$CUSTOM_TAG.$DATA_YEAR.base

# required metawordindex file for valid dataset.

 MWIFILES="all_words.txt concept_cui.txt concept_st.txt cui_sui.txt first_words.txt first_words_of_one.txt first_words_of_two.txt sui_cui.txt sui_nmstr_str.txt"

if [ -d $MWI/model.relaxed ] ; then
    validmodel=yes
    missing=""
    for mwifile in $MWIFILES
      do
      if [ ! -f $MWI/model.relaxed/$mwifile ] ; then
	  validmodel=no
	  missing="$missing $mwifile"
      fi
    done
    if [ "$validmodel" = "yes" ]; then
	echo "  Would you like to load the relaxed model? [no]: "
	read response
	if [ "$response" = "yes" ] ; then
	    LOAD_RELAXED=yes
	    selected="$selected relaxed"
	fi
    else
	echo "WARNING: Relaxed model will not be loaded, Some files are missing from model directory."
	echo "  missing files: $missing"
    fi
else
    echo "WARNING: Relaxed model will not be loaded, relaxed model directory not present."
fi

if [ -d $MWI/model.moderate ] ; then
    validmodel=yes
    missing=""
    for mwifile in $MWIFILES
      do
      if [ ! -f $MWI/model.moderate/$mwifile ] ; then
	  validmodel=no
	  missing="$missing $mwifile"
      fi
    done
    if [ "$validmodel" = "yes" ]; then
	echo "  Would you like to load the moderate model? [no]: "
	read response
	if [ "$response" = "yes" ] ; then
	    LOAD_MODERATE=yes
	    selected="$selected moderate"
	fi
    else
	echo "WARNING: Moderate model will not be loaded, Some files are missing from model directory."
	echo "  missing files: $missing"
    fi
else
    echo "WARNING: Moderate model will not be loaded, moderate model directory not present."
fi

if [ -d $MWI/model.strict ] ; then
    validmodel=yes
    missing=""
    for mwifile in $MWIFILES
      do
      if [ ! -f $MWI/model.strict/$mwifile ] ; then
	  validmodel=no
	  missing="$missing $mwifile"
      fi
    done
    if [ "$validmodel" = "yes" ]; then
	echo "  Would you like to load the strict model? [no]: "
	read response
	if [ "$response" = "yes" ] ; then
	    LOAD_STRICT=yes
	    selected="$selected strict"
	fi
    else
	echo "WARNING: Strict model will not be loaded, some files are missing from model directory."
	echo "  missing files: $missing"
    fi
else
    echo "WARNING: Strict model will not be loaded, strict model directory not present."
fi

# Copy generated data files to
# $BASEDIR/data/$CUSTOM_TAG/[lexicon|mmtx|strict|moderate|relaxed]/*.txt
# and then load requested data files into db

DBEXT=""
DATAFILESET=$BASEDIR/DB${DBEXT}/DB.$CUSTOM_TAG.$DATA_YEAR.base
echo "  Linking generated data files to $DATAFILESET."
mkdir -p $DATAFILESET
rm -f $DATAFILESET/*.txt
cp $BASEDIR/scripts/dfbuilderRRF/dbconfig/config* $DATAFILESET
(cd $DATAFILESET && ln -s $TREECODES/mesh_mh_opt.txt . )
(cd $DATAFILESET && ln -s $TREECODES/mesh_tc_strict.txt . )
(cd $DATAFILESET && ln -s $TREECODES/mesh_tc_relaxed.txt . )
(cd $DATAFILESET && ln -s $TREECODES/meta_mesh_opt.txt . )
(cd $DATAFILESET && ln -s $TREECODES/meta_mesh_tc_opt.txt . )
(cd $DATAFILESET && ln -s $MWI/Filter/cui_sourceinfo.txt . )
(cd $DATAFILESET && ln -s $MWI/Filter/cui_src.txt . )
(cd $DATAFILESET && ln -s $MWI/Filter/cui_srcs_sts.txt . )
(cd $DATAFILESET && ln -s $MWI/SAB/sab_??.txt . )
(cd $DATAFILESET && ln -s $VARIANTS/var*.txt . )
(cd $DATAFILESET && ln -s $SYNONYMS/syns.txt . )
(cd $DATAFILESET && ln -s $ACROABBR/nls_*.txt . )

echo "  Building indexes from data files in $DATAFILESET."
(cd $DATAFILESET && rm -f config )
(cd $DATAFILESET && ln -s config.common config )

case $SYSTEM in
    MINGW*)
	dos2unix $DATAFILESET/config
	(cd $DATAFILESET && pwd -W | $BASEDIR/bin/create_bulk )
	;;
    *)
	(cd $DATAFILESET && echo $DATAFILESET | $BASEDIR/bin/create_bulk )
	;;
esac

indexmodel ()
{
    DATAFILESET=$BASEDIR/DB${DBEXT}/DB.$CUSTOM_TAG.$DATA_YEAR.$MODEL

    echo "  Copying generated data files to $DATAFILESET."
    mkdir -p $DATAFILESET
    # cp $MWI/model.strict/*.txt $DATAFILESET/
    (cd $DATAFILESET && ln $MWI/model.$MODEL/*.txt . )
    (cd $DATAFILESET && ln $MWI/model.$MODEL/cui_concept cui_concept.txt )

    echo "  Building indexes from data files in $DATAFILESET."
    (cd $DATAFILESET && rm -f config )
    (cd $DATAFILESET && ln -s ../DB.$CUSTOM_TAG.$DATA_YEAR.base/config.01 config )

    case $SYSTEM in
	Windows_NT | MINGW* | CYGWIN*)
	    dos2unix $DATAFILESET/config
	    (cd $DATAFILESET && pwd -W | $BASEDIR/bin/create_bulk )
	    ;;
	*)
	    (cd $DATAFILESET && echo $DATAFILESET | $BASEDIR/bin/create_bulk )
	    ;;
    esac

    echo "  Linking common indexes from ../DB.$CUSTOM_TAG.$DATA_YEAR.base to $DATAFILESET."
    (cd $DATAFILESET && ln -s ../DB.$CUSTOM_TAG.$DATA_YEAR.base/vars . )
    (cd $DATAFILESET && ln -s ../DB.$CUSTOM_TAG.$DATA_YEAR.base/varsan . )
    (cd $DATAFILESET && ln -s ../DB.$CUSTOM_TAG.$DATA_YEAR.base/varsanu . )
    (cd $DATAFILESET && ln -s ../DB.$CUSTOM_TAG.$DATA_YEAR.base/varsu . )
    (cd $DATAFILESET && ln -s ../DB.$CUSTOM_TAG.$DATA_YEAR.base/meshtcstrict . )
    (cd $DATAFILESET && ln -s ../DB.$CUSTOM_TAG.$DATA_YEAR.base/meshmh . )
    (cd $DATAFILESET && ln -s ../DB.$CUSTOM_TAG.$DATA_YEAR.base/meshtcrelaxed . )
    (cd $DATAFILESET && ln -s ../DB.$CUSTOM_TAG.$DATA_YEAR.base/syns . )
    (cd $DATAFILESET && ln -s ../DB.$CUSTOM_TAG.$DATA_YEAR.base/nlsaau . )
    (cd $DATAFILESET && ln -s ../DB.$CUSTOM_TAG.$DATA_YEAR.base/nlsaa . )
    (cd $DATAFILESET && ln -s ../DB.$CUSTOM_TAG.$DATA_YEAR.base/metameshtc . )
    (cd $DATAFILESET && ln -s ../DB.$CUSTOM_TAG.$DATA_YEAR.base/metamesh . )
    (cd $DATAFILESET && ln -s ../DB.$CUSTOM_TAG.$DATA_YEAR.base/cuisourceinfo . )
    (cd $DATAFILESET && ln -s ../DB.$CUSTOM_TAG.$DATA_YEAR.base/cuisrc . )
    (cd $DATAFILESET && ln -s ../DB.$CUSTOM_TAG.$DATA_YEAR.base/cui_srcs_sts . )
    (cd $DATAFILESET && ln -s ../DB.$CUSTOM_TAG.$DATA_YEAR.base/sab_rv . )
    (cd $DATAFILESET && ln -s ../DB.$CUSTOM_TAG.$DATA_YEAR.base/sab_vr . )
    (cd $DATAFILESET && rm -f config )
    (cd $DATAFILESET && ln -s ../DB.$CUSTOM_TAG.$DATA_YEAR.base/config.02 config )

    # Setup Lexicon DB Files
    case $SYSTEM in
	Windows_NT | MINGW* | CYGWIN*)
	    echo "  Copying lexicon indexes from ../DB.USAbase.$DATA_YEAR.strict to $DATAFILESET."
	    (cd $DATAFILESET && cp ../DB.USAbase.$DATA_YEAR.strict/dm_vars . ) 
	    (cd $DATAFILESET && cp ../DB.USAbase.$DATA_YEAR.strict/im_vars . ) 
	    (cd $DATAFILESET && cp ../DB.USAbase.$DATA_YEAR.strict/lex_form . ) 
	    (cd $DATAFILESET && cp ../DB.USAbase.$DATA_YEAR.strict/lex_rec . ) 
	    (cd $DATAFILESET && cp ../DB.USAbase.$DATA_YEAR.strict/norm_prefix . ) 
	    ;;
	*)
	    echo "  Linking lexicon indexes from ../../lexicon/data/$LEX_YEAR to $DATAFILESET."
	    (cd $DATAFILESET && ln -s ../../lexicon/data/$LEX_YEAR/dm_vars . ) 
	    (cd $DATAFILESET && ln -s ../../lexicon/data/$LEX_YEAR/im_vars . ) 
	    (cd $DATAFILESET && ln -s ../../lexicon/data/$LEX_YEAR/lex_form . ) 
	    (cd $DATAFILESET && ln -s ../../lexicon/data/$LEX_YEAR/lex_rec . ) 
	    (cd $DATAFILESET && ln -s ../../lexicon/data/$LEX_YEAR/norm_prefix . ) 
	    ;;
    esac
}

if [ "$LOAD_RELAXED" = "yes" ] ; then
    MODEL=relaxed
    indexmodel
fi

if [ "$LOAD_MODERATE" = "yes" ] ; then
    MODEL=moderate
    indexmodel
fi

if [ "$LOAD_STRICT" = "yes" ] ; then
    MODEL=strict
    indexmodel
fi

exit 0

# end of script
