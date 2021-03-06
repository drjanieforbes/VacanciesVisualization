# ####################################################################
#
# Program:  ProcessHUDfilesForVizWithFnV6Py36.py
#
# Author:  Dolores Jane Forbes (dolores.j.forbes@census.gov)  x39323
#
# Date:  March 14, 2017
#
# Python Version:  3.6.0
#
# Branch:  Geographic Research & Innovation Staff/Geography
#
# This script processes census tract-level HUD input files by creating
# summary statistics of individual variables at multiple spatial scales
# (nation, state, county).  Census tract level is already included in the
# files.
#
# The purpose in doing this is to develop visualizations of these
# statistics over time at multiple spatial scales (national, state,
# county, and the original census tract level).
#
# These multiple spatial scales might then be served for analysis
# using R Shiny or other methods.
#
# This script was built with Python 3.6.0
#
# I'm using Anaconda for Python 3.6.0 for easy access to the rich number of
# available packages.
#
#   - use conda env list    # to list available environments
#   - activate py36         # activate py36
#   - idle                  # to start IDLE as the programming environment
#   - conda install pkg     # install a package (make sure py27 is activated)
#
# ####################################################################
# import libraries
# ####################################################################

import os
from glob import glob
import pandas as pd
import csv              # for writing .csv files
from datetime import datetime     # time tracking
from operator import itemgetter   # for sorting
from dbfread import DBF

# ####################################################################
# set working environment (or current working directory)
# ####################################################################


# ####################################################################
# global constants
# ####################################################################

# ####################################################################
# Start the timer
# ####################################################################
startTime = datetime.now()
print("Start time: ")
print(datetime.now())
print

# ####################################################################
# functions
# ####################################################################

'''
dbf2DF

This function: accepts and opens a DBF file, converts to a dictionary
and then converts to and returns a Pandas data frame of selected
columns from the original file.

Arguments
---------
dbfile  : string - Filename to be imported
mycols  : list - List of columns to keep
'''

def dbf2DF(dbfile, mycols):
    
    # dbfread to open DBF file
    db = DBF(dbfile)
    
    # Convert to Pandas DF
    pandasDF = pd.DataFrame(iter(db))
    
    # Make columns all uppercase
    pandasDF.columns = map(str.upper, pandasDF.columns)
   
    # return the sorted pandas data frame
    return pandasDF


# ####################################################################
# main()
# ####################################################################

# initialize some variables
numAllRecords = 0
numNationalRecords = 0
numStateRecords = 0
numCountyRecords = 0
numTractRecords = 0

# counters for calculating the Average Days Vacant statistic
numRecsThisState = 0
numRecsThisCounty = 0
numRecsThisFile = 0

# lists of columns I want to keep
colsListuc = ["GEOID",                  # uppercase
            "AMS_RES",
            "RES_VAC",
            "AVG_VAC_R",
            "VAC_3_RES",
            "VAC_3_6_R",
            "VAC_6_12R",
            "VAC_12_24R",
            "VAC_24_36R",
            "VAC_36_RES"]

colsListlc = ["geoid",                  # some files include lowercase headings
            "ams_res",
            "res_vac",
            "avg_vac_r",
            "vac_3_res",
            "vac_3_6_r",
            "vac_6_12r",
            "vac_12_24r",
            "vac_24_36r",
            "vac_36_res"]    

# national level sums
totalAllAMS_RES = 0
totalAllRES_VAC = 0
totalAllAVG_VAC_R = 0
totalAllVAC_3_RES = 0
totalAllVAC_3_6_R = 0
totalAllVAC_6_12R = 0
totalAllVAC_12_24R = 0
totalAllVAC_24_36R = 0
totalAllVAC_36_RES = 0

# state level sums
totalStateAMS_RES = 0
totalStateRES_VAC = 0
totalStateAVG_VAC_R = 0
totalStateVAC_3_RES = 0
totalStateVAC_3_6_R = 0
totalStateVAC_6_12R = 0
totalStateVAC_12_24R = 0
totalStateVAC_24_36R = 0
totalStateVAC_36_RES = 0

# county level sums
totalCountyAMS_RES = 0
totalCountyRES_VAC = 0
totalCountyAVG_VAC_R = 0
totalCountyVAC_3_RES = 0
totalCountyVAC_3_6_R = 0
totalCountyVAC_6_12R = 0
totalCountyVAC_12_24R = 0
totalCountyVAC_24_36R = 0
totalCountyVAC_36_RES = 0

# open four files for output and write the headers
# one for each scale:  national, state, county, tract
# Note:  record layouts are the same, variable names differ by scale

# keep record layouts consistent across all levels
colHeadings = ['Month/Year',
                'GEOID',                
                'totalAMS_RES',
                'totalRES_VAC',
                'totalAVG_VAC_R',
                'totalVAC_3_RES',
                'totalVAC_3_6_R',
                'totalVAC_6_12R',
                'totalVAC_12_24R',
                'totalVAC_24_36R',
                'totalVAC_36_RES']

nationalFile = open('..\\HUD\\national.csv',"w")
natlWriter = csv.writer(nationalFile, delimiter=',',
                            lineterminator='\n',
                            quotechar='"',
                            quoting=csv.QUOTE_NONNUMERIC)
natlWriter.writerow(colHeadings)

stateFile = open('..\\HUD\\state.csv',"w")
stateWriter = csv.writer(stateFile, delimiter=',',
                            lineterminator='\n',
                            quotechar='"',
                            quoting=csv.QUOTE_NONNUMERIC)
stateWriter.writerow(colHeadings)

countyFile = open('..\\HUD\\county.csv',"w")
countyWriter = csv.writer(countyFile, delimiter=',',
                            lineterminator='\n',
                            quotechar='"',
                            quoting=csv.QUOTE_NONNUMERIC)
countyWriter.writerow(colHeadings)

tractFile = open('..\\HUD\\tract.csv',"w")
tractWriter = csv.writer(tractFile, delimiter=',',
                             lineterminator='\n',
                             quotechar='"',
                             quoting=csv.QUOTE_NONNUMERIC)
tractWriter.writerow(colHeadings)

# get list of all .dbf filenames in the specific directory
fileNames = glob('..\\Shapefiles\\*Data.dbf')
print(" ")
print(fileNames)

# process each file
for myFile in fileNames:

    # First, check the year to see if we have lowercase column headings.
    # Note that beginning in 3/2015, HUD column headings are NOT uppercase,
    # make sure that all the headers are in uppercase to match colsList

    # I'm looking for the year at the end of the filename:
    if int(myFile[-26:-22]) >= 2015:
        colsList = colsListlc
    else:
        colsList = colsListuc

    # This logic should be replaced by a check of the actual column
    # headings, in case HUD decides to go back to uppercase headings
    # at some future date.

    # open and convert the .dbf file to pandas data frame with my selected columns
    mypandasDF = dbf2DF(myFile,colsList)

    # What's the GEOID look like?
    print("First GEOID in this file: %s" % (mypandasDF.iloc[0]['GEOID']))

    # get current state GEOID
    myState = str(mypandasDF.iloc[0]['GEOID'][0:2])
    print("Initial State: %s" % (myState))
    
    # get current county GEOID
    myCounty = str(mypandasDF.iloc[0]['GEOID'][0:5])
    print("Initial County: %s" % (myCounty))

    # get current month/year for this file
    myQtrYear = str(myFile[-21:-19]) + "/" + str(myFile[-26:-22])
    print("Month/Year: %s" % (myQtrYear))

    # process each record in the individual file
    for index, row in mypandasDF.iterrows():
        
        # increment the counters
        numAllRecords += 1
        numTractRecords += 1

        # export the record to the census tract file
        tractWriter.writerow([myQtrYear,
                              str(row['GEOID']),
                              row['AMS_RES'],
                              row['RES_VAC'],
                              row['AVG_VAC_R'],
                              row['VAC_3_RES'],
                              row['VAC_3_6_R'],
                              row['VAC_6_12R'],
                              row['VAC_12_24R'],
                              row['VAC_24_36R'],
                              row['VAC_36_RES']])

        # is this a new county?
        if (myCounty != str(row["GEOID"][0:5])):
            
            # yes, so calculate the Average Days Vacant for this county
            totalCountyAVG_VAC_R = (totalCountyAVG_VAC_R / numRecsThisCounty)

            # yes, so write a line to the county file for this quarter-year
            countyWriter.writerow([myQtrYear,
                                myCounty,
                                totalCountyAMS_RES,
                                totalCountyRES_VAC,
                                totalCountyAVG_VAC_R,
                                totalCountyVAC_3_RES,
                                totalCountyVAC_3_6_R,
                                totalCountyVAC_6_12R,
                                totalCountyVAC_12_24R,
                                totalCountyVAC_24_36R,
                                totalCountyVAC_36_RES])

            # number of county records output
            numCountyRecords += 1
            
            # reset the county level totals
            totalCountyAMS_RES = 0
            totalCountyRES_VAC = 0
            totalCountyAVG_VAC_R = 0
            totalCountyVAC_3_RES = 0
            totalCountyVAC_3_6_R = 0
            totalCountyVAC_6_12R = 0
            totalCountyVAC_12_24R = 0
            totalCountyVAC_24_36R = 0
            totalCountyVAC_36_RES = 0

            # reset the county level counter
            numRecsThisCounty = 0
            
        # is this a new state?
        if (myState != str(row["GEOID"][0:2])):
            
            # yes, so calculate the Average Days Vacant for this state
            totalStateAVG_VAC_R = (totalStateAVG_VAC_R / numRecsThisState)

            # yes, so write a line to the state file for this quarter-year
            stateWriter.writerow([myQtrYear,
                                myState,
                                totalStateAMS_RES,
                                totalStateRES_VAC,
                                totalStateAVG_VAC_R,
                                totalStateVAC_3_RES,
                                totalStateVAC_3_6_R,
                                totalStateVAC_6_12R,
                                totalStateVAC_12_24R,
                                totalStateVAC_24_36R,
                                totalStateVAC_36_RES])

            # count number of state records written
            numStateRecords += 1

            # reset the state level totals
            totalStateAMS_RES = 0
            totalStateRES_VAC = 0
            totalStateAVG_VAC_R = 0
            totalStateVAC_3_RES = 0
            totalStateVAC_3_6_R = 0
            totalStateVAC_6_12R = 0
            totalStateVAC_12_24R = 0
            totalStateVAC_24_36R = 0
            totalStateVAC_36_RES = 0

            # reset the record counts for this state
            numRecsThisState = 0

        # sum the national totals (all records within each quarter/year)
        totalAllAMS_RES += row["AMS_RES"]
        totalAllRES_VAC += row["RES_VAC"]
        totalAllAVG_VAC_R += row["AVG_VAC_R"]
        totalAllVAC_3_RES += row["VAC_3_RES"]
        totalAllVAC_3_6_R += row["VAC_3_6_R"]
        totalAllVAC_6_12R += row["VAC_6_12R"]
        totalAllVAC_12_24R += row["VAC_12_24R"]
        totalAllVAC_24_36R += row["VAC_24_36R"]
        totalAllVAC_36_RES += row["VAC_36_RES"]

        # increment the record counter for Average Days Vacant Statistic
        numRecsThisFile += 1            # for national level

        # sum the state totals (all records within a given state)
        totalStateAMS_RES += row["AMS_RES"]
        totalStateRES_VAC += row["RES_VAC"]
        totalStateAVG_VAC_R += row["AVG_VAC_R"]
        totalStateVAC_3_RES += row["VAC_3_RES"]
        totalStateVAC_3_6_R += row["VAC_3_6_R"]
        totalStateVAC_6_12R += row["VAC_6_12R"]
        totalStateVAC_12_24R += row["VAC_12_24R"]
        totalStateVAC_24_36R += row["VAC_24_36R"]
        totalStateVAC_36_RES += row["VAC_36_RES"]

        # increment the record counter for Average Days Vacant Statistic
        numRecsThisState += 1

        # sum the county totals (all records within a given county in a state)
        totalCountyAMS_RES += row["AMS_RES"]
        totalCountyRES_VAC += row["RES_VAC"]
        totalCountyAVG_VAC_R += row["AVG_VAC_R"]
        totalCountyVAC_3_RES += row["VAC_3_RES"]
        totalCountyVAC_3_6_R += row["VAC_3_6_R"]
        totalCountyVAC_6_12R += row["VAC_6_12R"]
        totalCountyVAC_12_24R += row["VAC_12_24R"]
        totalCountyVAC_24_36R += row["VAC_24_36R"]
        totalCountyVAC_36_RES += row["VAC_36_RES"]

        # increment the record counters for Average Days Vacant statistic
        numRecsThisCounty += 1

        # get ready for next row, store off the new State, County
        myState = str(row["GEOID"][0:2])
        myCounty = str(row["GEOID"][0:5])

    # end of all records within a file
    print(" ")
    print("The file %s has completed processing." % (myFile))
    print("Time interval to this file: %s" % (str(datetime.now() - startTime)))

    # calculate the Average Days Vacant for this file (national level)
    totalAllAVG_VAC_R = (totalAllAVG_VAC_R / numRecsThisFile)
    
    # write a line to the national file for this quarter-year
    natlWriter.writerow([myQtrYear,
                        "01",               # an "invented" geoid for the USA
                        totalAllAMS_RES,
                        totalAllRES_VAC,
                        totalAllAVG_VAC_R,
                        totalAllVAC_3_RES,
                        totalAllVAC_3_6_R,
                        totalAllVAC_6_12R,
                        totalAllVAC_12_24R,
                        totalAllVAC_24_36R,
                        totalAllVAC_36_RES])

    # count number of national records processed
    numNationalRecords += 1

    # reset the national totals
    totalAllAMS_RES = 0
    totalAllRES_VAC = 0
    totalAllAVG_VAC_R = 0
    totalAllVAC_3_RES = 0
    totalAllVAC_3_6_R = 0
    totalAllVAC_6_12R = 0
    totalAllVAC_12_24R = 0
    totalAllVAC_24_36R = 0
    totalAllVAC_36_RES = 0

    # reset the number of records in this file
    numRecsThisFile = 0

    # calculate the Average Days Vacant for this state
    totalStateAVG_VAC_R = (totalStateAVG_VAC_R / numRecsThisState)

    # write a line to the state file for this quarter-year
    stateWriter.writerow([myQtrYear,
                        str(row["GEOID"][0:2]),
                        totalStateAMS_RES,
                        totalStateRES_VAC,
                        totalStateAVG_VAC_R,
                        totalStateVAC_3_RES,
                        totalStateVAC_3_6_R,
                        totalStateVAC_6_12R,
                        totalStateVAC_12_24R,
                        totalStateVAC_24_36R,
                        totalStateVAC_36_RES])

    # count number of state records processed
    numStateRecords += 1

    # reset the state level totals
    totalStateAMS_RES = 0
    totalStateRES_VAC = 0
    totalStateAVG_VAC_R = 0
    totalStateVAC_3_RES = 0
    totalStateVAC_3_6_R = 0
    totalStateVAC_6_12R = 0
    totalStateVAC_12_24R = 0
    totalStateVAC_24_36R = 0
    totalStateVAC_36_RES = 0

    # reset the record count for this state
    numRecsThisState = 0

    # calculate the Average Days Vacant for this county
    totalCountyAVG_VAC_R = (totalCountyAVG_VAC_R / numRecsThisCounty)

    # write the totals to the county aggregate file
    countyWriter.writerow([myQtrYear,
                        str(row["GEOID"][0:5]),
                        totalCountyAMS_RES,
                        totalCountyRES_VAC,
                        totalCountyAVG_VAC_R,
                        totalCountyVAC_3_RES,
                        totalCountyVAC_3_6_R,
                        totalCountyVAC_6_12R,
                        totalCountyVAC_12_24R,
                        totalCountyVAC_24_36R,
                        totalCountyVAC_36_RES])

    # count number of county records processed
    numCountyRecords += 1
    
    # reset the county level totals
    totalCountyAMS_RES = 0
    totalCountyRES_VAC = 0
    totalCountyAVG_VAC_R = 0
    totalCountyVAC_3_RES = 0
    totalCountyVAC_3_6_R = 0
    totalCountyVAC_6_12R = 0
    totalCountyVAC_12_24R = 0
    totalCountyVAC_24_36R = 0
    totalCountyVAC_36_RES = 0

    # reset the record count for this county
    numRecsThisCounty = 0

# end of all input files
print("Total number of records processed: %i" % (numAllRecords))
print("Number of national records: %i" % (numNationalRecords))
print("Number of state records: %i" % (numStateRecords))
print("Number of county records: %i" % (numCountyRecords))
print("Number of tract records: %i" % (numTractRecords))

# close all files
tractFile.close()
countyFile.close()
stateFile.close()
nationalFile.close()

# ####################################################################
# End the timer
# ####################################################################

print(" ")
print("Finished all processing")
print(datetime.now() - startTime)

    

