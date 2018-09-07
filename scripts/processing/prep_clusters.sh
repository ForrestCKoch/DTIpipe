#!/bin/bash

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
BASE="$DTIPIPE"

SUBJECT_DIR="$(pwd)"

WMH_MASK="$SUBJECT_DIR/workdir/wmh_vs_nawm/wmh_mask_flair_space"
FLAIR_TO_DWI="$SUBJECT_DIR/workdir/wmh_vs_nawm/flair_to_dwi.mat"
DTI="$SUBJECT_DIR/workdir/distortion_correction/eddy_corrected"

cd workdir
mkdir -p clusters
cd clusters
mkdir -p flair_clusters
mkdir -p dwi_clusters
mkdir -p cluster_stats


# get clusters
cluster --in=$WMH_MASK --thresh=1 --oindex=index_flair --osize=size_flair > cluster.txt
lines=$(cat cluster.txt|tail -n $(( $(cat cluster.txt|wc -l) -1)))

#convert cluster results to dwi
flirt -in index_flair -ref $DTI -applyxfm -init $FLAIR_TO_DWI\
	-out index_dwi -interp nearestneighbour
flirt -in size_flair -ref $DTI -applyxfm -init $FLAIR_TO_DWI\
	-out size_dwi -interp nearestneighbour

while read c; do
    id=$(echo $c|cut -d' ' -f1)
    size=$(echo $c|cut -d' ' -f2)

    echo "cluster #: $id"

    fslmaths index_flair -thr $id -uthr $id \
		-bin flair_clusters/cluster_${id}

    gunzip -f flair_clusters/cluster_${id}.nii.gz

    fslmaths index_dwi -thr $id -uthr $id \
		-bin dwi_clusters/cluster_${id}

    gunzip -f dwi_clusters/cluster_${id}.nii.gz 

done <<< "$lines"

matlab -nosplash -nodesktop -r "\
\
files = dir('flair_clusters/*.nii');\
len = length(files);\
for i = 1:len\
	fp = fopen(['cluster_stats/cluster_' num2str(i) '.csv'],'w');\
	mask = readnifti(['flair_clusters/cluster_' num2str(i) '.nii']);\
	stats = regionprops3(mask,['all']);\
	vol = stats.Volume;\
	sa = stats.SurfaceArea;\
	sp = ((pi^(1/3))*(6*vol)^(2/3))/sa;\
	axis = sort(stats.PrincipalAxisLength);\
	br = (axis(3)/axis(1));\
	ec = sqrt(1-((axis(1)*axis(2))/axis(3)^2));\
	fprintf(fp,'%f,%f,%f,%f,%f',vol,sa,sp,br,ec);\
	fclose(fp);\
end
"</dev/null
#	fprintf(fp,'Vol,SA,SP,BR,EC\\n');\

module unload matlab/R2018a

cd $SUBJECT_DIR
