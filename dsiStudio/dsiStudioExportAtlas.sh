#!/bin/bash

####Notes & Comments####
help() {
echo ""
echo "Export Diffusion Metrics (FA, MD, RD, AD) from src.gz files"
echo "Daniel Elbich"
echo "The Pennsylvania State University"
echo "7/15/17"
echo ""
echo ""
echo "Note: Assumes all fiber tracks (*.fib.gz extension) are in single file"
echo ""
echo "Usage:"
echo "sh dsiStudioExportAtlas.sh --subj <text>"
echo ""
echo " Required arguments:"
echo ""
echo "        --subj            Subject ID"
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
*)    # unknown option
POSITIONAL+=("$1") # save it in an array for later
shift # past argument
;;
esac
done
set -- "${POSITIONAL[@]}" # restore positional parameters

# Change directory
cd /path/to/$subj/data

# List all fib.gz files
subs=$(ls *.fib.gz)

#Example atlas name - see DSI Studio install for complete list of available atlases
atlas="aal"

for sub in $subs
do

/path/to/install/dsi_studio --action=exp --source=${sub} --atlas=${atlas} --export=${sub}"_"${atlas}"_stats"


echo
done




