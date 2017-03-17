# ####################################################################
#
# Program:  ProcessHUDfilesForVizWithFn.py
#
# Author:  Dolores Jane Forbes (dolores.j.forbes@census.gov)  x39323
#
# Date:  March 14, 2017
#
# Python Version:  2.7.1
#
# Branch:  Geographic Research & Innovation Staff/Geography
#
# This script processes census tract-level HUD input files by creating
# summary percentages of individual variables at multiple spatial scales
# (nation, state, county).
#
# The purpose in doing this is to develop visualizations of these
# percentages over time at multiple spatial scales (national, state,
# county, and the original census tract level).
#
# These multiple spatial scales might then be served for analysis
# using R Shiny or other methods.
#
# This script was built with Python 2.7
#
# I'm using Anaconda for Python 2.7 for access to the rich number of available
# packages.
#
#   - use conda env list    # to list available environments
#   - activate py27         # activate py27
#   - idle                  # to start IDLE as the programming environment
#   - conda install pkg     # install a package (make sure py27 is activated)
#
# ####################################################################
# import libraries
# ####################################################################

import os
from glob import glob
import pandas as pd
import pysal as ps      # for reading .dbf files
import csv              # for writing .csv files

# ####################################################################
# set working environment (or current working directory)
# ####################################################################


# ####################################################################
# global constants
# ####################################################################


# ####################################################################
# functions
# ####################################################################

'''
This function: reads in DBF files and returns Pandas DF

Arguments
---------
dbfile  : DBF file - Input to be imported
upper   : Condition - If true, make column heads upper case
'''
def dbf2DF(dbfile, mycols):
    # Pysal to open DBF file
    db = ps.open(dbfile)
    # convert to a dictionary with key:value pairs
    d = dict([(var, db.by_col(var)) for var in mycols])
    # Convert to Pandas DF
    pandasDF = pd.DataFrame(d)
    # Make columns all uppercase
    pandasDF.columns = map(str.upper, pandasDF.columns)
    # close the dbf file
    db.close()
    # return the pandas data frame
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

# lists of columns I want to keep
colsListuc = ["GEOID",
            "month",
            "year",
            "AMS_RES",
            "RES_VAC",
            "AVG_VAC_R",
            "VAC_3_RES",
            "VAC_3_6_R",
            "VAC_6_12R",
            "VAC_12_24R",
            "VAC_24_36R",
            "VAC_36_RES"]

colsListlc = ["GEOID",
            "month",
            "year",
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

nationalFile = open('..\\HUD\\national.csv',"wb")
natlWriter = csv.writer(nationalFile, delimiter=',')
natlWriter.writerow(['Month/Year',
                    'GEOID',
                    'totalAllAMS_RES',
                    'totalAllRES_VAC',
                    'totalAllAVG_VAC_R',
                    'totalAllVAC_3_RES',
                    'totalAllVAC_3_6_R',
                    'totalAllVAC_6_12R',
                    'totalAllVAC_12_24R',
                    'totalAllVAC_24_36R',
                    'totalAllVAC_36_RES'])

stateFile = open('..\\HUD\\state.csv',"wb")
stateWriter = csv.writer(stateFile, delimiter=',')
stateWriter.writerow(['Month/Year',
                    'GEOID',
                    'totalStateAMS_RES',
                    'totalStateRES_VAC',
                    'totalStateAVG_VAC_R',
                    'totalStateVAC_3_RES',
                    'totalStateVAC_3_6_R',
                    'totalStateVAC_6_12R',
                    'totalStateVAC_12_24R',
                    'totalStateVAC_24_36R',
                    'totalStateVAC_36_RES'])

countyFile = open('..\\HUD\\county.csv',"wb")
countyWriter = csv.writer(countyFile, delimiter=',')
countyWriter.writerow(['Month/Year',
                    'GEOID',
                    'totalCountyAMS_RES',
                    'totalCountyRES_VAC',
                    'totalCountyAVG_VAC_R',
                    'totalCountyVAC_3_RES',
                    'totalCountyVAC_3_6_R',
                    'totalCountyVAC_6_12R',
                    'totalCountyVAC_12_24R',
                    'totalCountyVAC_24_36R',
                    'totalCountyVAC_36_RES'])

tractFile = open('..\\HUD\\tract.csv',"wb")
tractWriter = csv.writer(tractFile, delimiter=',')
tractWriter.writerow(['Month/Year',
                    'GEOID',
                    'tractAMS_RES',
                    'tractRES_VAC',
                    'tractAVG_VAC_R',
                    'tractVAC_3_RES',
                    'tractVAC_3_6_R',
                    'tractVAC_6_12R',
                    'tractVAC_12_24R',
                    'tractVAC_24_36R',
                    'tractVAC_36_RES'])

# get list of all .dbf filenames in the specific directory
fileNames = glob('..\\Shapefiles\\*.dbf')
print(fileNames)

# process each file
for myFile in fileNames:

    # First, check the year to see if we have lowercase column headings.
    # Note that beginning in 3/2015, HUD headers are NOT uppercase, so
    # make sure that all the headers are in uppercase to match colsList

    # I'm looking for the year at the end of the filename:
    if int(myFile[-26:-22]) >= 2015:
        colsList = colsListlc
    else:
        colsList = colsListuc

    # open and convert the .dbf file to pandas data frame
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
    myQtrYear = str(mypandasDF.iloc[0]['MONTH']) + "/" + str(mypandasDF.iloc[0]['YEAR'])
    print("Month/Year: %s" % (myQtrYear))

    # process each record in the individual file
    for index, row in mypandasDF.iterrows():
        
        numAllRecords += 1

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
        if (myCounty <> str(row["GEOID"][0:5])):
            
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

            # number of county records processed
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
            
        # is this a new state?
        if (myState <> str(row["GEOID"][0:2])):
            
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

        # get ready for next row, store off the new State, County
        myState = str(row["GEOID"][0:2])
        
        myCounty = str(row["GEOID"][0:5])

    # end of all records within a file
    print("The file %s has completed processing." % (myFile))
    
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

    # count number of state records processed
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


    

