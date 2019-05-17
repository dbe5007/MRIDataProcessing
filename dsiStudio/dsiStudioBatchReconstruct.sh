#!/bin/bash

####Notes & Comments####
help() {
echo ""
echo "Reconstruct source to fiber images"
echo "Daniel Elbich"
echo "Created: 2/26/19"
echo ""
echo ""
echo "Usage:"
echo "sh dsiStudioBatchReconstruct.sh --subj <text> --method <number>"
echo ""
echo " Required arguments:"
echo ""
echo "        --subj            Path to subject data"
echo "        --method          Type of reconstruction (0:DSI, 1:DTI, 2:Funk-Randon QBI, 3:Spherical Harmonic QBI, 4:GQI 6: Convert to HARDI 7:QSDR)"
echo ""
echo ""
exit 1
}
[ "$1" = "--help" ] && help


#Argument check
POSITIONAL=()
while [[ $# -gt 0 ]]
do
key="$1"

case $key in

--subj) subj="$2"
shift # past argument
shift # past value
;;
--method) method="$2"
shift # past argument
shift # past value
;;
*)    # unknown option
POSITIONAL+=("$1") # save it in an array for later
shift # past argument
;;
esac
done
set -- "${POSITIONAL[@]}" # restore positional parameters


cd $subj

## List all src.gz files ##
subs=$(ls *.src.gz)

## Reconstruction Parameters ##
#method=7          # 0:DSI, 1:DTI, 2:Funk-Randon QBI, 3:Spherical Harmonic QBI, 4:GQI 6: Convert to HARDI 7:QSDR


case "$method" in

1) output_dif="1"            # For DTI. Output Diffusivity
   output_tensor="1"         # Output tensor
   motion_correction="1";;   # Correct for motion

4) param0="1.25"             # For GQI
   record_odf="1";;          # Record ODF for Connectometry

7) param0="1.25"             # For QSDR
   voxel_res="2"             # 2mm voxels
   thread="16"               # Use multiple threads
   record_odf="1"            # Record ODF for Connectometry
   output_mapping="1"        # Output mapping for each voxel
   output_jac="1";;          # Output jacobian determinant

## DSI Studio install path ##
dsiPath=/path/to/dsiStudio/install

for sub in $subs
do

case "$method" in

#DTI Reconstruction
1) $dsiPath/dsi_studio --action=rec --thread=${thread} --source=${sub} --method=${method} --motion_correction=${motion_correction} --output_dif=${output_dif} --output_tensor=${output_tensor};;

#GQI Reconstruction
4) $dsiPath/dsi_studio --action=rec --thread=${thread} --source=${sub} --method=${method} --param0=${param0} --param1=${voxel_res} --record_odf=${record_odf} --reg_method=4;;

#QSDR Reconstruction
7) $dsiPath/dsi_studio --action=rec --thread=${thread} --source=${sub} --method=${method} --param0=${param0} --param1=${voxel_res} --output_jac=${output_jac} --output_mapping=${output_mapping} --record_odf=${record_odf} --reg_method=4;;


done

