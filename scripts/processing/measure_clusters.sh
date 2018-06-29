#!/bin/bash

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
BASE="$(readlink -f $SCRIPT_DIR/../..)"

SUBJECT_DIR="$(pwd)"

# we should alter this to ultimately use original space possibly?
WMH_MASK="$SUBJECT_DIR/workdir/wmh_vs_nawm/wmh_mask_dwi_space"

cd workdir
mkdir -p clusters
cd clusters

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
lines=$(cat cluster.txt|tail -n $(( $(cat cluster.txt|wc -l) -1)))

while read c; do
id=$(echo $c|cut -d' ' -f1)
size=$(echo $c|cut -d' ' -f2)

echo "cluster #: $id"

echo -n $id,$(cat cluster_stats/cluster_${id}.csv|sed 's/\n//') >> cluster_results.csv

for map in $(ls $SUBJECT_DIR/workdir/response_maps/*/*.nii*); do
	map_name=$(echo $map|rev|cut -d'/' -f1|rev|cut -d'.' -f1)
	MEAN=$(fslstats $map -k dwi_clusters/cluster_${id} -M)
	echo -n ",$MEAN" >> cluster_results.csv
done
for map in $(ls $SUBJECT_DIR/workdir/noddi_calculation/noddi_*.nii*); do
	map_name=$(echo $map|rev|cut -d'/' -f1|rev|cut -d'.' -f1)
	MEAN=$(fslstats $map -k dwi_clusters/cluster_${id} -M)
	echo -n ",$MEAN" >> cluster_results.csv
done
for map in $(ls $SUBJECT_DIR/workdir/kurtosis_calculation/dke/dke_*.nii*); do
	map_name=$(echo $map|rev|cut -d'/' -f1|rev|cut -d'.' -f1)
	MEAN=$(fslstats $map -k dwi_clusters/cluster_${id} -M)
	echo -n ",$MEAN" >> cluster_results.csv
done

echo "" >> cluster_results.csv


done <<< "$lines"

cd $SUBJECT_DIR
