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

echo "performing brain extraction..."
bet $T1 t1_brain
bet $FLAIR flair_brain
# coregister t1 and flair to get the wmh mask in t1 space
echo "converting flair to t1 space..."
flirt -in flair_brain -ref t1_brain -dof 6 -omat flair_to_t1.mat \
	-out flair_brain_t1_space
flirt -in $WMH_MASK -ref t1_brain -applyxfm -init flair_to_t1.mat \
	-interp nearestneighbour -out wmh_mask_t1_space

# now generate nawm mask
fslmaths $WMSEG -sub wmh_mask_t1_space -thr 0 -bin nawm_mask_t1_space

# and convert masks and flair to dwi space
echo "now convert everything to dwi space..."
flirt -in wmh_mask_t1_space -ref $B0_MEAN_BRAIN -applyxfm \
	-init $T1_TO_B0_MAT -interp nearestneighbour -out wmh_mask_dwi_space
flirt -in nawm_mask_t1_space -ref $B0_MEAN_BRAIN -applyxfm \
	-init $T1_TO_B0_MAT -interp nearestneighbour -out nawm_mask_dwi_space
flirt -in $WMSEG -ref $B0_MEAN_BRAIN -applyxfm \
	-init $T1_TO_B0_MAT -interp nearestneighbour -out wm_mask_dwi_space
flirt -in flair_brain_t1_space -ref $B0_MEAN_BRAIN -applyxfm \
	-init $T1_TO_B0_MAT -out flair_brain_dwi_space

