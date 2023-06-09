#!/usr/bin/env tcsh
#
# Copyright (c) 2019-2023, California Institute of Technology ("Caltech").
# U.S. Government sponsorship acknowledged.
# All rights reserved.
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:
# - Redistributions of source code must retain the above copyright notice,
#   this list of conditions and the following disclaimer.
# - Redistributions must reproduce the above copyright notice, this list of
#   conditions and the following disclaimer in the documentation and/or other
#   materials provided with the distribution.
# - Neither the name of Caltech nor its operating division, the Jet Propulsion
#   Laboratory, nor the names of its contributors may be used to endorse or
#   promote products derived from this software without specific prior written
#   permission.
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
# AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
# ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE
# LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
# CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
# SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
# INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
# CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
# ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
# POSSIBILITY OF SUCH DAMAGE.

################################################################################
#                                                                              #
#                       LABELOCITY INITIALIZATION SCRIPT                       #
#                                   NASA JPL                                   #
#                                                                              #
################################################################################

# note this script is scoped minimally to promote reuse in many environments
# its purpose is to move users into the correct shell (tcsh) and set vars

set cwdl=($_)
if ("$cwdl" != "") then  # sourced
    set cwdl=$cwdl[2]
else  # executed 
   set cwdl=${0}
endif
set cwdl=`dirname "${cwdl}"`
set cwdl_full=`cd "${cwdl}" && pwd`

# source required environment vars
if (! $?LABELOCITY_ROOT) then  # unset, assume inside labelocity dir
    echo "INFO: Exec startup at '${cwdl_full}'..."
    source "${cwdl_full}"/initenv
else
    if ("${LABELOCITY_ROOT}" == "") then  # empty, set this script's dir as root
        echo "INFO: Setting LABELOCITY_ROOT at '${cwdl_full}'..."
        setenv LABELOCITY_ROOT "${cwdl_full}"
    else
        echo "INFO: Using LABELOCITY_ROOT at '${LABELOCITY_ROOT}'..."
    endif
    source "${LABELOCITY_ROOT}"/initenv
endif

# launch tcsh -- yields control to the tcsh terminal until exit
echo "INFO: Launching Labelocity subshell. ..."
/usr/bin/env tcsh

exit
