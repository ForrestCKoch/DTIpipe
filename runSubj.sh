#!/bin/sh

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

SUBJ="$1"
STARTDIR="$(pwd)"

cd "$SUBJ"
mkdir logs
#$DTIPIPE/scripts/processing/parcellate.sh > parcellate.log 2>&1 & 
echo "Distortion Correction"
$DTIPIPE/scripts/processing/distortion_correction.sh>logs/distortion_correction.log 2>&1 
echo "Coregistration"
$DTIPIPE/scripts/processing/coregister.sh > logs/coregister.log 2>&1 
echo "Fitting tensors"
$DTIPIPE/scripts/processing/fit_tensors.sh > logs/fit_tensors.log 2>&1 
echo "Calculating Noddi"
$DTIPIPE/scripts/processing/calculate_noddi.sh > logs/calculate_noddi.log 2>&1
echo "Calculating Kurtosis"
$DTIPIPE/scripts/processing/calculate_kurtosis.sh > logs/calculate_kurtosis.log 2>&1
echo "Preparing WMH vs NAWM"
$DTIPIPE/scripts/processing/prepare_wmh_vs_nawm.sh > logs/prep_wmh.log 2>&1
echo "Preparing WMH Shells"
$DTIPIPE/scripts/processing/prep_wmh_shell.shs > logs/prep_shells.log 2>&1
echo "Preparing Clusters"
$DTIPIPE/scripts/processing/prep_clusters.shs > logs/prep_clusters.log 2>&1
echo "Comparing WMH vs NAWM"
$DTIPIPE/scripts/processing/compare_wmh_vs_nawm.sh > logs/comp_wmh.log 2>&1
echo "Comparing Shells"
$DTIPIPE/scripts/processing/compare_wmh_shells.sh > logs/comp_shells.log 2>&1
echo "Measuring Clusters"
$DTIPIPE/scripts/processing/measure_clusters.sh > logs/measure_clusters.log 2>&1
#$DTIPIPE/scripts/processing/tractography.sh > tractography.log 2>&1
#$DTIPIPE/scripts/processing/get_connectome.sh > getConnectome.log 2>&1
cd $STARTDIR
