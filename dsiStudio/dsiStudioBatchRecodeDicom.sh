#!/bin/bash
# Recode DICOMS to squence name with .dcm extension
# Daniel Elbich
# The Pennsylvania State University
# 7/13/17
#
#
# Note!!!: Requires DSI Studio to run. Process will rename files of original data so
# be sure to copy raw data to avoid overwriting.
#

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

/path/to/install/dsi_studio --action=ren --source=/path/to/$subjID/$folderID

done



