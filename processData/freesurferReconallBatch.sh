#!/bin/bash

####Notes & Comments####
howtouse() {
echo ""
echo "Import data for processing in Freesurfer (v6.0.0)"
echo "Daniel Elbich"
echo "Created: 4/25/17"
echo ""
echo " Short script to batch preprocess/organize structural MRI data for processing through Freesurfer."
echo ""
echo "Usage:"
echo "freesurferReconallBatch.sh --subjIDs <text or text file> --exten <text>"
echo ""
echo "Required arguments:"
echo ""
echo "      --subjIDs      Text file or list of subject IDs"
echo "      --exten        Extension of MPRAGE files (e.g., .v2, .dcm, .nii)"
echo ""
exit 1
}
[ "$1" = "--help" ] && howtouse

#Arguement check
POSITIONAL=()
while [[ $# -gt 0 ]]
do
key="$1"

case $key in
--subjIDs) subjList="$2" # Declare Subjects
if [[ $subjList == *".txt" ]]; then
	i=0
	while read -r LINE || [[ -n $LINE ]]; do
		echo $LINE
		subjs[i]=$LINE
		let "i++"
	done <$subjList
else	
	i=$#
	end[0]=$((i-1))
	end[1]=$((i-2))
	a=0
	ii=0
	for sub in $@; do
	if [ $ii == 0 ]; then
		let "ii++"
	elif [ $ii == ${end[0]} ]; then
		let "ii++"		
	elif [ $ii == ${end[1]} ]; then
		let "ii++"		
	else
		subjs[$a]=$sub
		let "a++"
		let "ii++"
	fi

	done

fi

shift # past argument
shift # past value
;;
--exten) exten="$2" # Extension of MPRAGE
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


# List Source Directories
#pathtodata=/path/to/subjects

#for (( i=0; i<${#subjs[@]}; i++))
#do

# Hard Code List
# As written code would list directory of structural directory "ser2" of subject A1_001 and find 1st image in the series to submit to Freesurfer recon-all function (e.g. ~/A1_001/ser2/sometitlehere12345.v2). Also note extension is .v2 - change to fit dicom extension of your data (e.g. .dcm).

#recon-all -i $(ls $pathtodata/${subjs[i]}/ser2/"*"$exten | head -1) -subjid ${subjs[i]}

#done


