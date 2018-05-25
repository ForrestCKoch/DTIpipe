#!/bin/sh -v

# A little hack to make sure paths are as we expect
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
BASE="$(readlink -f $SCRIPT_DIR/../..)"

BVECS="$BASE/resources/bvals"
BVALS="$BASE/resources/bvecs"

cd workdir
mkdir -p maps
fslmaths unwarped_b0 -Tmean mean
bet mean mean -n -m -f 0.2

dtifit -k undistorted -r $BVECS -b $BVALS -o maps/dti -m mean_mask

cd ../
