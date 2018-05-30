#!/bin/sh

# A little hack to make sure paths are as we expect
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
BASE="$(readlink -f $SCRIPT_DIR/../..)"

BVALS="$BASE/resources/bvals"
BVECS="$(pwd)/workdir/distortion_correction/bvecs_ec"
DTI="$(pwd)/workdir/distortion_correction/eddy_corrected"
MASK="$(pwd)/workdir/coregistration/b0_mean_brain_mask"

cd workdir
mkdir -p response_maps
cd response_maps
mkdir -p fsl_dti_maps
mkdir -p fsl_kurt_maps

#fslmaths unwarped_b0 -Tmean mean
#bet mean mean -n -m -f 0.2

dtifit -k $DTI -r $BVECS -b $BVALS -o fsl_tensor_maps/dti -m $MASK
dtifit --kurt -k $DTI -r $BVECS -b $BVALS -o fsl_kurt_maps/kurt -m $MASK

cd ../
