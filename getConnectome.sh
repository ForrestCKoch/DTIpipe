#!/bin/sh

ORIG=$(pwd)
FS_DEFAULT='/home/forrest/.local/share/mrtrix3/labelconvert/fs_default.txt'
FS_COLOR_LUT="$FREESURFER_HOME/FreeSurferColorLUT.txt"

cd workdir
mkdir -p connectome
cd connectome

labelconvert ../freesurfer/mri/aparc+aseg.mgz $FS_COLOR_LUT $FS_DEFAULT nodes.mif

labelsgmfix nodes.mif $ORIG/workdir/t1_coregistered.nii.gz $FS_DEFAULT nodes_fixSGM.mif

tck2connectome ../mrtrix_proc/100k_sift.tck nodes_fixSGM.mif connectome.csv

cd $ORIG
