#!/bin/sh

# A little hack to make sure paths are as we expect
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
BASE="$(readlink -f $SCRIPT_DIR/../..)"

START="$(pwd)"

mkdir -p ../QC/denoise_residual_check

for i in *; do
	echo "Preparing $i ..."
	res="$i/workdir/distortion_correction/res.mif"
	mrconvert $res ../QC/denoise_residual_check/${i}.nii
done

cd ../QC/denoise_residual_check
echo "Calling slicesdir ..."
slicesdir *

cd $START


