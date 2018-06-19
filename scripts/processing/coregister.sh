#!/bin/sh

# A little hack to make sure paths are as we expect
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
BASE="$(readlink -f $SCRIPT_DIR/../..)"

SUBJECT_DIR=$(pwd)

B0="$SUBJECT_DIR/workdir/distortion_correction/eddy_corrected_b0"
T1="$SUBJECT_DIR/t1"

cd workdir

mkdir -p coregistration
cd coregistration

echo "prepare T1 images..."
# get our brain extracted t1
bet $T1 t1_brain -f 0.4 -v


echo "Prepare dwi images..."
# create a mean of the undistorted data for registration
fslmaths $B0 -Tmean b0_mean
# brain extract the b0
bet b0_mean b0_mean_brain -m -f 0.2 -v

epi_reg -v --epi=b0_mean --t1=$T1 --t1brain=t1_brain --out=epi_reg
# for backwards compatibility
cp epi_reg_fast_wmseg.nii.gz wmseg.nii.gz
cp epi_reg.mat b0_to_t1.mat

# and convert backwards
convert_xfm -omat t1_to_b0.mat -inverse b0_to_t1.mat

echo "Register T1 to dwi..."
flirt -v -ref b0_mean -in $SUBJECT_DIR/t1 -applyxfm -init t1_to_b0.mat \
	-out t1_coregistered

#cp t1_coregistered.nii.gz ../

cd $SUBJECT_DIR
