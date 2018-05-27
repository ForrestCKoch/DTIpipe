#!/bin/sh

# A little hack to make sure paths are as we expect
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
BASE="$(readlink -f $SCRIPT_DIR/../..)"

SUBJECT_DIR="$(pwd)"
BVECS="$BASE/resources/bvecs"
BVALS="$BASE/resources/bvals"

cd workdir
BASE="$(pwd)"
mkdir -p mrtrix_proc
cd mrtrix_proc
mkdir -p tensor_metrics
mkdir -p QC

# We'll need to create the mif files first
mrconvert -fslgrad "$BVECS" "$BVALS" \
    $BASE/distortion_correction/eddy_corrected.nii.gz dwi.mif 

# generate a mean b0 for visualization
dwiextract dwi.mif - -bzero | mrmath - mean QC/meanb0.mif -axis 3

mrconvert $SUBJECT_DIR/workdir/coregistration/t1_coregistered.nii.gz t1.mif

###############################################################################
# create mask and tensor metrics
###############################################################################
dwi2mask -bvalue_scaling 'no' dwi.mif mask.mif
dwi2tensor -bvalue_scaling 'no' -mask mask.mif dwi.mif tensor.mif
tensor2metric tensor.mif -adc tensor_metrics/adc.mif
tensor2metric tensor.mif -fa  tensor_metrics/fa.mif
tensor2metric tensor.mif -ad  tensor_metrics/ad.mif
tensor2metric tensor.mif -rd  tensor_metrics/rd.mif
tensor2metric tensor.mif -cl  tensor_metrics/cl.mif
tensor2metric tensor.mif -cp  tensor_metrics/cp.mif
tensor2metric tensor.mif -cs  tensor_metrics/cs.mif
tensor2metric tensor.mif -vector tensor_metrics/v1.mif -num 1
tensor2metric tensor.mif -vector tensor_metrics/v2.mif -num 2
tensor2metric tensor.mif -vector tensor_metrics/v3.mif -num 3
tensor2metric tensor.mif -value  tensor_metrics/l1.mif -num 1
tensor2metric tensor.mif -value  tensor_metrics/l2.mif -num 2
tensor2metric tensor.mif -value  tensor_metrics/l3.mif -num 3

###############################################################################
# constrained spherical deconvolution (CSD)
# http://mrtrix.readthedocs.io/en/latest/constrained_spherical_deconvolution/multi_tissue_csd.html
###############################################################################

# generate five-tissue-type stuff
5ttgen fsl t1.mif 5tt.mif
5tt2gmwmi 5tt.mif 5tt_seed.mif

dwi2response msmt_5tt dwi.mif 5tt.mif wm_rf.txt gm_rf.txt csf_rf.txt \
    -voxels voxels_rf.mif

dwi2fod msmt_csd -bvalue_scaling 'no' -mask mask.mif dwi.mif wm_rf.txt \
    wm_fod.mif gm_rf.txt gm_fod.mif csf_rf.txt csf_fod.mif

mrconvert -coord 3 0 wm_fod.mif - | mrcat csf_fod.mif gm_fod.mif - vf.mif
# for visualizing the 5tt
5tt2vis 5tt.mif QC/5tt_vis.mif

# try without t1 image
#dwi2response dhollander dwi.mif dh_wm.txt dh_gm.txt dh_csf.txt -voxels

#dwi2fod msmt_csd -bvalue_scaling 'no' -mask mask.mif dwi.mif dh_wm.txt \
#    dh_wm_fod.mif dh_gm.txt dh_gm_fod.mif dh_csf.txt dh_csf_fod.mif



###############################################################################
# streamline anatomically constrained tractography
# as per HCP
###############################################################################
# http://mrtrix.readthedocs.io/en/latest/quantitative_structural_connectivity/ismrm_hcp_tutorial.html
# trying with wm fod
echo "Running ACT with wm fod"
# NOTE: conflicting options for seeding
        #######################################################
        # -seed_gmwmi image seed from the grey matter white 
        #       matter interface (only valid if using ACT 
        #       framework). Input image should be a 3D seeding 
        #       volume; seeds drawn within this image will be 
        #       optimised to the interface using the 5TT image 
        #       provided using the -act option.
        # -seed_dynamic fod_image determine seed points 
        #       dynamically using the SIFT model (must not 
        #       provide any other seeding mechanism). Note that 
        #       while this seeding mechanism improves the 
        #       distribution of reconstructed streamlines 
        #       density, it should NOT be used as a substitute 
        #       for the SIFT method itself.
        #######################################################
#tckgen -seed_gmwmi 5tt_seed.mif -select 100M -act 5tt.mif -backtrack \
#    -crop_at_gmwmi -bvalue_scaling 'no' -maxlength 250 -cutoff 0.06 \
#    wm_fod.mif 100M_act_5tt_seed.tck 

tckgen -seed_dynamic wm_fod.mif -select 1M -act 5tt.mif -backtrack \
    -crop_at_gmwmi -bvalue_scaling 'no' -maxlength 250 -cutoff 0.06 \
    wm_fod.mif 1M_act_dynamic_seed.tck 

tcksift 1M_act_dynamic_seed.tck wm_fod.mif 100k_sift.tck -act 5tt.mif -term_number 100000

#tckgen -seed_dynamic dh_wm_fod.mif -select 100M -act 5tt.mif -backtrack \
#    -crop_at_gmwmi -bvalue_scaling 'no' -maxlength 250 -cutoff 0.06 \
#    wm_fod.mif 100M_act_dynamic_seed.tck 


###############################################################################
# global tractography
###############################################################################
#echo "Running global tractography on original dwi"
#tckglobal dwi.mif wm_rf.txt -riso csf_rf.txt -riso gm_rf.txt -mask mask.mif \
#    -niter 1e9 -fod fod.mif -fiso fiso.mif global_tracks.tck

cd $SUBJECT_DIR


###############################################################################
# QC notes
###############################################################################
# 
# mrview meanb0.mif -overlay.load RF_voxels.mif -overlay.opacity 0.5
# mrview vf.mif -odf.load_sh wm_fod.mif
