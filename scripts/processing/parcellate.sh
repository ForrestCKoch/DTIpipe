#!/bin/sh

# A little hack to make sure paths are as we expect
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
HOME="$(readlink -f $SCRIPT_DIR/../..)"

mkdir -p workdir

SUBJECT_DIR="$(pwd)"

cd workdir
mkdir -p freesurfer

export SUBJECTS_DIR="$(pwd)"

recon-all -i $SUBJECT_DIR/t1.nii -subjid freesurfer -all

cd $SUBJECT_DIR
