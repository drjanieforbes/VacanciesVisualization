# ##################################################################
# Author:  Dolores Jane Forbes
#
# Date:  03/10/2017
#
# Email:  dolores.j.forbes@census.gov
#
# File: PlotVacantVsTotalUnits.R Version 2
#
# Branch:  Geographic Research & Innovation Staff/Geography
#
# ##################################################################
#
# This script sums individual census tract values at multiple 
# scales, including county, state, and nation
#
# ##################################################################
#
# Modules:
# 
# 1)  Checks/sets the working directory
# 2)  Gets a list of all HUD table file names using "*Data.dbf"
# 3)  Read and store all the HUD table files as a list of lists
# 4)  Remove unwanted columns from the HUD table files
# 5)  Process reformatted data to summarize values at multiple scales
#
# These files are all in the form of a census tract equal to a case,
# with the variables as columns
#
# ##################################################################


# ##################################################################
# load libraries
# ##################################################################

library(foreign)
library(tidyverse)

# ##################################################################
# environment settings
# ##################################################################

options(scipen=999)

# ##################################################################
# check to see if working directory has already been set
# ##################################################################

# version for on site work

# set working directory here

# ##################################################################
# list all HUD files
# ##################################################################

filenames <- list.files("Shapefiles",pattern="*Data.dbf",
		full.names=TRUE)

# ##################################################################
# check to see if ldf has already been created
# ##################################################################

# this uploads all available HUD files and stores them in memory
# for further processing

if (!exists("ldf")) {

	# read and store all the dbf files into a list of lists
	# each dbf file can be indexed as ldf[[1]] or ldf[[2]], etc.
	ldf = lapply(filenames, read.dbf, as.is=FALSE)

	# store the descriptive statistics summaries for all the dbf files
	res <- lapply(ldf, summary)

	# extract file names (ignoring the path)
	# names(res) <- substr(filenames, 11, 45)	# the start/stop values will chg
}

# ##################################################################
# pull out all the desired values
# ##################################################################

my.df <- data.frame(matrix(ncol = 11, nrow = 0))

colnames(my.df) <- c("geoid",
                     "quarter",
                     "year",
                     "ams_res",
                     "res_vac",
                     "vac_3_res",
                     "vac_3_6_res",
                     "vac_6_12_res",
                     "vac_12_24_res",
                     "vac_24_36_res",
                     "vac_36_res")

my.geoid <- as.character()
my.quarter <- as.character()
my.year <- as.character()
my.ams_res <- as.integer()
my.res_vac <- as.integer()
my.vac_3_res <- as.integer()
my.vac_3_6_res <- as.integer()
my.vac_6_12_res <- as.integer()
my.vac_12_24_res <- as.integer()
my.vac_24_36_res <- as.integer()
my.vac_36_res <- as.integer()

for (i in 1:length(ldf)) {

	for (j in 1:length(ldf[[i]][,1])) {
		my.geoid <- c(my.geoid, as.character(ldf[[i]][j,1]))
		my.quarter <- c(my.quarter, as.character(ldf[[i]][j,70]))
		my.year <- c(my.year, as.character(ldf[[i]][j,71]))
		my.ams_res <- c(my.ams_res, ldf[[i]][j,10])
		my.res_vac <- c(my.res_vac, ldf[[i]][j,13])
		my.vac_3_res <- c(my.vac_3_res, ldf[[i]][j,19])
		my.vac_3_6_res <- c(my.vac_3_6_res, ldf[[i]][j,22])
		my.vac_6_12_res <- c(my.vac_6_12_res, ldf[[i]][j,25])
		my.vac_12_24_res <- c(my.vac_12_24_res, ldf[[i]][j,28])
		my.vac_24_36_res <- c(my.vac_24_36_res, ldf[[i]][j,31])
		my.vac_36_res <- c(my.vac_36_res, ldf[[i]][j,34])
	}

	# here is where the switch to a new i occurs
	my.df <- data_frame(geoid = my.geoid,
               quarter = my.quarter,
               year = my.year, 
               ams_res = my.ams_res, 
               res_vac = my.res_vac,
               vac_3_res = my.vac_3_res,
               vac_3_6_res = my.vac_3_6_res,
               vac_6_12_res = my.vac_6_12_res,
               vac_12_24_res = my.vac_12_24_res,
               vac_24_36_res = my.vac_24_36_res,
               vac_36_res = my.vac_36_res)

	# build the filename using i
	outfile <- gsub(" ","",paste("HUD/",ldf[[i]]$month[1],"-",ldf[[i]]$year[1],"_values",".csv"))

	# write the file out
	print("Writing output csv file VALUES")
	write.csv(my.df, outfile)
	print("File is complete")

	# reset my.df
	my.df <- NULL
  
	# recreate empty my.df
	my.df <- data.frame(matrix(ncol = 11, nrow = 0))

	colnames(my.df) <- c("geoid",
               	     "quarter",
                       "year",
                       "ams_res",
                       "res_vac",
                       "vac_3_res",
                       "vac_3_6_res",
                       "vac_6_12_res",
                       "vac_12_24_res",
                       "vac_24_36_res",
                       "vac_36_res")

	# reset the vectors
	my.geoid <- as.character()
	my.quarter <- as.character()
	my.year <- as.character()
	my.ams_res <- as.integer()
	my.res_vac <- as.integer()
	my.vac_3_res <- as.integer()
	my.vac_3_6_res <- as.integer()
	my.vac_6_12_res <- as.integer()
	my.vac_12_24_res <- as.integer()
	my.vac_24_36_res <- as.integer()
	my.vac_36_res <- as.integer()

}

# remove ldf from memory
rm("ldf")

# ##################################################################
# list all "values" files
# ##################################################################

valuefiles <- list.files("HUD",pattern="*_values.csv",full.names=TRUE)

my.value.ldf = lapply(valuefiles, read.csv, as.is=FALSE)

# ##################################################################
# tidy the value files - separate the geoid into state, county, tract
# ##################################################################

for (i in 1:length(my.value.ldf)) {

# #####################
# NOTE
# ##################
# IT WOULD BE BETTER TO DO THIS WHOLE PROCESS IN PYTHON
# AND DO THE VISUALIZATION IN r AFTER THE DATA IS PROCESSED HERE
#
# NOTE THAT STATE MUST BE '10', COUNTY MUST BE '10010' AND TRACT IS FINE AS IS
# FIGURE OUT A WAY TO GET THESE DONE
#####################

	print(paste("Now processing: ",i))
	# separate won't work here - county fips must include the state; same with tracts
	my.state <- as.character(my.value.ldf[[i]]$geoid)

	my.state <- separate(my.value.ldf[[i]],geoid,sep=c(2),convert=FALSE)

	my.temp.df <- separate(my.value.ldf[[i]],geoid, 
		into = c("state", "county","tract"), 
		sep = c(2,5),
		convert = FALSE)
	
	# build the filename using i
	outfile <- gsub(" ","",paste("HUD/",my.temp.df$quarter[i],"-",my.temp.df$year[i],"_tidy",".csv"))

	# get rid of this column (NEED TO FIGURE OUT WHY IT IS BEING ADDED)
	my.temp.df$X <- NULL

	# write the file out
	print("Writing output csv file TIDY")
	write.csv(my.temp.df, outfile)
	print("File is complete")

}

rm("my.value.ldf")

# ##################################################################
# list all "tidy" files
# ##################################################################

tidyfiles <- list.files("HUD",pattern="*_tidy.csv",full.names=TRUE)

my.tidy.ldf = lapply(tidyfiles, read.csv, as.is=FALSE)

# ##################################################################
# process different aggregations of each data set and output to 
# the appropriate file
# ##################################################################

# ##################################################################
# create STATE aggregations
# ##################################################################

# create buckets for totals
tot_ams_res = 0
tot_res_vac = 0
tot_vac_3_res = 0
tot_vac_3_6_res = 0
tot_vac_6_12_res = 0
tot_vac_12_24_res = 0
tot_vac_24_36_res = 0
tot_vac_36_res = 0

# create an empty data frame
my.state.df = NULL

# store off first state
my.state <- my.tidy.ldf[[1]]$state[1]

# for each of the input files
for (i in 1:length(my.tidy.ldf)) {

	# aggregate States
	print(paste("Now processing States in file: ",i))

	# get the number of states in current file
	my.count <- length(levels(as.factor(my.tidy.ldf[[i]]$state)))

	# aggregate statistics to state level
	for (j in 1:length(my.tidy.ldf[[i]][,1])) {

		if (my.tidy.ldf[[i]]$state[j] != my.state) {
			# got a new state
			# do new state things

			# print out the current accumulators
			print(paste("State: ",my.state))

			print(tot_ams_res)
			print(tot_res_vac)
			print(tot_vac_3_res)
			print(tot_vac_3_6_res)
			print(tot_vac_6_12_res)
			print(tot_vac_12_24_res)
			print(tot_vac_24_36_res)
			print(tot_vac_36_res)

			# calculate the percentages
			# THIS NEEDS TO BE A FUNCTION!!!!!!!
			if (tot_ams_res != 0) {
				vac_3_perc <- tot_vac_3_res / tot_ams_res
				vac_3_6_perc <- tot_vac_3_6_res / tot_ams_res
				vac_6_12_perc <- tot_vac_6_12_res / tot_ams_res
				vac_12_24_perc <- tot_vac_12_24_res / tot_ams_res
				vac_24_36_perc <- tot_vac_24_36_res / tot_ams_res
				vac_36_perc <- tot_vac_36_res / tot_ams_res

				# calculate occupied and vacant percentage
				occupied_perc <- (tot_ams_res - tot_res_vac) / tot_ams_res
				vacant_perc <- tot_res_vac / tot_ams_res
			} else {
				vac_3_perc = 0
				vac_3_6_perc = 0
				vac_6_12_perc = 0
				vac_12_24_perc = 0
				vac_24_36_perc = 0
				vac_36_perc = 0
				occupied_perc = 0
				vacant_perc = 0
			}

			# print the percentages
			print(vac_3_perc)
			print(vac_3_6_perc)
			print(vac_6_12_perc)
			print(vac_12_24_perc)
			print(vac_24_36_perc)
			print(vac_36_perc)
			print(occupied_perc)
			print(vacant_perc)
			
			# create a vector of the values to keep
			my.state.vec <- c(state=my.state,
		            quarter=my.quarter,
		            year=my.year, 
				vac_3_perc=vac_3_perc,
				vac_3_6_perc=vac_3_6_perc,
				vac_6_12_perc=vac_6_12_perc,
				vac_12_24_perc=vac_12_24_perc,
				vac_24_36_perc=vac_24_36_perc,
				vac_36_perc=vac_36_perc,
				occupied_perc=occupied_perc,
				tot_ams_res=tot_ams_res,
				vacant_perc=vacant_perc)

			# add my.state.vec to my.state.df
			my.state.df <- rbind(my.state.df,my.state.vec)

			# reset my.state.vec to empty
			my.state.vec <- NULL

			# reset the accumulators
			tot_ams_res = 0
			tot_res_vac = 0
			tot_vac_3_res = 0
			tot_vac_3_6_res = 
			tot_vac_6_12_res = 0
			tot_vac_12_24_res = 0
			tot_vac_24_36_res = 0
			tot_vac_36_res = 0
		}
		# not a new state, so accumulate the values
		tot_ams_res <- tot_ams_res + my.tidy.ldf[[i]]$ams_res[j]
		tot_res_vac <- tot_res_vac + my.tidy.ldf[[i]]$res_vac[j]
		tot_vac_3_res <- tot_vac_3_res + my.tidy.ldf[[i]]$vac_3_res[j]
		tot_vac_3_6_res <- tot_vac_3_6_res + my.tidy.ldf[[i]]$vac_3_6_res[j]
		tot_vac_6_12_res <- tot_vac_6_12_res + my.tidy.ldf[[i]]$vac_6_12_res[j]
		tot_vac_12_24_res <- tot_vac_12_24_res + my.tidy.ldf[[i]]$vac_12_24_res[j]
		tot_vac_24_36_res <- tot_vac_24_36_res + my.tidy.ldf[[i]]$vac_24_36_res[j]
		tot_vac_36_res <- tot_vac_36_res + my.tidy.ldf[[i]]$vac_36_res[j]

		# store the quarter and year
		my.state <- as.character(my.tidy.ldf[[i]]$state[j])
		my.quarter <- as.character(my.tidy.ldf[[i]]$quarter[j])
		my.year <- as.character(my.tidy.ldf[[i]]$year[j])
	
	}

}

# build the filename 
outfile <- gsub(" ","",paste("HUD/","all_states",".csv"))

# write the file out
print("Writing output csv file STATES")
write.csv(my.state.df, outfile)
#write.csv(mydata, file=outstate, append=T, col.names=F) 	# or outcounty or outtract
print("File is complete")

# ##################################################################
# create COUNTY aggregations
# ##################################################################

# create buckets for totals
tot_ams_res = 0
tot_res_vac = 0
tot_vac_3_res = 0
tot_vac_3_6_res = 0
tot_vac_6_12_res = 0
tot_vac_12_24_res = 0
tot_vac_24_36_res = 0
tot_vac_36_res = 0

# create an empty data frame
my.county.df = NULL

# store off first county
my.county <- as.character(my.tidy.ldf[[1]]$county[1])

# for each of the input files
for (i in 1:length(my.tidy.ldf)) {

	# aggregate Counties
	print(paste("Now processing Counties in file: ",i))

	# get the number of states in current file
	my.count <- length(levels(as.factor(my.tidy.ldf[[i]]$county)))

	# aggregate statistics to county level
	for (j in 1:length(my.tidy.ldf[[i]][,1])) {

		if (my.tidy.ldf[[i]]$county[j] != my.county) {
			# got a new county
			# do new county things

			# print out the current accumulators
			print(paste("County: ",my.county))

			print(tot_ams_res)
			print(tot_res_vac)
			print(tot_vac_3_res)
			print(tot_vac_3_6_res)
			print(tot_vac_6_12_res)
			print(tot_vac_12_24_res)
			print(tot_vac_24_36_res)
			print(tot_vac_36_res)

			# calculate the percentages
			# THIS NEEDS TO BE A FUNCTION!!!!!!!
			if (tot_ams_res != 0) {
				vac_3_perc <- tot_vac_3_res / tot_ams_res
				vac_3_6_perc <- tot_vac_3_6_res / tot_ams_res
				vac_6_12_perc <- tot_vac_6_12_res / tot_ams_res
				vac_12_24_perc <- tot_vac_12_24_res / tot_ams_res
				vac_24_36_perc <- tot_vac_24_36_res / tot_ams_res
				vac_36_perc <- tot_vac_36_res / tot_ams_res

				# calculate occupied and vacant percentage
				occupied_perc <- (tot_ams_res - tot_res_vac) / tot_ams_res
				vacant_perc <- tot_res_vac / tot_ams_res
			} else {
				vac_3_perc = 0
				vac_3_6_perc = 0
				vac_6_12_perc = 0
				vac_12_24_perc = 0
				vac_24_36_perc = 0
				vac_36_perc = 0
				occupied_perc = 0
				vacant_perc = 0
			}

			# print the percentages
			print(vac_3_perc)
			print(vac_3_6_perc)
			print(vac_6_12_perc)
			print(vac_12_24_perc)
			print(vac_24_36_perc)
			print(vac_36_perc)
			print(occupied_perc)
			print(vacant_perc)
			
			# create a vector of the values to keep
			my.county.vec <- c(county=my.county,
		            quarter=my.quarter,
		            year=my.year, 
				vac_3_perc=vac_3_perc,
				vac_3_6_perc=vac_3_6_perc,
				vac_6_12_perc=vac_6_12_perc,
				vac_12_24_perc=vac_12_24_perc,
				vac_24_36_perc=vac_24_36_perc,
				vac_36_perc=vac_36_perc,
				occupied_perc=occupied_perc,
				tot_ams_res=tot_ams_res,
				vacant_perc=vacant_perc)

			# add my.county.vec to my.county.df
			my.county.df <- rbind(my.county.df,my.county.vec)

			# reset my.county.vec to empty
			my.county.vec <- NULL

			# reset the accumulators
			tot_ams_res = 0
			tot_res_vac = 0
			tot_vac_3_res = 0
			tot_vac_3_6_res = 0
			tot_vac_6_12_res = 0
			tot_vac_12_24_res = 0
			tot_vac_24_36_res = 0
			tot_vac_36_res = 0
		}
		# not a new county, so accumulate the values
		tot_ams_res <- tot_ams_res + my.tidy.ldf[[i]]$ams_res[j]
		tot_res_vac <- tot_res_vac + my.tidy.ldf[[i]]$res_vac[j]
		tot_vac_3_res <- tot_vac_3_res + my.tidy.ldf[[i]]$vac_3_res[j]
		tot_vac_3_6_res <- tot_vac_3_6_res + my.tidy.ldf[[i]]$vac_3_6_res[j]
		tot_vac_6_12_res <- tot_vac_6_12_res + my.tidy.ldf[[i]]$vac_6_12_res[j]
		tot_vac_12_24_res <- tot_vac_12_24_res + my.tidy.ldf[[i]]$vac_12_24_res[j]
		tot_vac_24_36_res <- tot_vac_24_36_res + my.tidy.ldf[[i]]$vac_24_36_res[j]
		tot_vac_36_res <- tot_vac_36_res + my.tidy.ldf[[i]]$vac_36_res[j]

		# store the quarter and year
		my.county <- as.character(my.tidy.ldf[[i]]$county[j])
		my.quarter <- as.character(my.tidy.ldf[[i]]$quarter[j])
		my.year <- as.character(my.tidy.ldf[[i]]$year[j])
	
	}

}

# build the filename 
outfile <- gsub(" ","",paste("HUD/","all_counties",".csv"))

# write the file out
print("Writing output csv file COUNTIES")
write.csv(my.county.df, outfile)
print("File is complete")



