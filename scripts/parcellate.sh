#!/bin/sh

mkdir -p workdir

EXTRAS="$(pwd)/../../DTIpipe"
SUBDIR="$(pwd)"

cd workdir
mkdir -p freesurfer
export SUBJECTS_DIR="$(pwd)"

recon-all -i $SUBDIR/t1.nii -subjid freesurfer -all

cd $SUBDIR
