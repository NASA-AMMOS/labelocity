# README  for run_reg_test.csh
run_reg_test.csh provides a regression test for PDS4 velocity template conversions.
This file will be found in a vicar select at $V2JBIN/reg_test/run_reg_test.csh
This is a driver script which walks through the sub directories of an input directory. The script looks
for files in the following subdirectories: edr_rdr, mosaics and obj.
The script is currently disabled for subdirectories: anc, browse, doc and templ.
If the edr_rdr and/or mosaic subdirectories are found it will loop through the .VIC or .IMG files found there
and create PDS4 labels.
The obj subdirectory tests the label creation for a mesh obj file.
The script calls other scripts found in the $V2JBIN directory.
Velocity templates are found in the directry pointed to by V2TEMPLATES.
Vicar select sets the $CLASSPATH used to find the java jars. If a user of this script wants to do testing with
a different CLASSPATH the environment variable must be set before the script is executed. If no value has been
set for CLASSPATH the script will abort and remind the user to set the environent variable. Doing a vicar select
will set the CLASSPATH.
V2TEMPLATES points to the directory which contains all of velocity template and macro files.
V2JBIN points to the scripts directory. It is set by a vicar select.

run_reg_test.csh V2JBIN V2TEMPLATES V2VEL_REGTEST_INPUT V2VEL_REGTEST_OUTPUT HELP MISSION VERBOSE PNG

These values are also environment variables: V2JBIN V2TEMPLATES V2VEL_REGTEST_INPUT V2VEL_REGTEST_OUTPUT
If any of these values are on the command line they will override and update the environment variables

V2JBIN points to the scripts directory. This argument overrides the value of this environment variable.
V2TEMPLATES points to the velocity templates directory. This argument overrides the value of this environment
variable.

V2VEL_REGTEST_INPUT points to the top directory of input test data.
V2VEL_REGTEST_OUTPUT points to the top directory of output files. All of the results and logs will be stored
in this directory. Subdirectories will be created based on the inputs. 
Currently these environment variables are not set. They may be in the future.
They must be supplied as arguments for any conversions to happen.

MISSION argument which could be used to seed some of the templates and scripts.
 possible options: [M2020, NSYT, INSIGHT, MER, MSAM, MSL]
VERBOSE turns on extra printing while the script is running. No value just a flag, default is off.
PNG - create a PNG from an edr/rdr or mosaic. No value just a flag, default is false if PNG arg isn't used
 for some unkown reason -PNG breaks the argument parser. PNG, --PNG and PNG=true all work 
arguments can be any of these 3 formats: 
  --PARAM the_value 
  -PARAM the_value 
  PARAM=the_value 