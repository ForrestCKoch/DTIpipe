#!/bin/sh

# A little hack to make sure paths are as we expect
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
BASE="$DTIPIPE"

SUBJECT_DIR=$(pwd)

B0="$SUBJECT_DIR/workdir/distortion_correction/eddy_corrected_b0"
T1="$SUBJECT_DIR/t1"

C1="$SUBJECT_DIR/workdir/WMH_extract/subjects/*/mri/preprocessing/c1*"
C2="$SUBJECT_DIR/workdir/WMH_extract/subjects/*/mri/preprocessing/c2*"
C3="$SUBJECT_DIR/workdir/WMH_extract/subjects/*/mri/preprocessing/c3*"

cd workdir

mkdir -p coregistration
cd coregistration

echo "prepare T1 images..."
# get our brain extracted t1
#bet $T1 t1_brain -f 0.4 -v
# first we'll generate our wmseg
fslmaths $C2 -thr 0.75 -bin wmseg
fslmaths $C1 -add $C2 -add $C3 -bin t1_brain_mask
fslmaths $T1 -mas t1_brain_mask t1_brain

echo "Prepare dwi images..."
# create a mean of the undistorted data for registration
fslmaths $B0 -Tmean b0_mean
# brain extract the b0
bet b0_mean b0_mean_brain -m -f 0.2 -v

epi_reg -v --epi=b0_mean --t1=$T1 --t1brain=t1_brain --out=epi_reg \
	--wmseg=wmseg
# for backwards compatibility
cp epi_reg.mat b0_to_t1.mat

# and convert backwards
convert_xfm -omat t1_to_b0.mat -inverse b0_to_t1.mat

echo "Register T1 to dwi..."
flirt -v -ref b0_mean -in $T1 -applyxfm -init t1_to_b0.mat -out t1_coregistered

#cp t1_coregistered.nii.gz ../

cd $SUBJECT_DIR
