#!/bin/csh -f
#
# Copy a calibration text file for archive and create a label.
#
# Usage:
#  % label_cal_file.csh sourcedir outdir mission bundle dir/calfile "descr" imgtxt
#
# mission is NSYT, MSAM, etc.  bundle is the LID bundle string.
# sourcedir is the top-level cal dir (where
# MARS_CONFIG_PATH points).  outdir is the output counterpart.  dir/calfile
# is relative to those. It MUST have a directory; use "./" if going after the
# readme file.  imgtxt is "img" or "txt".  
#
#
if ($# != 7) then
   head -12 $0
   exit
endif

## setenv CLASSPATH /home/nsytmipl/magic_jars/a_dev_srl_generate-0.14.0.jar:/home/nsytmipl/magic_jars/a_vicario_msl.jar:"$CLASSPATH"

set sourcedir = $1
set outdir = $2
set mission = $3
set bundle = $4
set calfile = $5
set descr = "$6"
set imgtxt = $7


set code = $V2TEMPLATES/

# Get the SIS from the mission

set sis = ""
if ("$mission" == "NSYT") then
   set sis = "urn:nasa:pds:insight_cameras:documentation:insight_cameras_sis.pdf"
else if ("$mission" == "MSAM") then
   set sis = "urn:nasa:pds:deen_pdart16_msl_msam:document:msam_sis.pdf"
else if ("$mission" == "M2020") then
   set sis = "urn:nasa:pds:mars2020_mission:document:Mars2020_Camera_SIS.pdf"
endif

# Extract stuff from input name

set dir = ${calfile:h}
set name = ${calfile:r:t}
set ext = ${calfile:e}

# Preserve xml files
if ("$ext" == "xml") set ext = "xmlx"

# Temp files
set json = ${outdir}/${dir}/${name}.${ext}.json
if ("$imgtxt" == "img") then
   set imgtmp = ${sourcedir}/${calfile}
else
   set imgtmp = ${outdir}/${dir}/${name}.${ext}.tmpvic
endif

# Output files
set outfile = ${outdir}/${dir}/${name}.${ext}
set outlbl =  ${outdir}/${dir}/${name}.${ext}_lbl.xml

# Copy over file
mkdir ${outdir}
mkdir ${outdir}/${dir}
cp $sourcedir/$calfile $outfile

# Create json label for transcoder.  Ironically, we don't need to see the
# actual text file itself.  But we do need to see the image.

echo '{' >$json
echo '  "INSTRUMENT_HOST_ID": "'$mission'",' >>$json
echo '  "BUNDLE": "'$bundle'",' >>$json
echo '  "FILENAME": "'${name}.${ext}'",' >>$json
echo '  "TITLE": "'"$descr"'",' >>$json
echo '  "SIS_LID": "'$sis'"' >>$json
echo '}' >>$json

# If text, create dummy (placeholder) vicar file

if ("$imgtxt" != "img") then
   ### $R2LIB/gen $imgtmp
   cp $V2JBIN/LabelocityDummyImage.VIC $imgtmp
endif

# Now call the transcoder to do the work...

if ("$imgtxt" == "img") then
   set templ = $code/cal_file_image.vm
else
   set templ = $code/cal_file_text.vm
endif

java -Xmx256M jpl.mipl.io.jConvertIIO PDS_DETACHED_ONLY=true PDS_LABEL_TYPE=PDS4 ri-true format=pds4 inp=$imgtmp out=$outlbl velo_template=$templ extra_file_name=$json extra_file_type=json

# remove temp files

rm $json
if ("$imgtxt" != "img") then
   rm $imgtmp
endif

