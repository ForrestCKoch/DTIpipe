#!/bin/bash

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
BASE="$(readlink -f $SCRIPT_DIR/../..)"

SUBJECT_DIR="$(pwd)"

# we should alter this to ultimately use original space possibly?
WMH_MASK="$SUBJECT_DIR/workdir/wmh_vs_nawm/wmh_mask_flair_space"
FLAIR_TO_DWI="$SUBJECT_DIR/workdir/wmh_vs_nawm/flair_to_dwi.mat"

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
flirt -in index_flair -ref $SUBJECT_DIR/dti -applyxfm -init $FLAIR_TO_DWI\
	-out index_dwi -interp nearestneighbour
flirt -in size_flair -ref $SUBJECT_DIR/dti -applyxfm -init $FLAIR_TO_DWI\
	-out size_dwi -interp nearestneighbour

while read c; do
    id=$(echo $c|cut -d' ' -f1)
    size=$(echo $c|cut -d' ' -f2)

    echo "cluster #: $id"

    fslmaths index_flair -thr $id -uthr $id \
		-bin flair_clusters/cluster_${id}

    gunzip flair_clusters/cluster_${id}.nii.gz

    fslmaths index_dwi -thr $id -uthr $id \
		-bin dwi_clusters/cluster_${id}

    gunzip dwi_clusters/cluster_${id}.nii.gz


done <<< "$lines"

    # this is time consuming, so include it in prep stage
#    matlab -nosplash -nodesktop -r "\
#    fp = fopen('cluster_${id}_props.txt','w');\
#    mask = readnifti('cluster_${id}_${size}.nii');\
#    stats = regionprops3(mask,{'Volume' 'SurfaceArea'});\
#    v = stats.Volume;\
#    s = stats.SurfaceArea;\
#    sphericity = ((pi^(1/3))*(6*stats.Volume)^(2/3))/stats.SurfaceArea;\
#    fprintf(fp,'%f,%f,%f',stats.Volume,stats.SurfaceArea,sphericity);\
#    fp.close();\
#    "</dev/null > /dev/null 2>&1

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

cd $SUBJECT_DIR
