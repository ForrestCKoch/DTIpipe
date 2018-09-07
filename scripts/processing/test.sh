#!/bin/sh

matlab -nosplash -nodesktop -r "\
fp = fopen('${1}.txt','w');\
mask = readnifti('$1');\
stats = regionprops3(mask,{'Volume' 'SurfaceArea'});\
sphericity = ((pi^(1/3))*(6*stats.Volume)^(2/3))/stats.SurfaceArea;\
fprintf(fp,'%f,%f,%f',stats.Volume,stats.SurfaceArea,sphericity);\
fp.close();\
"</dev/null

module unload matlab/R2018a
