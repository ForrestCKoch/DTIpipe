#!/bin/sh

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

SUBJ="$1"
STARTDIR="$(pwd)"

cd "$SUBJ"
mkdir -p logs
#echo "Calculating Noddi"
#$DTIPIPE/scripts/processing/calculate_noddi.sh > logs/calculate_noddi.log 2>&1
#echo "Calculating Kurtosis"
#$DTIPIPE/scripts/processing/calculate_kurtosis.sh > logs/calculate_kurtosis.log 2>&1
#echo "Fitting tensors"
#$DTIPIPE/scripts/processing/fit_tensors.sh> logs/fit_tensors.log 2>&1
echo "Preparing WMH vs NAWM"
$DTIPIPE/scripts/processing/prepare_wmh_vs_nawm.sh > logs/prep_wmh.log 2>&1
echo "Preparing WMH Shells"
$DTIPIPE/scripts/processing/prep_wmh_shells.sh > logs/prep_shells.log 2>&1
echo "Preparing Clusters"
$DTIPIPE/scripts/processing/prep_clusters.sh > logs/prep_clusters.log 2>&1
echo "Preparing Cluster shells"
$DTIPIPE/scripts/processing/prep_cluster_shells.sh > logs/prep_cluster_shell.log 2>&1
echo "Comparing WMH vs NAWM"
$DTIPIPE/scripts/processing/compare_wmh_vs_nawm.sh > logs/comp_wmh.log 2>&1
echo "Comparing Shells"
$DTIPIPE/scripts/processing/compare_wmh_shells.sh > logs/comp_shells.log 2>&1
echo "Measuring Clusters"
$DTIPIPE/scripts/processing/measure_clusters.sh > logs/measure_clusters.log 2>&1
echo "Measuring Cluster shells"
$DTIPIPE/scripts/processing/measure_cluster_shells.sh > logs/measure_clusters.log 2>&1
cd $STARTDIR
