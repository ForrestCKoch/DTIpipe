#!/bin/sh

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

SUBJ="$1"
STARTDIR="$(pwd)"

cd "$SUBJ"
mkdir logs
#$DIR/scripts/processing/parcellate.sh > parcellate.log 2>&1 & 
echo "Distortion Correction"
$DIR/scripts/processing/distortion_correction.sh>logs/distortion_correction.log 2>&1 
echo "Coregistration"
$DIR/scripts/processing/coregister.sh > logs/coregister.log 2>&1 
echo "Fitting tensors"
$DIR/scripts/processing/fit_tensors.sh > logs/fit_tensors.log 2>&1 
echo "Calculating Noddi"
$DIR/scripts/processing/calculate_noddi.sh > logs/calculate_noddi.log 2>&1
echo "Calculating Kurtosis"
$DIR/scripts/processing/calculate_kurtosis.sh > logs/calculate_kurtosis.log 2>&1
echo "Preparing WMH vs NAWM"
$DIR/scripts/processing/prepare_wmh_vs_nawm.sh > logs/prep_wmh.log 2>&1
echo "Preparing WMH Shells"
$DIR/scripts/processing/prep_wmh_shell.shs > logs/prep_shells.log 2>&1
echo "Preparing Clusters"
$DIR/scripts/processing/prep_clusters.shs > logs/prep_clusters.log 2>&1
echo "Comparing WMH vs NAWM"
$DIR/scripts/processing/compare_wmh_vs_nawm.sh > logs/comp_wmh.log 2>&1
echo "Comparing Shells"
$DIR/scripts/processing/compare_wmh_shells.sh > logs/comp_shells.log 2>&1
echo "Measuring Clusters"
$DIR/scripts/processing/measure_clusters.sh > logs/measure_clusters.log 2>&1
#$DIR/scripts/processing/tractography.sh > tractography.log 2>&1
#$DIR/scripts/processing/get_connectome.sh > getConnectome.log 2>&1
cd $STARTDIR
