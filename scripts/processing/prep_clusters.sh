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
echo -n '#,Vol,SA,SP' >> cluster_results.csv
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
cluster --in=$WMH_MASK --thresh=1 --oindex=index --osize=size > cluster.txt
lines=$(cat cluster.txt|tail -n $(( $(cat cluster.txt|wc -l) -1)))

while read c; do
id=$(echo $c|cut -d' ' -f1)
size=$(echo $c|cut -d' ' -f2)

echo "cluster #: $id"

fslmaths index -thr $id -uthr $id -bin cluster_${id}_${size}
gunzip cluster_${id}_${size}.nii.gz
matlab -nosplash -nodesktop -r "\
fp = fopen('cluster_${id}_props.txt','w');\
mask = readnifti('cluster_${id}_${size}.nii');\
stats = regionprops3(mask,{'Volume' 'SurfaceArea'});\
v = stats.Volume;\
s = stats.SurfaceArea;\
sphericity = ((pi^(1/3))*(6*stats.Volume)^(2/3))/stats.SurfaceArea;\
fprintf(fp,'%f,%f,%f',stats.Volume,stats.SurfaceArea,sphericity);\
fp.close();\
"</dev/null > /dev/null 2>&1
echo -n $(cat cluster_${id}_props.txt|sed 's/\n//') >> cluster_results.csv

for map in $(ls $SUBJECT_DIR/workdir/response_maps/*/*.nii*); do
	map_name=$(echo $map|rev|cut -d'/' -f1|rev|cut -d'.' -f1)
	MEAN=$(fslstats $map -k cluster_${id}_${size} -M)
	echo -n "$MEAN" >> cluster_results.csv
done
for map in $(ls $SUBJECT_DIR/workdir/noddi_calculation/noddi_*.nii*); do
	map_name=$(echo $map|rev|cut -d'/' -f1|rev|cut -d'.' -f1)
	MEAN=$(fslstats $map -k cluster_${id}_${size} -M)
	echo -n "$MEAN" >> cluster_results.csv
done
for map in $(ls $SUBJECT_DIR/workdir/kurtosis_calculation/dke/dke_*.nii*); do
	map_name=$(echo $map|rev|cut -d'/' -f1|rev|cut -d'.' -f1)
	MEAN=$(fslstats $map -k cluster_${id}_${size} -M)
	echo -n "$MEAN" >> cluster_results.csv
done

echo "" >> cluster_results.csv


done <<< "$lines"


cd $SUBJECT_DIR
