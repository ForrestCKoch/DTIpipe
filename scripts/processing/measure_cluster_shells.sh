#!/bin/bash

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
BASE="$DTIPIPE"

SUBJECT_DIR="$(pwd)"

# we should alter this to ultimately use original space possibly?
WMH_MASK="$SUBJECT_DIR/workdir/wmh_vs_nawm/wmh_mask_dwi_space"

CNUM=$(ls $SUBJECT_DIR/workdir/clusters/dwi_clusters|wc -l)
CLUSTER_STATS="$SUBJECT_DIR/workdir/clusters/cluster_stats"

cd workdir
cd cluster_shells

# prepare our header
echo -n '' > cluster_results.csv
echo -n '#,Vol,SA,SP,BR,EC' >> cluster_results.csv
for map in $(ls $SUBJECT_DIR/workdir/response_maps/*/*.nii*); do
	map_name=$(echo $map|rev|cut -d'/' -f1|rev|cut -d'.' -f1)
	echo -n ",$map_name" >> cluster_results.csv
done
for map in $(ls $SUBJECT_DIR/workdir/noddi_calculation/noddi_*.nii*); do
	map_name=$(echo $map|rev|cut -d'/' -f1|rev|cut -d'.' -f1)
	echo -n ",$map_name" >> cluster_results.csv
done
for map in $(ls $SUBJECT_DIR/workdir/kurtosis_calculation/dke/dke_*.nii*); do
	map_name=$(echo $map|rev|cut -d'/' -f1|rev|cut -d'.' -f1)
	echo -n ",$map_name" >> cluster_results.csv
done
echo "" >> cluster_results.csv

# get clusters

for id in $(seq 1 $CNUM); do

	echo "cluster #: $id"

	for mask in cluster_$id/*; do 
		echo "    $mask"
		echo -n $mask,$(cat $CLUSTER_STATS/cluster_${id}.csv|sed 's/\n//') \
			>> cluster_results.csv

		for map in $(ls $SUBJECT_DIR/workdir/response_maps/*/*.nii*); do
			map_name=$(echo $map|rev|cut -d'/' -f1|rev|cut -d'.' -f1)
			MEAN=$(fslstats $map -k $mask -M)
			echo -n ",$MEAN" >> cluster_results.csv
		done
		for map in $(ls $SUBJECT_DIR/workdir/noddi_calculation/noddi_*.nii*); do
			map_name=$(echo $map|rev|cut -d'/' -f1|rev|cut -d'.' -f1)
			MEAN=$(fslstats $map -k $mask -M)
			echo -n ",$MEAN" >> cluster_results.csv
		done
		for map in $(ls $SUBJECT_DIR/workdir/kurtosis_calculation/dke/dke_*.nii*); do
			map_name=$(echo $map|rev|cut -d'/' -f1|rev|cut -d'.' -f1)
			MEAN=$(fslstats $map -k $mask -M)
			echo -n ",$MEAN" >> cluster_results.csv
		done

		echo "" >> cluster_results.csv
	done
done

cd $SUBJECT_DIR
