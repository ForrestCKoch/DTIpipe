#!/bin/bash

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
BASE="$(readlink -f $SCRIPT_DIR/../..)"

SUBJECT_DIR="$(pwd)"

FLAIR="$SUBJECT_DIR/workdir/WMH_extract/subjects/*/mri/orig/*_FLAIR.nii"
WMH_MASK="$SUBJECT_DIR/workdir/WMH_extract/subjects/*/mri/extractedWMH/*_WMH_FLAIRspace.nii.gz"

T1="$SUBJECT_DIR/t1.nii"
WMSEG="$SUBJECT_DIR/workdir/coregistration/wmseg.nii.gz"

T1_TO_B0_MAT="$SUBJECT_DIR/workdir/coregistration/t1_to_b0.mat"
B0_MEAN_BRAIN="$SUBJECT_DIR/workdir/coregistration/b0_mean_brain.nii.gz"

cd workdir
mkdir -p wmh_vs_nawm
cd wmh_vs_nawm

echo "creating dilation masks"
# create some dilation masks
prev="wmh_mask_dwi_space"
for i in $(seq 2 6); do
	echo "\t${i}mm..."
	mname="dilated_${i}mm_gauss_wmh_mask"
	# create the 'full' mask first
	fslmaths wmh_mask_dwi_space -kernel gauss $i -dilM \
		-mas wm_mask_dwi_space dialated_${i}mm_gaussian_wmh
	# now create the 'shell'
	fslmaths $mname -sub $prev -thr 0 shelled_$mname
	prev=$mname
	# we could also create a new 'nawm' however, it might start
	# to shrink too much

echo "creating erosion masks" 
for i in $(seq 2 4); do
	echo "\t${i}mm..."
	mname="eroded_${i}mm_gauss_wmh_mask"
	fslmaths wmh_mask_dwi_space -kernel gauss $i $mname
	

	
