#!/bin/bash

####Notes & Comments####
help() {
echo ""
echo "Create Frontal Lobe Label in Freesurfer"
echo "Daniel Elbich"
echo "The Pennsylvania State University"
echo "Created: 4/25/17"
echo ""
echo ""
echo " Merges seperate labels derived from Freesurfer into a single frontal lobe"
echo " region and pulls statistics from new region. Requires Freesurfer to be"
echo " added to the path."
echo ""
echo ""
echo "Usage:"
echo "freesurferMergeFrontal.sh --subjList <subjectIDs>"
echo ""
echo " Required arguments:"
echo ""
echo "      --subjList      Single subject ID or text file containing list of subject IDs"
echo ""
exit 1
}
[ "$1" = "--help" ] && help

## Argument check ##
POSITIONAL=()
while [[ $# -gt 0 ]]
do
key="$1"

case $key in

--subjList) subjList="$2"
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

## Read Subject IDs ##
if [[ -f $subjList ]]; then
	i=0
	while read -r LINE || [[ -n $LINE ]]; do
		subs[i]=$LINE
		let "i++"
	done < $subjList
else
	subs=$subjList
fi

## Statistics output path ##
statsPath=/path/to/stats/output/

for (( i=0; i<${#subs[@]}; i++))
do

## Displays current subject in terminal window ##
echo ${subjs[i]}
cd $SUBJECTS_DIR/${subs[i]}/label

## Export annotation file to separate label files ##
mri_annotation2label --subject ${subs[i]} --hemi rh --outdir $SUBJECTS_DIR/${subs[i]}/label
mri_annotation2label --subject ${subs[i]} --hemi lh --outdir $SUBJECTS_DIR/${subs[i]}/label

## Merge right and left hemipshere regions (separately) into single region ##
mri_mergelabels -i rh.frontalpole.label -i rh.lateralorbitofrontal.label -i rh.medialorbitofrontal.label -i rh.paracentral.label -i rh.parsopercularis.label -i rh.parsorbitalis.label -i rh.parstriangularis.label -i rh.precentral.label -i rh.rostralanteriorcingulate.label -i rh.rostralmiddlefrontal.label -i rh.superiorfrontal.label -o rh.allFrontal.label

mri_mergelabels -i lh.frontalpole.label -i lh.lateralorbitofrontal.label -i lh.medialorbitofrontal.label -i lh.paracentral.label -i lh.parsopercularis.label -i lh.parsorbitalis.label -i lh.parstriangularis.label -i lh.precentral.label -i lh.rostralanteriorcingulate.label -i lh.rostralmiddlefrontal.label -i lh.superiorfrontal.label -o lh.allFrontal.label

## Export statistics from region to output directory ##
mris_anatomical_stats -f $statsPath/${subs[i]}.rh.stats.txt -l rh.allFrontal.label ${subs[i]} rh
mris_anatomical_stats -f $statsPath/${subs[i]}.rh.stats.txt -l lh.allFrontal.label ${subs[i]} lh

done


