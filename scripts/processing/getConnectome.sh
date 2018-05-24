#!/bin/sh

# A little hack to make sure paths are as we expect
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
HOME="$(readlink -f $SCRIPT_DIR/../..)"

SUBJECT_DIR=$(pwd)
FS_DEFAULT="$HOME/resources/fs_default.txt"
FS_COLOR_LUT="$HOME/FreeSurferColorLUT.txt"

cd workdir
mkdir -p connectome
cd connectome

labelconvert ../freesurfer/mri/aparc+aseg.mgz $FS_COLOR_LUT $FS_DEFAULT nodes.mif

labelsgmfix nodes.mif $SUBJECT_DIR/workdir/t1_coregistered.nii.gz $FS_DEFAULT nodes_fixSGM.mif

tck2connectome ../mrtrix_proc/100k_sift.tck nodes_fixSGM.mif connectome.csv

cd $SUBJECT_DIR
