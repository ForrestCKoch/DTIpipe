#!/bin/bash

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
# BASE="$(readlink -f $SCRIPT_DIR/../..)"
BASE="$DTIPIPE"

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

echo "calculating means from masks..."
# create our csv
echo -n '' > comparison_results.csv
echo "map,wm_mean,wm_sd,wmh_mean,wmh_sd,nawm_mean,nawm_sd"\
	>>comparison_results.csv

# for fsl results
for map in $(ls $SUBJECT_DIR/workdir/response_maps/*/*.nii*); do
	map_name=$(echo $map|rev|cut -d'/' -f1|rev|cut -d'.' -f1)
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

# for noddi results
for map in $(ls $SUBJECT_DIR/workdir/noddi_calculation/noddi_*.nii*); do
	map_name=$(echo $map|rev|cut -d'/' -f1|rev|cut -d'.' -f1)
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

# for DKE results
for map in $(ls $SUBJECT_DIR/workdir/kurtosis_calculation/dke/dke_*.nii*); do
	map_name=$(echo $map|rev|cut -d'/' -f1|rev|cut -d'.' -f1)
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

cd $SUBJECT_DIR
