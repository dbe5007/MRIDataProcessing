#!/bin/bash
# FSL Diffusion Preprocessing
# Daniel Elbich
# Lab of Developmental Neuroscience (in conjuntion with Brain & Behavior Lab)
# The Pennsylvania State University
# 7/13/17
#
#
# Short script for conducting standard preprocessing of diffusion data in FSL with organization for TBSS analysis
# Note: Code relies on uniform naming of diffusion files. Variable file naming ability will be coming in further versions. Primary functions rely on FSL being installed. Refer to their help documentation for specific function errors

# List Source Directories
pathtodata=~/path/to/subjects
pathtooutput=~/path/to/output

# Declare Subjects
subjs=(A1_001 A1_002 A1_003) #Example Subject IDs
sub=($subjs)

# Create separate folders for FA, AD, RD, and MD metrics
mkdir $pathtooutput/Output_FA
mkdir $pathtooutput/Output_AD
mkdir $pathtooutput/Output_RD
mkdir $pathtooutput/Output_MD

for (( i=0; i<${#subjs[@]}; i++))
do

# Create subject specific folder for processing data
mkdir $pathtooutput/${subjs[i]}

# Copy Data to Other Location
cp $pathtodata/${subjs[i]}/nii/ep2ddiffabc123.nii $pathtooutput/${subjs[i]}
cp $pathtodata/${subjs[i]}/nii/ep2ddiffabc123.bval $pathtooutput/${subjs[i]}
cp $pathtodata/${subjs[i]}/nii/ep2ddiffabc123.bvec $pathtooutput/${subjs[i]}

# Rename to Subject ID
mv $pathtooutput/${subjs[i]}/ep2ddiffabc123.nii $pathtooutput/${subjs[i]}/${subjs[i]}_raw.nii
mv $pathtooutput/${subjs[i]}/ep2ddiffabc123.bval $pathtooutput/${subjs[i]}/${subjs[i]}.bval
mv $pathtooutput/${subjs[i]}/ep2ddiffabc123.bvec $pathtooutput/${subjs[i]}/${subjs[i]}.bvec

#If multiple b0 (uncomment to run) - update values to reflect number of b0 images in diffusion sequence
#fslsplit $pathtooutput/${subjs[i]}/${subjs[i]}_raw.nii
#fslmaths $pathtooutput/${subjs[i]}/vol0000.nii.gz -add vol00##.nii.gz $pathtooutput/${subjs[i]}/sumb0.nii.gz
#fslmaths $pathtooutput/${subjs[i]}/sumb0.nii.gz -div 2 $pathtooutput/${subjs[i]}/avgb0.nii.gz
#rm $pathtooutput/${subjs[i]}/vol0000.nii.gz
#fslmerge -a $pathtooutput/${subjs[i]}/${subjs[i]}.nii $pathtooutput/${subjs[i]}/avgb0.nii.gz vol00*

#If only 1 b0 (uncomment to run) - Default
mv $pathtooutput/${subjs[i]}/${subjs[i]}_raw.nii $pathtooutput/${subjs[i]}/${subjs[i]}.nii

#Correct for Eddy Current Distortions
eddy_correct $pathtooutput/${subjs[i]}/${subjs[i]}.nii $pathtooutput/${subjs[i]}/${subjs[i]}_data.nii 0

#Brain Extraction Tool (BET)
bet $pathtooutput/${subjs[i]}/${subjs[i]}_data.nii $pathtooutput/${subjs[i]}/${subjs[i]}_brain.nii -f 0.2 -g 0 -m

#Export Diffusion Maps (FA, AD, RD, MD)
dtifit -k $pathtooutput/${subjs[i]}/${subjs[i]}_data.nii -o $pathtooutput/${subjs[i]}/${subjs[i]}_DTI -m $pathtooutput/${subjs[i]}/${subjs[i]}_brain_mask.nii -r $pathtooutput/${subjs[i]}/${subjs[i]}.bvec -b $pathtooutput/${subjs[i]}/${subjs[i]}.bval

#Copy Files to Directory for TBSS
cp $pathtooutput/${subjs[i]}/${subjs[i]}_DTI_FA.nii.gz $pathtooutput/Output_FA
cp $pathtooutput/${subjs[i]}/${subjs[i]}_DTI_L1.nii.gz $pathtooutput/Output_AD
cp $pathtooutput/${subjs[i]}/${subjs[i]}_DTI_MD.nii.gz $pathtooutput/Output_MD
cp $pathtooutput/${subjs[i]}/${subjs[i]}_DTI_L2.nii.gz $pathtooutput/Output_RD

#Rename AD & RD to Keep Track
mv $pathtooutput/AD/${subjs[i]}_DTI_L1.nii.gz $pathtooutput/AD/${subjs[i]}_DTI_AD.nii.gz
mv $pathtooutput/RD/${subjs[i]}_DTI_L2.nii.gz $pathtooutput/AD/${subjs[i]}_DTI_RD.nii.gz

done



