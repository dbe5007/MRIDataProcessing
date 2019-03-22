#!/bin/sh

####Notes & Comments####
help() {
echo ""
echo "Create PBS Scripts"
echo "Daniel Elbich"
echo "Cogntive, Aging, and Neurogimaging Lab"
echo "Created: 3/12/19"
echo ""
echo ""
echo " Creates subject specific PBS job files to submit to batch processing."
echo ""
echo ""
echo "Usage:"
echo "sh createPBSScripts.sh --subjList <textfile> --run"
echo ""
echo " Required arguments:"
echo ""
echo "	    --subjList      Text file containing list of subjects to run (include path to file)"
echo ""
echo " Optional arguments (You may optionally specify one or more of): "
echo ""
echo "      --run   	    Submit PBS job to qsub"
echo ""
echo ""
exit 1
}
[ "$1" = "--help" ] && help

#subs=()
#Arguement check
POSITIONAL=()
while [[ $# -gt 0 ]]
do
key="$1"

case $key in
--subjList) subjList="$2"
i=0
while read -r LINE || [[ -n $LINE ]]; do
	subs[i]=$LINE
	let "i++"
done < $subjList
shift # past argument
shift # past value
;;
--run) run=1
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

#####OTHER PBS FLAGS#####
#Delayed qsub submission line - military time
#PBS -a 2200

for sub in ${subs[@]}; do

##Save pbs text file to directory""
FILE='/path/to/folder/PBS_file.txt'

/bin/cat <<EOM >$FILE
#PBS -A ALLOCATION HERE
#PBS -l nodes=1:ppn=1
#PBS -l walltime=36:00:00
#PBS -l pmem=8gb
#PBS -j oe
#PBS -mae
#PBS -M YOUR EMAIL ADDRESS FOR STATUS ALERTS

Start code after last #PBS line

<Body here>

End code before EOM

EOM

##Optional flag will automatically submit job
if [ -z "$run" ]
then
	echo "PBS job file created. Saving to: "$FILE
else
	echo "PBS job file created. Saving to: "$FILE
	echo "Submitting job..."
	qsub $FILE
fi
done
