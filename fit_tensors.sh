#!/bin/sh -v


EXTRAS="/home/forrest/Documents/BRAIN_Study/BRAIN_Training_Trial/DTI_Processing/workdir/DTIpipe"
bvals="$EXTRAS/bvals"
bvecs="$EXTRAS/bvecs"

cd workdir
mkdir -p maps
mkdir -p kurt
fslmaths unwarped_b0 -Tmean mean
bet mean mean -n -m -f 0.2

dtifit -k undistorted -r $bvecs -b $bvals -o maps/dti --kurt --kurtdir=kurt -m mean_mask

cd ../
