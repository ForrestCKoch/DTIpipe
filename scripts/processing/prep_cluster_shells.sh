#!/bin/bash

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
BASE="$DTIPIPE"

SUBJECT_DIR="$(pwd)"

FLAIR="$SUBJECT_DIR/workdir/WMH_extract/subjects/*/mri/orig/*_FLAIR.nii"

T1="$SUBJECT_DIR/t1.nii"
WMSEG="$SUBJECT_DIR/workdir/wmh_vs_nawm/wm_mask_dwi_space"

SHELLDIR="$SUBJECT_DIR/workdir/wmh_vs_nawm/wmh_shells"
CLUSTDIR="$SUBJECT_DIR/workdir/clusters/dwi_clusters"
CNUM=$(ls $CLUSTDIR|wc -l)

cd workdir
mkdir -p cluster_shells
cd cluster_shells

for i in $(seq 1 $CNUM); do
	echo "Cluster $i:"
	mkdir -p cluster_$i
	echo "    Creating dilation masks"
	cluster="$CLUSTDIR/cluster_$i"
	prev_mask="$CLUSTDIR/cluster_$i"
	for j in $(seq 2 12); do
		echo "        ${j}mm..."
		# the name of the next mask to be created
		mname="cluster_${i}/cluster_${i}_shelled_dilated_${j}mm_gauss_mask"
		# expand, subtract out previous, threshold to avoid neg
		# mask to ensure wm and force binary
		fslmaths $cluster -kernel gauss $j -dilM -sub $prev_mask \
			-thr 0 -mas $WMSEG -bin $mname
		prev_mask="$SHELLDIR/dilated_${j}mm_gauss_wmh_mask"
	done	
	echo "    Creating erosion masks"
	prev_mask="$CLUSTDIR/cluster_$i"
	for j in $(seq 2 3); do
		echo "        ${j}mm..."
		ename="cluster_${i}/cluster_${i}_eroded_${j}mm_gauss_mask"	
		mname="cluster_${i}/cluster_${i}_shelled_eroded_${j}mm_gauss_mask"	
		fslmaths $cluster -kernel gauss $j -ero $ename
		fslmaths $prev_mask -sub $ename -thr 0 $mname
		prev_mask=$ename
	done
done
	
cd $SUBJECT_DIR
