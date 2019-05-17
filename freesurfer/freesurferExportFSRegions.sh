#!/bin/bash

####Notes & Comments####
help() {
echo ""
echo "Convert Freesurfer labels & subcortical segmentations to NiFTi"
echo "Daniel Elbich"
echo "Cogntive, Aging, and Neurogimaging Lab"
echo "Created: 4/2/19"
echo ""
echo ""
echo " Exports Freesurfer cortical labels and subcortical segmentation into NiFTi files"
echo " for use in other MR analysis programs (e.g. FSL, SPM). Requires Freesurfer and"
echo " FSL be installed."
echo ""
echo ""
echo "Usage:"
echo "sh freesurferExportFSRegions.sh --subjList <subjectIDs>"
echo ""
echo " Required arguments:"
echo ""
echo "      --subjList      Single subject ID or text file containing list of subject IDs"
echo ""
echo " Optional arguments (You may optionally specify one or more of): "
echo ""
echo "	    --fsSubjDir     Freesurfer subjects directory (change if you do not"
echo "                          to use the default setup from sourcing Freesurfer)"
echo ""
echo ""
exit 1
}
[ "$1" = "--help" ] && help

#Arguement check
POSITIONAL=()
while [[ $# -gt 0 ]]
do
key="$1"

case $key in

--subjList) subjList="$2"
shift # past argument
shift # past value
;;
--fsSubjDir) fsSubjDir="$2"
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

###Read Subject IDs###
if [[ -f $subjList ]]; then
	i=0
	while read -r LINE || [[ -n $LINE ]]; do
		subs[i]=$LINE
		let "i++"
	done < $subjList
else
	subs=$subjList
fi

##Load in freesurfer and fsl - FOR SERVER USE ONLY!!!##
module load fsl
module load freesurfer
source /opt/aci/sw/freesurfer/6.0.0/SetUpFreeSurfer.sh

#Setup freesurfer subject directory##
if [ -z ${fsSubjDir+x} ]
then
	echo "Using default subjects directory..."
else
	export SUBJECTS_DIR=$fsSubjDir
fi
echo "Subjects directory is: " $SUBJECTS_DIR

##Color LUTs for Aseg parcellation - refer to freesurfer webpage##
#https://surfer.nmr.mgh.harvard.edu/fswiki/FsTutorial/AnatomicalROI/FreeSurferColorLUT#
#Includes subcortical regions excluding all ventricles#
colorCode=(9 11 12 13 17 18 19 26 27 48 50 51 52 53 54 55 58 59)
colorName=('lh_Thalamus' 'lh_Caudate' 'lh_Putamen' 'lh_Pallidum' 'lh_Hippocampus' 'lh_Amygdala' 'lh_Insula' 'lh_Accumbens' 'lh_Substancia' 'rh_Thalamus' 'rh_Caudate' 'rh_Putamen' 'rh_Pallidum' 'rh_Hippocampus' 'rh_Amygdala' 'rh_Insula' 'rh_Accumbens' 'rh_Substancia')

##Change to project directory and get subject list
cd $SUBJECTS_DIR
#subs=(*)

##Loop for all subjects##
for ((i=0; i<${#subs[@]}; i++))
do

sub=${subs[i]}

##Split label file into individual labels for both hemispheres##
mri_annotation2label --subject $sub --hemi rh --outdir $SUBJECTS_DIR/$sub/labelSplit
mri_annotation2label --subject $sub --hemi lh --outdir $SUBJECTS_DIR/$sub/labelSplit

##Get list of labels and make output directory for conversion##
mkdir $SUBJECTS_DIR/$sub/labelSplit/nii
labels=($SUBJECTS_DIR/$sub/labelSplit/*.label)

##Extraneous text to remove##
prefix=$SUBJECTS_DIR/$sub/labelSplit/
suffix=.label

##Loop for all labels##
for ((ii=0; ii<${#labels[@]}; ii++))
do

label=${labels[ii]}

##Mark which hemisphere reference to use##
if [[ $label == *"rh."* ]]
then
	hemisphere='rh'
else
	hemisphere='lh'
fi

##Remove prefix path and suffix label extensions##
label=${label#"$prefix"}
label=${label%"$suffix"}
label=${label#"$hemisphere."}

##Fit labels to original MPRAGE input into freesurfer##
mri_label2vol --label ${labels[ii]} --temp $SUBJECTS_DIR/$sub/mri/orig/001.mgz --identity --subject $sub --hemi $hemisphere --proj frac 0 1 .1 --fillthresh .3 --o $SUBJECTS_DIR/$sub/labelSplit/nii/$hemisphere'_'$label'.nii'

done

##Split aseg file into labgels and convert labels to nii##
#Fit aseg to subject space space and convert to nii#
mri_label2vol --seg $sub/mri/aseg.mgz --identity --temp $sub/mri/orig/001.mgz --o $sub/mri/aseg.nii

#Loop to convert all areas of interest to nii#
for ((ii=0; ii<${#colorCode[@]}; ii++))
do

if [ "$ii" -le 8 ]
then
	hemisphere='lh'
else
	hemisphere='rh'
fi

##Extraneous text to remove##
region=${colorName[ii]#"$hemisphere"}
region=${region#"_"}

##Thresholds map to specific color value and saves as nifti###
fslmaths $SUBJECTS_DIR/$sub/mri/aseg.nii -uthr ${colorCode[ii]} -thr ${colorCode[ii]} $SUBJECTS_DIR/$sub/labelSplit/nii/$hemisphere'_'$region'.nii.gz'

##Binarizes voxels using color value##
fslmaths $SUBJECTS_DIR/$sub/labelSplit/nii/$hemisphere'_'$region'.nii.gz' -div ${colorCode[ii]} $SUBJECTS_DIR/$sub/labelSplit/nii/$hemisphere'_'$region'.nii.gz'

done

done
