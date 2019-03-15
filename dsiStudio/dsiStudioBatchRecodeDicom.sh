#!/bin/bash

####Notes & Comments####
help() {
echo ""
echo "Recode DICOMS to squence name with .dcm extension"
echo "Daniel Elbich"
echo "The Pennsylvania State University"
echo "Created: 7/13/17"
echo ""
echo ""
echo " Batch rename DICOM files for set of subjects. Copys raw data folder and"
echo " and renames copied files instead of altering original raw data folder."
echo ""
echo "Usage:"
echo "sh dsiStudioBatchRecodeDicom.sh"
echo ""
echo ""
exit 1
}
[ "$1" = "--help" ] && help


#Subject List - list subject IDs with hard return after each
#subjlist=(AA_123
#BB_123
#CC_123)
subjlist=()

#Folder List - list folder containing DICOMS with hard return after each
#folderlist=(ser5_dcm
#ser5_dcm
#ser6_dcm)
folderlist=()

lngthsubj=${#subjlist[@]}
lngthfolder==${#folderlist[@]}

for (( i=0; i<${lngthsubj}; i++ ));
do

subjID=${subjlist[$i]}
folderID=${folderlist[$i]}

cp /path/to/$subjID/$folderID /path/to/$subjID/$folderID"_dsi_renamed"

/path/to/install/dsi_studio --action=ren --source=/path/to/$subjID/$folderID"_dsi_renamed"

done



