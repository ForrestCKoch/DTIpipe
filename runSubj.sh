#!/bin/sh

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

SUBJ="$1"
STARTDIR="$(pwd)"

cd "$SUBJ"
#$DIR/scripts/processing/parcellate.sh > parcellate.log 2>&1 & 
$DIR/scripts/processing/distortion_correction.sh>distortion_correction.log 2>&1 
$DIR/scripts/processing/coregister.sh > coregister.log 2>&1 
$DIR/scripts/processing/calculate_noddi.sh > calculate_noddi.log 2>&1
$DIR/scripts/processing/tractography.sh > tractography.log 2>&1
#$DIR/scripts/processing/get_connectome.sh > getConnectome.log 2>&1
cd $STARTDIR
