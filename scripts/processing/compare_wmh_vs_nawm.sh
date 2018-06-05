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

echo "calculating means from masks..."
# create our csv
echo -n '' > comparison_results.csv
echo "filename,wm_mean,wm_sd,wmh_mean,wmh_sd,nawm_mean,nawm_sd"\
	>>comparison_results.csv

for map in $(ls $SUBJECT_DIR/workdir/response_maps/*/*); do
	map_name=$(echo $map|rev|cut -d'/' -f1|rev)
	echo $map_name
	WM_MEAN=$(fslstats $map -k $WM -M)
	WM_SDEV=$(fslstats $map -k $WM -S)
	WMH_MEAN=$(fslstats $map -k $WMH -M)
	WMH_SDEV=$(fslstats $map -k $WMH -S)
	NAWM_MEAN=$(fslstats $map -k $NAWM -M)
	NAWM_SDEV=$(fslstats $map -k $NAWM -S)
	echo "$map_name,$WM_MEAN,$WM_SDEV,$WMH_MEAN,$WMH_SDEV,$NAWM_MEAN,$NAWM_SDEV" \
		>> comparison_results.csv
done

for map in $(ls $SUBJECT_DIR/workdir/noddi_calculation/noddi_*); do
	map_name=$(echo $map|rev|cut -d'/' -f1|rev)
	echo $map_name
	WM_MEAN=$(fslstats $map -k $WM -M)
	WM_SDEV=$(fslstats $map -k $WM -S)
	WMH_MEAN=$(fslstats $map -k $WMH -M)
	WMH_SDEV=$(fslstats $map -k $WMH -S)
	NAWM_MEAN=$(fslstats $map -k $NAWM -M)
	NAWM_SDEV=$(fslstats $map -k $NAWM -S)
	echo "$map_name,$WM_MEAN,$WM_SDEV,$WMH_MEAN,$WMH_SDEV,$NAWM_MEAN,$NAWM_SDEV" \
		>> comparison_results.csv
done
