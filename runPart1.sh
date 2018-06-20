#!/bin/sh

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

SUBJ="$1"
STARTDIR="$(pwd)"

cd "$SUBJ"
mkdir logs
echo "Distortion Correction"
$DIR/scripts/processing/distortion_correction.sh>logs/distortion_correction.log 2>&1 
echo "Coregistration"
$DIR/scripts/processing/coregister.sh > logs/coregister.log 2>&1 
echo "Fitting tensors"
$DIR/scripts/processing/fit_tensors.sh > logs/fit_tensors.log 2>&1 
cd $STARTDIR
