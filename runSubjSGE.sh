#!/usr/bin/bash
# load the minimum for now
module load fsl/5.0.11
module load mrtrix
module load python/3.6.6

DIR="$DTIPIPE"
SUBJ="$1"
STARTDIR="$(pwd)"
cd "$SUBJ"
mkdir logs
# $DIR/scripts/processing/parcellate.sh > parcellate.log 2>&1 & 
echo "Distortion Correction"
# $DIR/scripts/processing/distortion_correction.sh>logs/distortion_correction.log 2>&1 
echo "Coregistration"
# $DIR/scripts/processing/coregister.sh > logs/coregister.log 2>&1 
echo "Fitting tensors"
# $DIR/scripts/processing/fit_tensors.sh > logs/fit_tensors.log 2>&1 

# and load up special dke stuff
module load matlab/MCR-R2012a
module load dke
echo "Calculating Kurtosis"
# $DIR/scripts/processing/calculate_kurtosis.sh > logs/calculate_kurtosis.log 2>&1
module unload dke
module unload matlab/MCR-R2012a

# load up regular matlab
module load matlab/R2018a
echo "Calculating Noddi"
# $DIR/scripts/processing/calculate_noddi.sh > logs/calculate_noddi.log 2>&1

echo "Preparing WMH vs NAWM"
# $DIR/scripts/processing/prepare_wmh_vs_nawm.sh > logs/prep_wmh.log 2>&1
echo "Preparing WMH Shells"
# $DIR/scripts/processing/prep_wmh_shells.sh > logs/prep_shells.log 2>&1
echo "Preparing Clusters"
$DIR/scripts/processing/prep_clusters.sh > logs/prep_clusters.log 2>&1
echo "Preparing Cluster Shells"
$DIR/scripts/processing/prep_cluster_shells.sh > logs/prep_cluster_shells.log 2>&1
echo "Comparing WMH vs NAWM"
# $DIR/scripts/processing/compare_wmh_vs_nawm.sh > logs/comp_wmh.log 2>&1
echo "Comparing Shells"
# $DIR/scripts/processing/compare_wmh_shells.sh > logs/comp_shells.log 2>&1
echo "Measuring Clusters"
$DIR/scripts/processing/measure_clusters.sh > logs/measure_clusters.log 2>&1
echo "Measuring Cluster Shells"
$DIR/scripts/processing/measure_cluster_shells.sh > logs/measure_cluster_shells.log 2>&1
# $DIR/scripts/processing/tractography.sh > tractography.log 2>&1
# $DIR/scripts/processing/get_connectome.sh > getConnectome.log 2>&1
cd $STARTDIR
