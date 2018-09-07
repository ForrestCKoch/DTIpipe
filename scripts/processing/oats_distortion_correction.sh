#!/bin/sh
# NOTE: Smith et Al 2012 mention upsampling.  Should we do this first?

# A little hack to make sure paths are as we expect
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
BASE="$DTIPIPE"

SUBJECT_DIR=$(pwd)
BVALS="$SUBJECT_DIR/dti.bval"
BVECS="$SUBJECT_DIR/dti.bvec"

mkdir -p workdir
cd workdir

mkdir -p distortion_correction
cd distortion_correction

######################################################
# Pre-topup preparation
######################################################

cp $SUBJECT_DIR/dti.nii .

echo "merging components"
fslmerge -t both_b0 $SUBJECT_DIR/blip_up $SUBJECT_DIR/blip_down

# need to creat an acqparams.txt file
# according to guide positive blip means signal is displaced upward
echo -n "" > acqparams.txt
echo "0 1 0 .09758" >> acqparams.txt
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

if has eddy 2>/dev/null; then
    time eddy -v --imain=dti_denoised --mask=mean_mask \
        --acqp=acqparams.txt --index=index.txt \
        --bvals=$BVALS --bvecs=$BVECS --topup=topup \
        --out=eddy_corrected --data_is_shelled
else;
    time eddy_openmp -v --imain=dti_denoised --mask=mean_mask \
        --acqp=acqparams.txt --index=index.txt \
        --bvals=$BVALS --bvecs=$BVECS --topup=topup \
        --out=eddy_corrected --data_is_shelled
fi    

cp eddy_corrected.eddy_rotated_bvecs bvecs_ec

# and remake a new b0 that is eddy corrected
echo "extracting eddy corrected b0 components..."
dwiextract -bzero -fslgrad $BVECS $BVALS eddy_corrected eddy_corrected_b0

cd $SUBJECT_DIR

