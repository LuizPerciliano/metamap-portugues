# g:/Projects/test/dfb/public_mm/bin/ginstall_dfb.tcl, Fri Sep 09 10:46:48 2011
#
# ginstall_dfb.tcl - Public MetaMap Data File Builder Install Program
#
# This script uses global variables basedirpath and macro defined earlier

# Requires that LVG has been installed previously.

# Procedure: dfb_dialog
#
# GLOBALS:
#   lvg_dir     - LVG install directory
#   basedirpath - public_mm basedir, usually "public_mm"
#
proc dfb_dialog { } {
  global lvg_dir
  global basedirpath
  global env
  global dfbrc_fn

  # if rc file exists from previous run than source it.
  set dfbrc_fn [format "%s/.install_dfb_rc.tcl" ${basedirpath}]
  if [file exists $dfbrc_fn] {
    source $dfbrc_fn
  }
  if { ( [info exists lvg_dir] == 0 ) || ( $lvg_dir == "" ) } {
    if [info exists env(LVG_DIR)] {
      set lvg_dir $env(LVG_DIR)
    } else {
      if [info exists env(OS)] {
	if { $env(OS) == "Windows_NT" } {
	  set lvg_dir "C:/Program Files/lvg2013"
	} else {
	  set lvg_dir [getresidentdir lvg]
	}
      } else {
	set lvg_dir [getresidentdir lvg]
      }
    }
  }
  if { $basedirpath != "" } {
    set proglabel "MetaMap DFB Install"
    if [info exists env(LVG_DIR)] {
      set msgtext "The install program found that LVG_DIR \
was defined as $env(LVG_DIR). To use this as the \
installation just press the \"Next\" button.  Otherwise, enter \
the location of the LVG installation at prompt."
    } else {
      set msgtext "Enter the location of the LVG \
 installation at prompt."
    }
    set labeltext "Location of the LVG Installation Directory: "
    lappend entryinfo [list $labeltext lvg_dir]
    build_dialog .panel $proglabel $msgtext $entryinfo doPrevious dfbDoNext
  }
}

# Procedure: dfbDoNext
#
# Perform any necessary settings after dialog is finished.
#
# GLOBALS:
#   lvg_dir - LVG install directory
#    macro  - array of substitution macros
proc dfbDoNext { } {
  global lvg_dir
  global macro
  global dfbrc_fn

  # associative array of replacement patterns and their replacements
  #                             unixpath        win32path                 java_path
  set macro(@@lvgdir@@) [list ${lvg_dir} [fslash2bslash_win32 ${lvg_dir}] ${lvg_dir}]

  # save user response in rc file.
  set dfbrc_fp [open $dfbrc_fn "w"]
  fputs $dfbrc_fp "set env(LVG_DIR) \"$lvg_dir\""
  close $dfbrc_fp

  doNext
}

# Procedure: write_dfb_setup_scripts
#
# PARAMS:
#   basedir   - public_mm basedir, usually "public_mm"
#   java_home - Java JRE or SDK install directory
#   lvg_dir   - LVG install directory
#
proc write_dfb_setup_scripts { basedir java_home lvg_dir } {
  puts "Writing Bourne and CSH setup scripts..."
  set rcfp [open "dfbsetup.sh" "w"]
  fputs $rcfp "# Minimal Bourne shell setup script for datafile builder"
  fputs $rcfp "#  use: source dfbsetup.sh to use"
  fputs $rcfp [format "BASEDIR=\"%s\"" [bslash2fslash_unix $basedir]]
  fputs $rcfp [format "JAVA_HOME=\"%s\"" [bslash2fslash_unix $java_home]]
  fputs $rcfp [format "LVG_DIR=\"%s\"" [bslash2fslash_unix $lvg_dir]]
  fputs $rcfp "BINDIR=\$BASEDIR/bin"
  fputs $rcfp "PATH=\${BINDIR}:\${JAVA_HOME}/bin:\${LVG_DIR}/bin:\$PATH"
  fputs $rcfp "export PATH"
  close $rcfp
  puts "Wrote Bourne setup script dfbsetup.sh."

  set rcfp [open "dfbsetup.csh" "w"]
  fputs $rcfp "# Minimal CSH shell setup script for datafile builder"
  fputs $rcfp "#  use: source dfbsetup.csh to use"
  fputs $rcfp [format "setenv BASEDIR \"%s\"" [bslash2fslash_unix $basedir]]
  fputs $rcfp [format "setenv JAVA_HOME \"%s\"" [bslash2fslash_unix $java_home]]
  fputs $rcfp [format "setenv LVG_DIR \"%s\"" [bslash2fslash_unix $lvg_dir]]
  fputs $rcfp "setenv BINDIR \${BASEDIR}/bin"
  fputs $rcfp "set path = ( \$BINDIR \$JAVA_HOME/bin \$LVG_DIR/bin \$path )"
  close $rcfp
  puts "Wrote CSH setup script dfbsetup.csh."
}

# Procedure: dfb_install
#
# Actually install the dfb stuff.
#
# PARAMS:
#   panel       - dialog panel
#
# GLOBALS:
#   basedirpath - public_mm basedir, usually "public_mm"
#   javadirpath - Java JRE or SDK install directory
#   lvg_dir     - LVG install directory
#   macro       - array of substitution macros
#
proc dfb_install { panel } {
  global basedirpath
  global javadirpath
  global lvg_dir
  global macro
  global env

  puts "Performing DFB Install"
  ${panel}.proglabel config -text "Performing DFB MetaMap Install" -font {Courier 14 bold}
  foreach template [glob -nocomplain -directory ${basedirpath}/scripts/dfbuilderRRF *.in] {
    regsub {\.in} $template {} binscript
    genfile $template $binscript
    if { $env(OS) != "Windows_NT" } {
      file attributes $binscript -permissions ugo+x
    }
  }
  foreach template [glob -nocomplain -directory ${basedirpath}/scripts/dfbuilderRRF/Variants *.in] {
    regsub {\.in} $template {} binscript
    genfile $template $binscript
    if { $env(OS) != "Windows_NT" } {
      file attributes $binscript -permissions ugo+x
    }
  }
  write_dfb_setup_scripts $basedirpath $javadirpath $lvg_dir

  puts ""
  puts "Public MetaMap DFB Install Settings:"
  puts "  LVG dir: $lvg_dir"
  puts ""
  puts "DFB MetaMap Install Complete"
  ${panel}.proglabel config -text "DFB MetaMap Install Complete" -font {Courier 14 bold}
}

lappend dialog_list dfb_dialog
lappend additional_module_list dfb_install

