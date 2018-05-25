#!/bin/sh
# NOTE: Smith et Al 2012 mention upsampling.  Should we do this first?

# A little hack to make sure paths are as we expect
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
BASE="$(readlink -f $SCRIPT_DIR/../..)"

SUBJECT_DIR=$(pwd)
BVALS="$BASE/resources/bvals"
BVECS="$BASE/resources/bvecs"

mkdir -p workdir
cd workdir

mkdir -p distortion_correction
cd distortion_correction

######################################################
# Pre-topup preparation
######################################################

# first let's handle this annoying requirement for even # of slices
DTI_SLICES=$(fslval $SUBJECT_DIR/dti dim3)
# check if even or odd
if [ $(($DTI_SLICES%2)) -eq 1 ]; then
    # lose the bottom slice
    fslroi $SUBJECT_DIR/dti dti_even 0 -1 0 -1 1 -1      
else
    cp $SUBJECT_DIR/dti.nii dti_even.nii
fi

# first let's handle this annoying requirement for even # of slices
BLIP_SLICES=$(fslval $SUBJECT_DIR/dti dim3)
# check if even or odd
if [ $(($BLIP_SLICES%2)) -eq 1 ]; then
    # lose the bottom slice
    fslroi $SUBJECT_DIR/blip blip_even 0 -1 0 -1 1 -1      
else
    cp $SUBJECT_DIR/blip.nii blip_even.nii
fi

# need to extract the b0 images from the dti
# in our data they are 0,20,40,60,80,100,120,&140
echo "extracting b0 components..."

# we should replace this with a function to find them automatically
splitTargets="split0000 split0020 split0040 split0060 split0080 split0100 split0120 split0140"

fslsplit dti_even split -t
fslmerge -t dti_b0 $splitTargets
rm split*

fslroi blip_even blip_b0 0 1

echo "merging components"
fslmerge -t both_b0 dti_b0 blip_b0

# need to creat an acqparams.txt file
# according to guide positive blip means signal is displaced upward
echo -n "" > acqparams.txt
for i in $(seq 1 8); do
    echo "0 1 0 .09758" >> acqparams.txt
done
echo "0 -1 0 .09758" >> acqparams.txt

######################################################
# Topup and applytopup
######################################################
echo "running topup"
b02b0="$FSLDIR/etc/flirtsch/b02b0.cnf"
time topup -v --imain=both_b0 --datain=acqparams.txt --config=$b02b0 --out=topup \
    --fout=field_map --iout=b0_undistorted

# let's denoise the data
echo "denoising diffusion data..."
mrconvert -fslgrad $BVECS $BVALS dti_even* dti.mif
dwidenoise dti.mif dti_denoised.mif -noise noise.mif
mrconvert dti_denoised.mif dti_denoised.nii
mrcalc dti.mif dti_denoised.mif -subtract res.mif

# generate a mask from b0's
fslmaths b0_undistorted -Tmean mean
bet mean mean -m -n -f 0.2

for i in $(seq 1 $(fslval dti_denoised dim4)); do
    echo -n '1 '
done > index.txt

time eddy -v --imain=dti_denoised --mask=mean_mask --acqp=acqparams.txt --index=index.txt \
    --bvals=$BVALS --bvecs=$BVECS --topup=topup --out=eddy_corrected --data_is_shelled

cp eddy_corrected.eddy_rotated_bvecs bvecs_ec

# and remake a new b0 that is eddy corrected
# in our data they are 0,20,40,60,80,100,120,&140
echo "extracting eddy corrected b0 components..."

# we should replace this with a function to find them automatically
splitTargets="split0000 split0020 split0040 split0060 split0080 split0100 split0120 split0140"

fslsplit eddy_corrected split -t
fslmerge -t eddy_corrected_b0 $splitTargets
rm split*

#cp eddy_corrected.nii.gz ../dti_undistorted.nii.gz
#cp unwarped_b0.nii.gz ../b0_undistorted.nii.gz

cd $SUBJECT_DIR

