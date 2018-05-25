#!/bin/sh

# A little hack to make sure paths are as we expect
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
HOME="$(readlink -f $SCRIPT_DIR/../..)"

SUBJECT_DIR=$(pwd)

cd workdir

mkdir -p coregistration
cd coregistration

# get our brain extracted t1
bet $SUBJECT_DIR/t1 t1_brain -f 0.4
# segmentation
fast -o fast t1_brain
# threshold to obtain a wm mask
fslmaths fast_pve_2 -thr 0.7 -bin wmseg

# create a mean of the undistorted data for registration
fslmaths $SUBJECT_DIR/workdir/distortion_correction/eddy_corrected_b0 -Tmean b0_mean

# brain extract the b0
bet b0_mean b0_mean_brain -m -f 0.2

# register
flirt -ref $SUBJECT_DIR/t1 -in b0_mean -dof 6 -cost bbr -wmseg wmseg \
    -omat b0_to_t1.mat -out b0_mean_coregistered -schedule $FSLDIR/etc/flirtsch/bbr.sch

# and convert backwards
convert_xfm -omat t1_to_b0.mat -inverse b0_to_t1.mat

flirt -ref b0_mean -in $SUBJECT_DIR/t1 -applyxfm -init t1_to_b0.mat -out t1_coregistered

#cp t1_coregistered.nii.gz ../

cd $SUBJECT_DIR
