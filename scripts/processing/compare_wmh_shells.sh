#!/bin/bash

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
BASE="$(readlink -f $SCRIPT_DIR/../..)"

SUBJECT_DIR="$(pwd)"

FLAIR="$SUBJECT_DIR/workdir/WMH_extract/subjects/*/mri/orig/*_FLAIR.nii"
WMH_MASK="$SUBJECT_DIR/workdir/WMH_extract/subjects/*/mri/extractedWMH/*_WMH_FLAIRspace.nii.gz"

T1="$SUBJECT_DIR/t1.nii"
WMSEG="$SUBJECT_DIR/workdir/coregistration/wmseg.nii.gz"

T1_TO_B0_MAT="$SUBJECT_DIR/workdir/coregistration/t1_to_b0.mat"
B0_MEAN_BRAIN="$SUBJECT_DIR/workdir/coregistration/b0_mean_brain.nii.gz"

WMH="wmh_mask_dwi_space"
WM="wm_mask_dwi_space"
NAWM="nawm_mask_dwi_space"

cd workdir/wmh_vs_nawm

echo "calculating means from shells"
# create our csv
echo -n '' > shell_comparison_results.csv
echo -n "filename" >> shell_comparison_results.csv
for mask in $(ls wmh_shells/*); do
	name=$(echo $mask|cut -d'/' -f2|cut -d'.' -f1)	
	echo -n ",${name} mean,${name} sdev" >> shell_comparison_results.csv
done
echo "" >> shell_comparison_results.csv

for map in $(ls $SUBJECT_DIR/workdir/response_maps/*/*); do
	map_name=$(echo $map|rev|cut -d'/' -f1|rev|cut -d'.' -f1)
	echo $map_name
	echo -n "$map_name" >> shell_comparison_results.csv
	for mask in $(ls wmh_shells/*); do
		mask_name=$(echo $mask|cut -d'/' -f2|cut -d'.' -f1)	
		MEAN=$(fslstats $map -k $mask -M)
		SDEV=$(fslstats $map -k $mask -S)
		echo -n ",$MEAN,$SDEV" >> shell_comparison_results.csv
	done
	echo '' >> shell_comparison_results.csv
done

for map in $(ls $SUBJECT_DIR/workdir/noddi_calculation/noddi_*); do
	map_name=$(echo $map|rev|cut -d'/' -f1|rev|cut -d'.' -f1)
	echo $map_name
	echo -n "$map_name" >> shell_comparison_results.csv
	for mask in $(ls wmh_shells/*); do
		mask_name=$(echo $mask|cut -d'/' -f2|cut -d'.' -f1)	
		MEAN=$(fslstats $map -k $mask -M)
		SDEV=$(fslstats $map -k $mask -S)
		echo -n ",$MEAN,$SDEV" >> shell_comparison_results.csv
	done
	echo '' >> shell_comparison_results.csv
done

cd $SUBJECT_DIR
