#!/bin/csh -f
#
# Run all cal labels for a mission
#
# Usage:
#   create_cal_labels.csh mission bundle indir outdir
#
# where mission is "NSYT" or "MSAM" or "M2020" (currently, others possible),
# bundle is the PDS LIB bundle string,
# indir is the location of the cal files, and outdir is where the output files
# and label will be put.  Both indir and outdir should be full (non-relative)
# pathnames.
#
# Note: the directory containing the script file must be in $path, as it
# needs to call several other subordinate scripts.
#
#
if ($# != 4) then
   head -16 $0
   exit
endif


set msn = $1
if ("$msn" == "NSYT") then
   set mission = "InSight"
   set venues = "NSYT NSYTTBC"
else if ("$msn" == "MSAM") then
   set mission = "MSAM"
   set venues = "MSL"
else if ("$msn" == "M2020") then
   set mission = "Mars2020"
   set venues = "M20"
else
   echo "Unrecognzed mission, aborting"
   exit
endif

set bundle = $2

set src = $3
set out = $4

set nonomatch

cd $src

$V2JBIN/label_cal_file.csh $src $out $msn $bundle ./README.TXT "$mission calibration README file" txt 

rm output.xml velocity.log

##### CAMERA MODELS

cd camera_models
foreach i (*.cahv*)
  if ("`echo $i | sed -e 's/\*//'`" != "$i") continue
  $V2JBIN/label_cal_file.csh $src $out $msn $bundle camera_models/$i "$mission camera model file" txt
end
foreach i (*.interp*)
  if ("`echo $i | sed -e 's/\*//'`" != "$i") continue
  $V2JBIN/label_cal_file.csh $src $out $msn $bundle camera_models/$i "$mission camera model interpolation file" txt
end

rm output.xml velocity.log

##### FLAT FIELDS

cd ../flat_fields
foreach i (*.IMG)
  if ("`echo $i | sed -e 's/\*//'`" != "$i") continue
  $V2JBIN/label_cal_file.csh $src $out $msn $bundle flat_fields/$i "$mission flat field file" img
end
foreach i (*.varflat)
  if ("`echo $i | sed -e 's/\*//'`" != "$i") continue
  $V2JBIN/label_cal_file.csh $src $out $msn $bundle flat_fields/$i "$mission flat field interpolation file" txt
end


rm output.xml velocity.log

##### ILUT

cd ../ilut
foreach i (*.txt)
  if ("`echo $i | sed -e 's/\*//'`" != "$i") continue
  $V2JBIN/label_cal_file.csh $src $out $msn $bundle ilut/$i "$mission inverse lookup table (decompanding) file" txt
end

rm output.xml velocity.log

##### PARAM FILES

cd ../param_files

foreach venue ($venues)

  set i = "${venue}_camera_mapping.xml"
  if (-e $i) then
    $V2JBIN/label_cal_file.csh $src $out $msn $bundle param_files/$i "$mission venue $venue camera mapping file" txt
  endif

  set i = "${venue}_arm_mask.VIC"
  if (-e $i) then
    $V2JBIN/label_cal_file.csh $src $out $msn $bundle param_files/$i "$mission venue $venue arm mask image" img
  endif

  set i = "${venue}_color.parms"
  if (-e $i) then
    $V2JBIN/label_cal_file.csh $src $out $msn $bundle param_files/$i "$mission venue $venue color parameters file" txt
  endif

  set i = "${venue}_filter_exclude.txt"
  if (-e $i) then
    $V2JBIN/label_cal_file.csh $src $out $msn $bundle param_files/$i "$mission venue $venue rover filter exclude list" txt
  endif

  set i = "${venue}_rover_filter.xml"
  if (-e $i) then
    $V2JBIN/label_cal_file.csh $src $out $msn $bundle param_files/$i "$mission venue $venue rover filter extras definition" txt
  endif

  set i = "${venue}_rover_filter.xmlf"
  if (-e $i) then
    $V2JBIN/label_cal_file.csh $src $out $msn $bundle param_files/$i "$mission venue $venue rover filter extras definition" txt
  endif

  set i = "${venue}_RMI_filter.xmlf"
  if (-e $i) then
    $V2JBIN/label_cal_file.csh $src $out $msn $bundle param_files/$i "$mission venue $venue RMI filter definition, removes area outside RMI FOV circle" txt
  endif

  foreach i (${venue}_*.point)
    if ("`echo $i | sed -e 's/\*//'`" != "$i") continue
    $V2JBIN/label_cal_file.csh $src $out $msn $bundle param_files/$i "$mission venue $venue pointing parameters file" txt
  end

# InSight specific
  foreach i (${venue}_wksp*.txt)
    if ("`echo $i | sed -e 's/\*//'`" != "$i") continue
    $V2JBIN/label_cal_file.csh $src $out $msn $bundle param_files/$i "$mission workspace polygon definition file" txt
  end

end

# Non per-venue files

# There's really only one but the foreach means we don't have to specify
# the mission name
foreach i (*_flat_fields.parms)
  if ("`echo $i | sed -e 's/\*//'`" != "$i") continue
  $V2JBIN/label_cal_file.csh $src $out $msn $bundle param_files/$i "$mission radiometry and color correction parameters file" txt
end
foreach i (*_rad_cal.parms)
  if ("`echo $i | sed -e 's/\*//'`" != "$i") continue
  $V2JBIN/label_cal_file.csh $src $out $msn $bundle param_files/$i "$mission radiometry correction parameters file" txt
end
foreach i (*_color_cal.parms)
  if ("`echo $i | sed -e 's/\*//'`" != "$i") continue
  $V2JBIN/label_cal_file.csh $src $out $msn $bundle param_files/$i "$mission color correction parameters file" txt
end

# InSight specific

# Raw workspace polygons
foreach i (hp3_*.txt seis_*.txt seis-wts_*.txt wts_*.txt)
  if ("`echo $i | sed -e 's/\*//'`" != "$i") continue
  $V2JBIN/label_cal_file.csh $src $out $msn $bundle param_files/$i "$mission raw workspace polygon definition file" txt
end

set i = "make_poly_links.csh"
if (-e "$i") then
  $V2JBIN/label_cal_file.csh $src $out $msn $bundle param_files/$i "$mission script to make softlinks" txt
endif

# MSAM specific

foreach i (tau_interp_*.txt)
  if ("`echo $i | sed -e 's/\*//'`" != "$i") continue
  $V2JBIN/label_cal_file.csh $src $out $msn $bundle param_files/$i "$mission TAU measurement per sol" txt
end

# M2020 specific

foreach i (M20_rad_cal_rte_whitebal.parms*)
  if ("`echo $i | sed -e 's/\*//'`" != "$i") continue
  $V2JBIN/label_cal_file.csh $src $out $msn $bundle param_files/$i "$mission radiometric calibration parameters for helicopter RTE images that were NOT white balanced onboard" txt
end

foreach i (M20_*_zoom_fnum.csv)
  if ("`echo $i | sed -e 's/\*//'`" != "$i") continue
  $V2JBIN/label_cal_file.csh $src $out $msn $bundle param_files/$i "$mission table converting zoom motor count to f/number for ZCAM" txt
end


rm output.xml velocity.log

##### RMC FILES

cd ../rmc

foreach venue ($venues)

  set i = "${venue}_rmc_file.xml"
  if (-e $i) then
    $V2JBIN/label_cal_file.csh $src $out $msn $bundle rmc/$i "$mission venue $venue RMC file" txt
  endif

end

rm output.xml velocity.log


