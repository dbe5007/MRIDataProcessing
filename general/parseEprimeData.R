#!/usr/bin/env Rscript
## Parse E-Prime File
#  Daniel Elbich
#  7/3/18
#
#  Script to parse E-Prime backup text file and output to readable CSV. Script
#  can be called from the command line on Linux/Macos system

#library(rprime)
#library(matlabr)

#For Rscript calling
args <- commandArgs(trailingOnly=TRUE)

.packages <- c("rprime", "svDialogs", "matlabr")
new.packages <- .packages[!(.packages %in% installed.packages()[,"Package"])]
if(length(new.packages)) install.packages(new.packages, dep=T)
quietly <- lapply(.packages, require, character.only=TRUE)

if (length(args)!=0){
	
	#Debug
	print(args[1])
	print(args[2])

	folder <- args[1]
	folder=gsub("\\"," ",folder,fixed=TRUE)
	print(folder)
	setwd(folder)
	
} else {
	
	#User interface to go to data folder
	if (require(svDialogs)) {
		setwd(dlgDir(default = getwd())$res)
	} else {
		folder <- readline(prompt="Enter path: ")
		setwd(folder)
	}
	
	returndir=getwd()
	
}

#Dumps all found text files into character array
datafiles=list.files(path = ".", pattern = ".txt")

#Create Data Frame
finaldata=data.frame("Subject ID")

for (file in datafiles) {
	experiment_lines <- read_eprime(file)
	experiment_data <- FrameList(experiment_lines)
	
	export_data <- to_data_frame(experiment_data)
	filename=substr(file, nchar(file)-nchar(file), nchar(file)-4)
	
	outputname=paste(filename,".csv", sep = "")
	
	write.csv(export_data, outputname)
	
	#Write clean version - delete unneeded columns of information
	export_data = subset(export_data,select = -c(Eprime.FrameNumber,Eprime.Level,Eprime.LevelName,Eprime.Basename,Running,VersionPersist,LevelName,Experiment,SessionDate,SessionStartDateTimeUtc,Session,SessionTime,DataFile.Basename,RandomSeed,Group,Display.RefreshRate,StudioVersion,RuntimeVersion,RuntimeVersionExpected,RuntimeCapabilities,ExperimentVersion))
	
	outputname=paste(filename,"_Cleaned.csv", sep = "")
	
	write.csv(export_data, outputname)
	
	rm(experiment_lines,experiment_data,export_data,filename,outputname)

}

tryCatch(system("mkdir output_csv"))
system("mv *.csv output_csv")
