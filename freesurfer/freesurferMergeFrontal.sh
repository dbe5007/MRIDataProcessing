#!/bin/bash

# Create Frontal Lobe Label in Freesurfer
# Daniel Elbich
# The Pennsylvania State University
# 4/25/17
#
#
# Merges seperate labels derived from Freesurfer into a single frontal lobe
# region and pulls statistics from new region. Requires Freesurfer to be
# added to the path
#

# List Source Directories
pathtodata=/path/to/data/here

#Subject List - list subject IDs with space after each
#subjs=(AA_123 BB_123 CC_123)
subjs=()

sub=($subjs)

for (( i=0; i<${#subjs[@]}; i++))
do

# Displays current subject ID in terminal window
echo ${subjs[i]}

# Hard Code List
cd $pathtodata/${subjs[i]}/label

# Export annotation file to separate label files
mri_annotation2label --subject ${subjs[i]} --hemi rh --outdir $pathtodata/${subjs[i]}/label
mri_annotation2label --subject ${subjs[i]} --hemi lh --outdir $pathtodata/${subjs[i]}/label

# Merge right and left hemipshere regions (separately) into single region
mri_mergelabels -i rh.frontalpole.label -i rh.lateralorbitofrontal.label -i rh.medialorbitofrontal.label -i rh.paracentral.label -i rh.parsopercularis.label -i rh.parsorbitalis.label -i rh.parstriangularis.label -i rh.precentral.label -i rh.rostralanteriorcingulate.label -i rh.rostralmiddlefrontal.label -i rh.superiorfrontal.label -o rh.allFrontal.label

mri_mergelabels -i lh.frontalpole.label -i lh.lateralorbitofrontal.label -i lh.medialorbitofrontal.label -i lh.paracentral.label -i lh.parsopercularis.label -i lh.parsorbitalis.label -i lh.parstriangularis.label -i lh.precentral.label -i lh.rostralanteriorcingulate.label -i lh.rostralmiddlefrontal.label -i lh.superiorfrontal.label -o lh.allFrontal.label

# Export statistics from region to output directory
mris_anatomical_stats -f /path/to/output/${subjs[i]}.rh.stats.txt -l rh.allFrontal.label ${subjs[i]} rh
mris_anatomical_stats -f /path/to/output/${subjs[i]}.rh.stats.txt -l lh.allFrontal.label ${subjs[i]} lh

done


