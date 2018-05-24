CreateRoi('dti.nii','brain_mask.nii','NODDI_roi.mat')

protocol = FSL2Protocol('bvals','bvecs')

noddi = MakeModel('WatsonSHStickTortIsoV_B0')

batch_fitting('NODDI_roi.mat',protocol,noddi,'FittedParams.mat',4)

SaveParamsAsNIfTI('FittedParams.mat','NODDI_roi.mat','brain_mask.nii','noddi')
