# ##################################################################
# Author:  Dolores Jane Forbes
#
# Date:  03/16/2017
#
# Email:  dolores.j.forbes@census.gov
#
# File: dbf2csv.R
#
# Branch:  Geographic Research & Innovation Staff/Geography
#
# ##################################################################
#
# Read .dbf files and export as .csv files
#
# ##################################################################

# ##################################################################
# load libraries
# ##################################################################

library(rio)

# ##################################################################
# check to see if working directory has already been set
# ##################################################################

# version for telework site (home)
if(!getwd() == "C:/CensusProjs/HUDData/VacantHouses") {
	oldwd = getwd()
	setwd("C:/CensusProjs/HUDData/VacantHouses")
}

# ##################################################################
# list all HUD files
# ##################################################################

if(!exists("filenames")) {

	filenames <- list.files("Shapefiles",pattern="*Data.dbf",
		full.names=TRUE)

}

# ##################################################################
# read each import file and export as .csv file
# ##################################################################

for (i in 1:length(filenames)) {

	x <- import(filenames[i])
	export(x, gsub(" ","",paste(substr(filenames[i], 1, 33),".csv")))
}

# it really was this easy ...



