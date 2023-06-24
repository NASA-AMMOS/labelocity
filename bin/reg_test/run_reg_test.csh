#!/bin/csh

# run_reg_test.csh
# arguments and env variables used
# help option?
#
# we may need a MISSION argument to seed some of the templates and scripts/
# --MISSION [M2020, NSYT, MER, MSAM, MSL]
echo "run_reg_test.csh"
echo "args are $*"
echo "arg ct = $#argv"

echo "==================================="
set help = 0
# set verbose = 0
set debug = 0 

if (! $?V2TOP) then       
  echo "Not in VICAR select. "
else
  echo "in VICAR select."
endif

if (! $?CLASSPATH) then       
  echo "CLASSPATH has not been set. It must be set first. "
  echo "exiting"
  exit 0
else
  echo "CLASSPATH has  been set"
endif

# possible command line arguments. Use to override environment variables
set V2JBINarg=""
set V2TEMPLATESarg=""
set V2VEL_REGTEST_INPUTarg=""
set V2VEL_REGTEST_OUTPUTarg=""
set MISSION="none"
set PNG="false"

# CLASSPATH can't be set because of the * expansion.
# user must set the env CLASSPATH variable first

# V2VEL_REGTEST_INPUT and V2VEL_REGTEST_OUTPUT

# Bob suggested V2VEL_REGTEST_INPUT and V2VEL_REGTEST_REF
# V2VEL_REGTEST_INPUT and V2VEL_REGTEST_OUTPUT

set argct=0
set i=0
echo "########## foreach ###########"

# exit 1

foreach name ( $argv )
   @ argct += 1
   if ($debug == 1) then 
      echo "args argct = $argct $name "
      echo "args  #  $argv[$argct]"
   endif
   # look for a word that contains an =. split it to 2 words
   if ($name =~ *=*) then
     if ($debug == 1) then 
      echo "############### match in $name"
      set PARAM=`echo $name | awk -F= '{print $1}'`
      set VALUE=`echo $name | awk -F= '{print $2}'`
      echo "PARAM = $PARAM"
      echo "VALUE = $VALUE"
      echo "###################"
     endif
     switch ($PARAM)
      case "V2JBIN":
        # echo "case $name   i=$i"
        set V2JBINarg=$VALUE
        breaksw
      case "PNG":
        # echo "case $name   i=$i"
        set PNG=$VALUE
        breaksw  
      case "V2TEMPLATES":
        # echo "case $name   i=$i"
        set V2TEMPLATESarg=$VALUE
        breaksw
        
      case "V2VEL_REGTEST_INPUT":
        # echo "case $name   i=$i"
        set V2VEL_REGTEST_INPUTarg=$VALUE
        breaksw
        
      case "V2VEL_REGTEST_OUTPUT":
        # echo "case $name   i=$i"
        set V2VEL_REGTEST_OUTPUTarg=$VALUE
        breaksw
        
      case "MISSION":
        # echo "case $name   i=$i"
        set MISSION=$VALUE
        breaksw  
      default:
        echo "default = $name"
        breaksw
      endsw
   else
    # echo "switch(${name}) "
    switch ($name)
      # add help ??
      case "-HELP":
      case "--HELP":
      case "--help":
      case "-help":
      case "HELP":
      case "help":
      case "-H":
      case "-h":
        set help = 1
        echo "run_reg_test.csh V2JBIN V2TEMPLATES V2VEL_REGTEST_INPUT V2VEL_REGTEST_OUTPUT HELP"
        echo "default CLASSPATH environment variable is the vicar select CLASSPATH. "
        echo "User must set the CLASSPATH environment varible to override the default CLASSPATH"
        echo "These values are also environment variables: V2JBIN V2TEMPLATES V2VEL_REGTEST_INPUT V2VEL_REGTEST_OUTPUT"
        echo "If any of these values are on the command line they will override and update the environment variables"
        echo "V2VEL_REGTEST_INPUT points to the top directory of input test data"
        echo "V2VEL_REGTEST_OUTPUT points to the top directory of output files"
        echo "V2JBIN points to the scripts directory"
        echo "V2TEMPLATES points to the velocity templates directory"
        echo "MISSION argument to seed some of the templates and scripts"
        echo " possible options: [M2020, NSYT, INSIGHT, MER, MSAM, MSL]"
        echo "PNG - create a PNG from an edr/rdr or mosaic. No value just a flag, default is false if PNG arg isn't used"
        echo " for some unkown reason -PNG breaks the argument parser. PNG, --PNG and PNG=true all work "
        echo "arguments can be any of these 3 formats: "
        echo "  --PARAM the_value "
        echo "  -PARAM the_value "
        echo "  PARAM=the_value "
        breaksw
      
      case "-V":
      case "-v":
      case "VERBOSE":  
      case "-VERBOSE":
      case "--VERBOSE":
        # echo "case $name   i=$i"
        set debug=1
        breaksw
      
      
      case "PNG":  
      case "-PNG":
      case "--PNG":
        echo "case $name   i=$i"
        set PNG="true"
        breaksw
        
      case "-V2JBIN":
      case "--V2JBIN":
        @ i = $argct + 1
        # echo "case a $name   i=$i"
        set V2JBINarg=$argv[$i]
        breaksw
        
      case "-V2TEMPLATES":
      case "--V2TEMPLATES":
        @ i = $argct + 1
        # echo "case $name   i=$i"
        set V2TEMPLATESarg=$argv[$i]
        breaksw
        
      case "-CLASSPATH":
      case "--CLASSPATH":
        @ i = $argct + 1
        # echo "case $name   i=$i"
        set CLASSPATH=$argv[$i]
        breaksw
        
      case "-V2VEL_REGTEST_INPUT":
      case "--V2VEL_REGTEST_INPUT":
        @ i = $argct + 1
        # echo "case $name   i=$i"
        set V2VEL_REGTEST_INPUTarg=$argv[$i]
        breaksw
    
      case "-V2VEL_REGTEST_OUTPUT":
      case "--V2VEL_REGTEST_OUTPUT":
        @ i = $argct + 1
        # echo "case $name   i=$i"
        set V2VEL_REGTEST_OUTPUTarg=$argv[$i]
        breaksw       
      
      case "-MISSION":
      case "--MISSION":
        @ i = $argct + 1
        # echo "case $name   i=$i"
        set MISSION=$argv[$i]
        breaksw
        
      default:
        echo "default $name"
        breaksw
      endsw
   endif
end

echo "######## end foreach #########"

if ($help == 1) exit 1

if ($debug == 1) then
   echo "environment variables:"
   env | grep "V2"
   env | grep CLASSPATH
   env | grep MISSION
   
   # echo "V2JBIN = $V2JBIN"
   # echo "V2TEMPLATES = $V2TEMPLATES"
   # echo "CLASSPATH = $CLASSPATH"
   # echo "V2VEL_REGTEST_INPUT = $V2VEL_REGTEST_INPUT"
   # echo "V2VEL_REGTEST_OUTPUT = $V2VEL_REGTEST_OUTPUT"
   
   echo "help = $help"
   
   # check if there are arguments which should be used to overide the environment variables
   echo "arguments: "
   echo "V2JBIN = $V2JBINarg"
   echo "V2TEMPLATES = $V2TEMPLATESarg"
   echo "V2VEL_REGTEST_INPUT = $V2VEL_REGTEST_INPUTarg"
   echo "V2VEL_REGTEST_OUTPUT = $V2VEL_REGTEST_OUTPUTarg"
   echo "MISSION = $MISSION"
   echo "PNG = $PNG"
endif

# set the env variables or keep them as shell
if ("$V2JBINarg" != "") then
  setenv V2JBIN $V2JBINarg
endif

if ("$V2TEMPLATESarg" != "") then
  setenv V2TEMPLATES $V2TEMPLATESarg
endif

if ("$V2VEL_REGTEST_INPUTarg" != "") then
  setenv V2VEL_REGTEST_INPUT $V2VEL_REGTEST_INPUTarg
endif

if ("$V2VEL_REGTEST_OUTPUTarg" != "") then
  setenv V2VEL_REGTEST_OUTPUT $V2VEL_REGTEST_OUTPUTarg
endif

# ??? MISSION environment variable or V2MISSION

if ($debug == 1) then
   echo "environment variables after they have been updated from the arguments"
   env | grep "V2"
   env | grep CLASSPATH
   env | grep MISSION
endif


echo "Begin the test ##########################################################"


mkdir -p ${V2VEL_REGTEST_OUTPUT}

if (-d ${V2VEL_REGTEST_INPUT}/edr_rdr ) then
echo '*************************************************************************'
echo ' EDR/RDR'
echo '*************************************************************************'

mkdir -p ${V2VEL_REGTEST_OUTPUT}/edr_rdr
pushd ${V2VEL_REGTEST_OUTPUT}/edr_rdr

echo "${V2VEL_REGTEST_INPUT}/edr_rdr"
pwd

#### check for .VIC or .IMG
set img_ct = `ls -1 ${V2VEL_REGTEST_INPUT}/edr_rdr/*.IMG | wc -l `
echo "img_ct = $img_ct"

set vic_ct = `ls -1 ${V2VEL_REGTEST_INPUT}/edr_rdr/*.VIC | wc -l `
echo "vic_ct = $vic_ct"

echo  "CLASSPATH = $CLASSPATH"
echo  "V2JBIN = $V2JBIN"
echo "${V2JBIN}/LabelImage"

if ($img_ct > 0) then
   echo ' EDR/RDR *.IMG '
   foreach i (${V2VEL_REGTEST_INPUT}/edr_rdr/*.IMG)
       ${V2JBIN}/LabelImage $i > ${i:t}.log
   end
   mv ${V2VEL_REGTEST_INPUT}/edr_rdr/*.xml .
   cp ${V2VEL_REGTEST_INPUT}/edr_rdr/*.IMG .
   
   if ($PNG == "true") then
      foreach i (*.xml)
          echo "CreatePNG $i "
          ${V2JBIN}/CreatePNG $i > ${i:t}.png.log
      end
   endif
endif

if ($vic_ct > 0) then
   echo ' EDR/RDR *.VIC '
   foreach i (${V2VEL_REGTEST_INPUT}/edr_rdr/*.VIC)
       ${V2JBIN}/LabelImage $i > ${i:t}.log
   end
   mv ${V2VEL_REGTEST_INPUT}/edr_rdr/*.xml .
   cp ${V2VEL_REGTEST_INPUT}/edr_rdr/*.VIC .
   # rm "output.xml"
   # rm "velocity.log"
   
   if ($PNG == "true") then
      foreach i (*.xml)
          echo "CreatePNG $i "
          ${V2JBIN}/CreatePNG $i > ${i:t}.png.log
      end
   endif
   
endif



popd
endif

if (-d ${V2VEL_REGTEST_INPUT}/anc ) then
#echo '*************************************************************************'
#echo ' Ancillary files'
#echo '*************************************************************************'
#
#mkdir -p ${V2VEL_REGTEST_OUTPUT}/anc
#pushd ${V2VEL_REGTEST_OUTPUT}/anc

#foreach i (${V2VEL_REGTEST_INPUT}/anc/*)
#   ${V2JBIN}/label_ancillary_file.csh NSYT $i > ${i:t}.log
#end
#
#popd
endif

if (-d ${V2VEL_REGTEST_INPUT}/browse) then
#echo '*************************************************************************'
#echo ' Browse images'
#echo '*************************************************************************'

#mkdir -p ${V2VEL_REGTEST_OUTPUT}/browse
#pushd ${V2VEL_REGTEST_OUTPUT}/browse

#foreach i (${V2VEL_REGTEST_INPUT}/browse/*.PNG)
#   ${V2JBIN}/LabelBrowse $i > ${i:t}.log
#end
#
#popd
endif

if (-d ${V2VEL_REGTEST_INPUT}/doc) then
#echo '*************************************************************************'
#echo ' Documentation files - note, we don't actually need the doc file'
#echo '*************************************************************************'

#mkdir -p ${V2VEL_REGTEST_OUTPUT}/doc
#pushd ${V2VEL_REGTEST_OUTPUT}/doc
#
# ${V2JBIN}/run_doc.csh > run_doc.log
#
#popd
endif

if (-d ${V2VEL_REGTEST_INPUT}/mosaic ) then
echo '*************************************************************************'
echo ' Mosaics'
echo '*************************************************************************'

mkdir -p ${V2VEL_REGTEST_OUTPUT}/mosaic
pushd ${V2VEL_REGTEST_OUTPUT}/mosaic

#### check for .VIC or .IMG
set img_ct = `ls -1 ${V2VEL_REGTEST_INPUT}/mosaic/*.IMG | wc -l `
echo "img_ct = $img_ct"

set vic_ct = `ls -1 ${V2VEL_REGTEST_INPUT}/mosaic/*.VIC | wc -l `
echo "vic_ct = $vic_ct"


if ($img_ct > 0) then
   echo ' mosaic *.IMG '
   foreach i (${V2VEL_REGTEST_INPUT}/mosaic/*.IMG)
       ${V2JBIN}/LabelImage $i > ${i:t}.log
       cp ${i} .
   end
   
   mv ${V2VEL_REGTEST_INPUT}/mosaic/*.xml .
   cp ${V2VEL_REGTEST_INPUT}/mosaic/*.IMG .
   
   if ($PNG == "true") then
      foreach i (*.xml)
          echo "CreatePNG $i "
          ${V2JBIN}/CreatePNG $i > ${i:t}.png.log
      end
   endif
endif

if ($vic_ct > 0) then
   echo ' mosaic *.VIC '
   foreach i (${V2VEL_REGTEST_INPUT}/mosaic/*.VIC)
       ${V2JBIN}/LabelImage $i > ${i:t}.log
       cp ${i} .
   end
   mv ${V2VEL_REGTEST_INPUT}/mosaic/*.xml .
   cp ${V2VEL_REGTEST_INPUT}/mosaic/*.VIC .
   
   if ($PNG == "true") then
      foreach i (*.xml)
          echo "CreatePNG $i "
          ${V2JBIN}/CreatePNG $i > ${i:t}.png.log
      end
   endif
endif



popd
endif

if (-d ${V2VEL_REGTEST_INPUT}/obj ) then
echo '*************************************************************************'
echo ' OBJ and MLP'
echo '*************************************************************************'

mkdir -p ${V2VEL_REGTEST_OUTPUT}/obj
pushd ${V2VEL_REGTEST_OUTPUT}/obj

#foreach i (${V2VEL_REGTEST_INPUT}/obj/*.obj)
#   ${V2JBIN}/LabelObj $i > ${i:t}.log
#end

# --MISSION [M2020, NSYT, MER, MSAM, MSL]
# make_meshlab.csh assumes this is a vicar environment so it can gen a dummy image file
foreach i (${V2VEL_REGTEST_INPUT}/obj/*.mlp)
  ${V2JBIN}/make_meshlab.csh ${i:r}.lis ${i:t} ${MISSION} >meshlab.log
  # dummy_image.vic is already there allows use on a mac without $R2LIB/gen
  # ${V2JBIN}/make_meshlab.csh ${i:r}.lis ${i:t} ${MISSION} ${V2VEL_REGTEST_INPUT}/obj/dummy_image.vic > meshlab.log
end
#
popd
endif

if (-d ${V2VEL_REGTEST_INPUT}/templ ) then
echo '*************************************************************************'
echo ' Velocity templates'
echo '*************************************************************************'

mkdir -p ${V2VEL_REGTEST_OUTPUT}/templ
pushd ${V2VEL_REGTEST_OUTPUT}/templ

# ${V2JBIN}/run_templ_doc.csh ${V2VEL_REGTEST_INPUT}/templ/ > run_templ_doc.log

popd
endif
#
echo "DONE"
exit 1