#!/bin/sh

SUBJ="$1"
STARTDIR="$(pwd)"

cd "$SUBJ"
#../../DTIpipe/parcellate.sh > parcellate.log 2>&1 & 
../../DTIpipe/distortion_correction.sh > distortion_correction.log 2>&1 
../../DTIpipe/coregister.sh > coregister.log 2>&1 
../../DTIpipe/tractography.sh > tractography.log 2>&1
#../../DTIpipe/getConnectome.sh > getConnectome.log 2>&1
cd $STARTDIR
