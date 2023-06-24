#!/bin/csh -f
#
# Create a label for an ancillary file (LIS, NAV, TIE, BRT, OVR, TXT, EXT, FILT, XMLF)
# or OTHER, in which case you can provide the title.
#
# Usage:
#  % label_ancillary_file.csh mission file [type/title [version [-prop label value]* ] ] 
#
# "mission" is NSYT, MSAM, M2020, etc.  "file" is the input file; the output
# file will be the same (and in the same dir) with .xml appended.  "type" is
# the file type (lis, nav, etc) and is derived from the filename extension
# if not given.  If type is not one of the known types, it is used verbatim
# in the title.  Version is an override in case it's not in the filename.
# One or more property pairs can be included via:  -prop label value
#

set DOC_LEN = 15

set prop_list = ()
set version = ""
if ($# == 2) then
   set mission = $1
   set infile = $2
   set type = ${infile:e}
else if ($# == 3) then
   set mission = $1
   set infile = $2
   set type = "$3"
else if ($# == 4) then
   set mission = $1
   set infile = $2
   set type = "$3"
   set version = $4
else if ($# > 4) then
   set mission = $1
   set infile = $2
   set type = "$3"
   set version = $4

   set startp = 5
 
   while ($startp <= $#)
      if ("$argv[$startp]" == "-prop") then
         @ startp = $startp + 1
         if ($startp <= $#) then
           set prop_key = $argv[$startp]
           @ startp = $startp + 1
           if ($startp <= $#) then
             set prop_val = $argv[$startp]
             set prop_line = \""${prop_key}"\"": "\""${prop_val}"\"
             set prop_list = ( $prop_list:q $prop_line:q )
           else
              head -${DOC_LEN} $0; echo "Error: Missing value for property '${prop_key}'"; exit 
           endif
         else
            head -${DOC_LEN} $0; echo "Error: Missing property name"; exit
         endif
      else
        head -${DOC_LEN} $0; echo "Error: Unrecognized option: '$argv[$startp]'"; exit
      endif
      @ startp = $startp + 1
   end
else
   head -${DOC_LEN} $0
   exit
endif


set uctype = `echo $type | tr '[a-z]' '[A-Z]'`

# setenv CLASSPATH /path/to/overriding.jar:"$CLASSPATH"

set code = $V2TEMPLATES

# Set the comment given the type

if ("$uctype" == "LIS") then
   set title = "List file, containing input filenames"
else if ("$uctype" == "NAV") then
   set title = "Pointing correction (nav) file, containing bundle adjustment results"
else if ("$uctype" == "TIE" || "$uctype" == "TPT") then
   set title = "Tiepoint file, containing tiepoints between images"
else if ("$uctype" == "BRT") then
   set title = "Brightness correction file, containing correction factors for each image"
else if ("$uctype" == "OVR") then
   set title = "Overlap file, containing mean and stdev statistics for overlapping areas"
else if ("$uctype" == "TXT") then
   set title = "Text file, containing a description of the image"
else if ("$uctype" == "EXT") then
   set title = "Extent file, containing extra mosaic command line parameters"
else if ("$uctype" == "FILT") then
   set title = "Filter file, containing rover mask parameters"
else if ("$uctype" == "XMLF") then
   set title = "XML file containing rover mask parameters"
else
   echo "Unrecognized file type, using as title"
   set title = "$type"
endif


# Temp files
set json = /tmp/${infile:t}.json
set imgtmp = /tmp/${infile:t}.tmpvic

set outlbl =  ${infile}.xml

# Create json label for transcoder.  Ironically, we don't need to see the
# actual text file itself.  But we do need to see the image.

##Populate the JSON with non-generic properties 
set prop_line = '"INSTRUMENT_HOST_ID": "'${mission}'"'
set prop_list = ( $prop_list:q $prop_line:q )
set prop_line = '"FILENAME": "'${infile:t}'"'
set prop_list = ( $prop_list:q $prop_line:q )
set prop_line = '"TITLE": "'"${title}"'"'
set prop_list = ( $prop_list:q $prop_line:q )

if ("$version" != "") then
    set prop_line = '"VERSION_NUMBER": "'${version}'"'
    set prop_list = ( $prop_list:q $prop_line:q )
endif

set prop_list_size = ${#prop_list}
if ( $prop_list_size > 0) then ##Not needed but keep for consistency
    ##Populate JSON file with properties
    echo '{' >$json
    foreach prop_idx (`seq $prop_list_size`)
        set cur_line = "   $prop_list[$prop_idx]"
        if ( $prop_idx < $prop_list_size ) then
           set cur_line = "${cur_line}," # no comma for last line
        endif
        echo $cur_line >>$json
    end
    echo '}' >>$json
endif


# Create dummy (placeholder) vicar file
### $R2LIB/gen $imgtmp
cp $V2JBIN/LabelocityDummyImage.VIC $imgtmp

# Now call the transcoder to do the work...

set templ = $code/ancillary_file_text.vm

java -Xmx256M jpl.mipl.io.jConvertIIO PDS_DETACHED_ONLY=true PDS_LABEL_TYPE=PDS4 ri-true format=pds4 inp=$imgtmp out=$outlbl velo_template=$templ extra_file_name=$json extra_file_type=json

# remove temp files

rm $json
rm $imgtmp

