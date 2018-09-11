#!/bin/sh

# A little hack to make sure paths are as we expect
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
BASE="$DTIPIPE"

BVALS="$BASE/resources/bvals"
BVECS="$(pwd)/workdir/distortion_correction/bvecs_ec"
DTI="$(pwd)/workdir/distortion_correction/eddy_corrected.nii.gz"
MASK="$(pwd)/workdir/coregistration/b0_mean_brain_mask"

cd workdir
mkdir -p response_maps
cd response_maps
mkdir -p fsl_kurt_maps

# fit the kurtosis model
echo "Using 0, 700, 1000, 2800 b-vals"
dtifit --kurt -k $DTI -r $BVECS -b $BVALS -o fsl_kurt_maps/kurt -m $MASK
# create the RD metric
fslmaths fsl_kurt_maps/dti_L1 -add fsl_kurt_maps/kurt_L2 -div 2 \
	fsl_kurt_maps/kurt_RD

# fit the dti model using only shells < 2000
# can include a list (eg 700, 700_1000, 700_1000_28000...)
for i in 700_1000; do
	mkdir -p fsl_$i
	echo "Using 0, $(echo $i|tr '_' ',') b-vals"
	dwiextract -shell 0,$(echo $i|tr '_' ',')  -fslgrad $BVECS $BVALS $DTI - |\
	mrconvert -export_grad_fsl bvecs_$i bvals_$i - dti_$i.nii
	dtifit -k dti_$i -r bvecs_$i -b bvals_$i \
		-o fsl_$i/dti_$i -m $MASK
	fslmaths fsl_$i/dti_${i}_L1 -add fsl_$i/dti_${i}_L2 -div 2 \
		fsl_$i/dti_${i}_RD
	#cp fsl_$i/dti_${i}_L1 fsl_$i/dti_${i}_AD
done

cd ../
