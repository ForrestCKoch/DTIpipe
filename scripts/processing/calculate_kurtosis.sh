#!/bin/sh

SUBJECT_DIR="$(pwd)"
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
BASE="$(readlink -f $DIR/../..)"

DKE_PARAM="$BASE/resources/dke_params.dat"
BVECS="$SUBJECT_DIR/workdir/distortion_correction/bvecs_ec"

cd workdir
mkdir -p kurtosis_calculation
cd kurtosis_calculation
mkdir -p dke

echo 'building bvecs table...'
$BASE/scripts/helpers/generate_dke_bvecs_table.py $BVECS
cp $SUBJECT_DIR/workdir/distortion_correction/eddy_corrected.nii.gz tmp.nii.gz

echo 'preparing dti volumes... '
fslsplit tmp
rm vol0020.nii.gz vol0040.nii.gz vol0060.nii.gz vol0080.nii.gz vol0100.nii.gz vol0120.nii.gz vol0140.nii.gz 
echo 'merging dti volumes ...'
fslmerge -t dti vol*

rm tmp.nii.gz
rm vol*

echo 'unzipping dti ...'
gunzip dti.nii.gz

mv dti.nii outdir 

echo 'running dke ...'
dke $DKE_PARAM


cd $SUBJECT_DIR
