#!/bin/bash

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
BASE="$DTIPIPE"

SUBJECT_DIR="$(pwd)"

FLAIR="$SUBJECT_DIR/workdir/WMH_extract/subjects/*/mri/orig/*_FLAIR.nii"
WMH_MASK="$SUBJECT_DIR/workdir/WMH_extract/subjects/*/mri/extractedWMH/*_WMH_FLAIRspace.nii.gz"

T1="$SUBJECT_DIR/t1.nii"
T1_BRAIN="$SUBJECT_DIR/workdir/coregistration/t1_brain"
T1_BRAIN_MASK="$SUBJECT_DIR/workdir/coregistration/t1_brain_mask"
WMSEG="$SUBJECT_DIR/workdir/coregistration/wmseg.nii.gz"

T1_TO_B0_MAT="$SUBJECT_DIR/workdir/coregistration/t1_to_b0.mat"
B0_MEAN_BRAIN="$SUBJECT_DIR/workdir/coregistration/b0_mean_brain.nii.gz"

cd workdir
mkdir -p wmh_vs_nawm
cd wmh_vs_nawm

cp $WMH_MASK wmh_mask_flair_space.nii.gz
# perform clustering in FLAIR space first
#cluster --in=$WMH_MASK --thresh=1 --oindex=index_flair_space --osize=size_flair_space > clusters.txt

#echo "performing brain extraction..."
#bet $T1 t1_brain
#bet $FLAIR flair_brain
# coregister t1 and flair to get the wmh mask in t1 space
echo "converting flair to t1 space..."
flirt -in $FLAIR -ref $T1_BRAIN -dof 6 -omat flair_to_t1.mat \
	-out flair_t1_space
fslmaths flair_t1_space -mas $T1_BRAIN_MASK flair_brain_t1_space
flirt -in $WMH_MASK -ref $T1_BRAIN -applyxfm -init flair_to_t1.mat \
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
	-init $T1_TO_B0_MAT -interp nearestneighbour -out incomp_wm_mask_dwi_space
flirt -in flair_brain_t1_space -ref $B0_MEAN_BRAIN -applyxfm \
	-init $T1_TO_B0_MAT -out flair_brain_dwi_space

# create a true wm_mask
fslmaths incomp_wm_mask_dwi_space -add wmh_mask_dwi_space -bin wm_mask_dwi_space

# for convenience generate a matrix from flair to dwi
convert_xfm -omat flair_to_dwi.mat -concat $T1_TO_B0_MAT flair_to_t1.mat

cd $SUBJECT_DIR
