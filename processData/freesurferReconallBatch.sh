#!/bin/bash
# Import Data for processing in Freesurfer (v6.0.0)
# Daniel Elbich
# Lab of Developmental Neuroscience (in conjuntion with Brain & Behavior Lab)
# The Pennsylvania State University
# 4/25/17
#
#
# Short script to batch preprocess/organize structural MRI data for processing through Freesurfer

# List Source Directories
pathtodata=/path/to/subjects

# Declare Subjects
subjs=(A1_001 A1_002 A1_003) #Example Subject IDs

sub=($subjs)

#Extension of MPRAGE
exten=.v2

for (( i=0; i<${#subjs[@]}; i++))
do

# Hard Code List
# As written code would list directory of structural directory "ser2" of subject A1_001 and find 1st image in the series to submit to Freesurfer recon-all function (e.g. ~/A1_001/ser2/sometitlehere12345.v2). Also note extension is .v2 - change to fit dicom extension of your data (e.g. .dcm).

recon-all -i $(ls $pathtodata/${subjs[i]}/ser2/"*"$exten | head -1) -subjid ${subjs[i]}

done


