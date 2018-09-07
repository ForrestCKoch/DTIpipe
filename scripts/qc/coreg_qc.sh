#/bin/sh

# A little hack to make sure paths are as we expect
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
BASE="$DTIPIPE"

START="$(pwd)"

mkdir -p ../QC/B0_to_T1_coreg

for i in *; do
	echo "Preparing $i ..."
	b0=$i/workdir/coregistration/epi_reg	
	wmseg=$i/workdir/coregistration/wmseg
	overlay 1 1 $b0 -A $wmseg 1 1 ../QC/B0_to_T1_coreg/$i
done

cd ../QC/B0_to_T1_coreg
echo "Calling slicesdir ..."
slicesdir *

cd $START


