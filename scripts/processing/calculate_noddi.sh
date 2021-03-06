#!/bin/sh

SUBJECT_DIR="$(pwd)"
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
# BASE="$(readlink -f $DIR/../..)"
BASE="$DTIPIPE"

BVALS="$BASE/resources/bvals"
BVECS="$SUBJECT_DIR/workdir/distortion_correction/bvecs_ec"

cd workdir
mkdir -p noddi_calculation
cd noddi_calculation

echo 'copying files...'
cp $SUBJECT_DIR/workdir/coregistration/b0_mean_brain_mask.nii.gz brain_mask.nii.gz
cp $SUBJECT_DIR/workdir/distortion_correction/eddy_corrected.nii.gz dti.nii.gz
cp $BVALS bvals
cp $BVECS bvecs

echo 'unzipping...'

for i in *.nii.gz; do gunzip -f -d $i; done

export TZ='Australia/Sydney'

cp $BASE/scripts/processing/calculate_noddi.m .

matlab -nosplash -nodesktop -r "calculate_noddi" < /dev/null

rm calculate_noddi.m

cd $SUBJECT_DIR
