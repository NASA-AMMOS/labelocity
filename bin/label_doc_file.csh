#!/bin/csh -f
#
# Create a label for a documentation file.
#
# Usage:
#  % label_doc_file.csh mission file bundle collection "descr" "author" "docstd" "edition" version [ title ]
#
# mission: NSYT, MSAM, etc.
# file: docfile to label.
# bundle: the bundle, used in PDS LID 
# collection: the collection, e.g. miscellaneous or document
# descr: description of the file.
# author: author list (F. Last, S. Other)
# docstd: document standard id, e.g. "Rich Text", "PDF/A", "7-Bit ASCII Text",
#     "GIF", "HTML", JPEG", "PNG", "TIFF", "UTF-8 Text"
# edition: text for <edition_name>, e.g. "PDF version"
# version: version number, e.g. 1.0
# title: optional title, use desc if not avail
#
if ($# != 9 && $# != 10) then
   head -19 $0
   exit
endif

# setenv CLASSPATH /home/nsytmipl/magic_jars/a_dev_srl_generate-0.14.0.jar:/home/nsytmipl/magic_jars/a_vicario_msl.jar:"$CLASSPATH"

set mission = $1
set docfile = $2
set bundle = "$3"
set collection = "$4"
set descr = "$5"
set author = "$6"
set docstd = "$7"
set edition = "$8"
set version = "$9"
if ($# == 10) then
  set title = "$10"
else
  set title = "$descr"
endif

set code = $V2TEMPLATES

# Get the SIS from the mission

set name = ${docfile:r}
set ext = ${docfile:e}

# Preserve xml files
if ("$ext" == "xml") set ext = "xmlx"

# Temp files
set json = ${name}.${ext}.json
set imgtmp = ${name}.${ext}.tmpvic

# Output files
set outlbl =  ${name}.${ext}.xml

# Create json label for transcoder.  Ironically, we don't need to see the
# actual text file itself.  But we do need to see the image.

echo '{' >$json
echo '  "INSTRUMENT_HOST_ID": "'$mission'",' >>$json
echo '  "FILENAME": "'${name}.${ext}'",' >>$json
echo '  "BUNDLE": "'"$bundle"'",' >>$json
echo '  "COLLECTION": "'"$collection"'",' >>$json
echo '  "DESCRIPTION": "'"$descr"'",' >>$json
echo '  "TITLE": "'"$title"'",' >>$json
echo '  "AUTHOR": "'"$author"'",' >>$json
echo '  "DOCSTD": "'"$docstd"'",' >>$json
echo '  "EDITION": "'"$edition"'",' >>$json
echo '  "VERSION": "'"$version"'"' >>$json
echo '}' >>$json

# Create dummy (placeholder) vicar file

### $R2LIB/gen $imgtmp
cp $V2JBIN/LabelocityDummyImage.VIC $imgtmp

# Now call the transcoder to do the work...

set templ = $code/doc_file.vm

java -Xmx256M jpl.mipl.io.jConvertIIO PDS_DETACHED_ONLY=true PDS_LABEL_TYPE=PDS4 ri-true format=pds4 inp=$imgtmp out=$outlbl velo_template=$templ extra_file_name=$json extra_file_type=json

# remove temp files

rm $json
rm $imgtmp
rm output.xml
rm velocity.log

