#!/usr/local/bin/tclsh
# Data file builder install program - Tcl version

# Procedure: read_response
#
# PARAMS:
#   prompt
#   varname : name of variable to be set
#   vardefault : default value to set 
proc read_response { prompt varname vardefault } {
  upvar $varname localVar

  puts -nonewline [format "%s \[%s]\]: " $prompt $vardefault]
  flush stdout
  set resp [gets stdin]
  if { [string length [string trim $resp]] == 0} {
    set localVar $vardefault
  } else {
    set localVar $resp
  }
  puts [format "%s: %s" $varname $localVar]
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
  puts $rcfp "# Minimal Bourne shell setup script for datafile builder"
  puts $rcfp "#  use: source dfbsetup.sh to use"
  puts $rcfp [format "BASEDIR=\"%s\"" [bslash2fslash_unix $basedir]]
  puts $rcfp [format "JAVA_HOME=\"%s\"" [bslash2fslash_unix $java_home]]
  puts $rcfp [format "LVG_DIR=\"%s\"" [bslash2fslash_unix $lvg_dir]]
  puts $rcfp "BINDIR=\$BASEDIR/bin"
  puts $rcfp "PATH=\${BINDIR}:\${JAVA_HOME}/bin:\${LVG_DIR}/bin:\$PATH"
  puts $rcfp "export PATH"
  close $rcfp
  puts "Wrote Bourne setup script dfbsetup.sh."

  set rcfp [open "dfbsetup.csh" "w"]
  puts $rcfp "# Minimal CSH shell setup script for datafile builder"
  puts $rcfp "#  use: source dfbsetup.csh to use"
  puts $rcfp [format "setenv BASEDIR \"%s\"" [bslash2fslash_unix $basedir]]
  puts $rcfp [format "setenv JAVA_HOME \"%s\"" [bslash2fslash_unix $java_home]]
  puts $rcfp [format "setenv LVG_DIR \"%s\"" [bslash2fslash_unix $lvg_dir]]
  puts $rcfp "setenv BINDIR \${BASEDIR}/bin"
  puts $rcfp "set path = ( \$BINDIR \$JAVA_HOME/bin \$LVG_DIR/bin \$path )"
  close $rcfp
  puts "Wrote CSH setup script dfbsetup.csh."
}

# if rc file exists from previous run than source it.
set dfbrc_fn [format "%s/.install_dfb_rc.tcl" ${basedirpath}]
if [file exists $dfbrc_fn] {
  source $dfbrc_fn
}

read_response "Is LVG installed? " lvgpresent "n"
if { $lvgpresent == "y" || $lvgpresent == "Y" } {
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
  read_response "location of LVG" lvg_dir $lvg_dir

  # save user response in rc file.
  set dfbrc_fp [open $dfbrc_fn "w"]
  puts $dfbrc_fp "set env(LVG_DIR) \"$lvg_dir\""
  close $dfbrc_fp

  puts "Performing DFB Install"
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
} else {
  puts "LVG must be installed to use Data File Builder!  See the Lexical Tools"
  puts "Web Page to acquire LVG which is part of the Lexical Tools package:"
  puts "  http://lexsrv3.nlm.nih.gov/LexSysGroup/Summary/lexicalTools.html"
}
