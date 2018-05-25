#!/bin/sh

SUBJECT_DIR="$(pwd)"
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
HOME="$(readlink -f $DIR/../..)"

BVALS="$HOME/resources/bvals"
BVECS="$SUBJECT_DIR/workdir/distortion_correction/bvecs_ec"

cp $SUBJECT_DIR/workdir/coregistration/b0_mean_brain_mask.nii.gz brain_mask.nii.gz
cp $BVALS bvals
cp $BVECS bvecs

for i in *.nii.gz; do gunzip -d $i; done

export TZ='Australia/Sydney'

matlab -nojvm -nodesktop -r "try; $DIR/calculate_noddi.m; catch; end; quit" < /dev/null

cd $SUBJECT_DIR
