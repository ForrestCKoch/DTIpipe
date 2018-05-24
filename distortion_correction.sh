#!/bin/sh
# NOTE: Smith et Al 2012 mention upsampling.  Should we do this first?

ORIG=$(pwd)
EXTRAS="$(pwd)/../../DTIpipe"

mkdir -p workdir
cd workdir

mkdir -p distortion_correction
cd distortion_correction

# first, go through the topup process as per
# https://fsl.fmrib.ox.ac.uk/fsl/fslwiki/topup/TopupUsersGuide
######################################################
# Pre-topup preparation
######################################################

# need to extract the b0 images from the dti
# in our data they are 0,20,40,60,80,100,120,&140
echo "extracting b0 components..."
splitTargets="split0000 split0020 split0040 split0060 split0080 split0100 split0120 split0140"
fslsplit $ORIG/dti.nii split -t
fslmerge -t dti_b0 $splitTargets
rm split*
fslroi $ORIG/blip.nii blip_b0 0 1
echo "merging components"
fslmerge -t merged dti_b0 blip_b0
# and we need to throw out the bottom slice for topup to work
# https://www.jiscmail.ac.uk/cgi-bin/webadmin?A2=fsl;67dcb45c.1209
fslroi merged both_b0 0 -1 0 -1 1 -1

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
time topup -v --imain=both_b0 --datain=acqparams.txt --config=$b02b0 --out=topup --fout=field_map --iout=unwarped_b0

# let's denoise the data
echo "denoising diffusion data..."
mrconvert -fslgrad $EXTRAS/bvecs $EXTRAS/bvals $ORIG/dti.nii dwi.mif
dwidenoise dwi.mif dwi_denoised.mif -noise noise.mif
mrconvert dwi_denoised.mif dwi_denoised.nii
mrcalc dwi.mif dwi_denoised.mif -subtract res.mif

echo "applying eddy"
# trim the dti
fslroi dwi_denoised dti_trimmed 0 -1 0 -1 1 -1

# swap out applytopup for eddy
#applytopup --imain=dti_trimmed --inindex=1 --datain=acqparams.txt --topup=topup --out=undistorted --method=jac

# generate a mask from b0's
fslmaths unwarped_b0 -Tmean mean
bet mean mean -m -n -f 0.2

for i in $(seq 1 $(fslval dti_trimmed dim4)); do
    echo -n '1 '
done > index.txt

time eddy --imain=dti_trimmed --mask=mean_mask --acqp=acqparams.txt --index=index.txt --bvals=$EXTRAS/bvals --bvecs=$EXTRAS/bvecs --topup=topup --out=eddy_corrected --data_is_shelled

cp eddy_corrected.nii.gz ../dti_undistorted.nii.gz
cp unwarped_b0.nii.gz ../b0_undistorted.nii.gz

cd $ORIG

