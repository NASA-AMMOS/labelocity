#!/bin/csh -f
#
# Make a meshlab project file given a list of OBJ files.
#
# Usage:
#   make_meshlab.csh obj.lis out.mlp mission
#
# where mission is NSYT, MSAM, etc.
#

if ($# != 3) then
  head -9 $0
  exit
endif

# setenv CLASSPATH /home/nsytmipl/magic_jars/a_dev_srl_generate-0.14.0.jar:/home/nsytmipl/magic_jars/a_vicario_msl.jar:"$CLASSPATH"

set orig_obj = $1
set out = $2
set mission = $3

# CONSTANTS THAT MAY NEED TO CHANGE

set code = $V2TEMPLATES

# Look for any empty obj's and put them at the end of the list
# Empty ones are 2 lines long but we check for 5... just because.

set obj = ${orig_obj}.sort
rm -f ${obj}.data
rm -f ${obj}.nodata
touch ${obj}.data
touch ${obj}.nodata
foreach o ("`cat $orig_obj`")
  if (`wc -l $o | cut -d ' ' -f 1` < 5) then
    echo $o >>${obj}.nodata
  else
    echo $o >>${obj}.data
  endif
end

cat ${obj}.data ${obj}.nodata >$obj
rm ${obj}.data ${obj}.nodata

# Write preamble

echo "<!DOCTYPE MeshLabDocument>" >$out
echo "<MeshLabProject>" >>$out
echo " <MeshGroup>" >>$out

# Loop for each wedge

foreach o ("`cat $obj`")

  echo '  <MLMesh filename="'${o:t}'" label="'${o:t}'">' >>$out
  echo "   <MLMatrix44>" >>$out
  echo "1 0 0 0 " >>$out
  echo "0 1 0 0 " >>$out
  echo "0 0 1 0 " >>$out
  echo "0 0 0 1 " >>$out
  echo "</MLMatrix44>" >>$out
  echo "  </MLMesh>" >>$out

end

# Write postamble

echo " </MeshGroup>" >>$out
echo " <RasterGroup/>" >>$out
echo "</MeshLabProject>" >>$out


# Create label

# Create the JSON for the label

set json = ${out}.json
echo '{' >$json
echo '   "INSTRUMENT_HOST_ID": "'$mission'",' >>$json
echo '  "FILENAME": "'${out:t}'",' >>$json
echo '   "OBJS": [' >>$json

set comma = 0
foreach o ("`cat $obj`")
  if ($comma == 0) then
    echo '"'${o:t}'" ' >>$json
  else
    echo ',"'${o:t}'" ' >>$json
  endif
  set comma = 1
end
echo '    ]' >>$json
echo '}' >>$json

# Create dummy image for transcoder

set imgtmp = ${out}.victmp
### $R2LIB/gen $imgtmp
cp $V2JBIN/LabelocityDummyImage.VIC $imgtmp

# Call the transcoder to do the work

java -Xmx256M jpl.mipl.io.jConvertIIO PDS_DETACHED_ONLY=true PDS_LABEL_TYPE=PDS4 ri-true format=pds4 inp=$imgtmp out=$out.xml velo_template=$code/meshlab_label.vm extra_file_name=$json extra_file_type=json

rm $json
rm $imgtmp
rm output.xml velocity.log
rm $obj



