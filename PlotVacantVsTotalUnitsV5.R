# ##################################################################
# Author:  Dolores Jane Forbes
#
# Date:  03/22/2017
#
# Email:  dolores.j.forbes@census.gov
#
# File: PlotVacantVsTotalUnitsV5.R Version 5
#
# Branch:  Geographic Research & Innovation Staff/Geography
#
# ##################################################################
#
# Using R version 3.2.2 (2015-08-14) -- "Fire Safety"
#
# This file reads summary files generated from a Python script:
#   ProcessHUDfilesForVizWithFn.py (look for latest version)
#
# The summary files consist of residential vacancy statistics
# at multiple scales:  national, state, county, and census tract.
#
# This script opens and reads each of these files, and generates
# tables of statistics based on percentages.  Each of the scales
# is then visualized as a time series of percentage statistics.
#
# ##################################################################
#
# Modules:
# 
# 1)  Checks/sets the working directory
# 2)  Opens and processes the separate scale summary files:
#		national.csv
#		state.csv
#		county.csv
#		tract.csv
# 3)  Plots the specified level/GEOID as specified (to be used
#     in R Shiny)
#
# ##################################################################


# ##################################################################
# load libraries
# ##################################################################

library(foreign)
library(plotly)

# ##################################################################
# environment settings
# ##################################################################

options(scipen=999)

# ##################################################################
# check to see if working directory has already been set
# ##################################################################

# version for on site work
if(!getwd() == "T:/$$JSL/Janie/Private/VacantHouses") {
  oldwd = getwd()
  setwd("T:/$$JSL/Janie/Private/VacantHouses")
}

# version for telework site (home)
if(!getwd() == "C:/CensusProjs/HUDData/VacantHouses") {
  oldwd = getwd()
  setwd("C:/CensusProjs/HUDData/VacantHouses")
}

# ##################################################################
# external data sets
# ##################################################################

state.fips <- read.csv(file="./HUD/StateFIPS.csv", 
                       header=TRUE, 
                       sep=",",
                       stringsAsFactors = FALSE)

county.fips <- read.csv(file="./HUD/CountyFIPS.csv",
                        header=TRUE, 
                        sep=",",
                        stringsAsFactors = FALSE)

# ##################################################################
# constants
# ##################################################################

layout <- list(
  # changed autosize to TRUE here
  autosize = TRUE, 
  bargap = 0.05, 
  bargroupgap = 0.15, 
  barmode = "stack", 
  boxgap = 0.3, 
  boxgroupgap = 0.3, 
  boxmode = "overlay", 
  dragmode = "zoom", 
  font = list(
    color = "rgb(255, 255, 255)", 
    family = "'Open sans', verdana, arial, sans-serif", 
    size = 12
  ), 
  height = 700, 
  hidesources = FALSE, 
  hovermode = "x", 
  legend = list(
    x = 1.11153846154, 
    y = 1.01538461538, 
    bgcolor = "rgba(255, 255, 255, 0)", 
    bordercolor = "rgba(0, 0, 0, 0)", 
    borderwidth = 1, 
    font = list(
      color = "", 
      family = "", 
      size = 0
    ), 
    traceorder = "normal", 
    xanchor = "auto", 
    yanchor = "auto"
  ), 
  margin = list(
    r = 80, 
    t = 100, 
    autoexpand = TRUE, 
    b = 80, 
    l = 100, 
    pad = 0
  ), 
  paper_bgcolor = "rgb(67, 67, 67)", 
  plot_bgcolor = "rgb(67, 67, 67)", 
  separators = ".,", 
  showlegend = TRUE, 
  smith = FALSE, 
  title = "National Level (United States)<br>Percent Units Vacant by Length of Time", 
  titlefont = list(
    color = "rgb(255, 255, 255)", 
    family = "", 
    size = 0
  ), 
  width = 700, 
  xaxis = list(
    anchor = "y", 
    autorange = TRUE, 
    autotick = TRUE, 
    domain = c(0, 1), 
    dtick = 20, 
    exponentformat = "e", 
    gridcolor = "#ddd", 
    gridwidth = 1, 
    linecolor = "#000", 
    linewidth = 1, 
    mirror = FALSE, 
    nticks = 0, 
    overlaying = FALSE, 
    position = 0, 
    range = c(0, 105.368421053), 
    rangemode = "normal", 
    showexponent = "all", 
    showgrid = FALSE, 
    showline = FALSE, 
    showticklabels = TRUE, 
    tick0 = 0, 
    tickangle = "auto", 
    tickcolor = "#000", 
    tickfont = list(
      color = "", 
      family = "", 
      size = 0
    ), 
    ticklen = 5, 
    ticks = "", 
    tickwidth = 1, 
    title = "<br><i>Data Source: Housing & Urban Development</i>", 
    titlefont = list(
      color = "", 
      family = "", 
      size = 0
    ), 
    type = "linear", 
    zeroline = FALSE, 
    zerolinecolor = "#000", 
    zerolinewidth = 1
  ), 
  yaxis = list(
    anchor = "x", 
    autorange = TRUE, 
    autotick = TRUE, 
    # added this so that the order is preserved on the output
    categoryorder = "trace",
    domain = c(0, 1), 
    dtick = 1, 
    exponentformat = "e", 
    gridcolor = "#ddd", 
    gridwidth = 1, 
    linecolor = "#000", 
    linewidth = 1, 
    mirror = FALSE, 
    nticks = 0, 
    overlaying = FALSE, 
    position = 0, 
    range = c(-0.5, 23.5), 
    rangemode = "normal", 
    showexponent = "all", 
    showgrid = FALSE, 
    showline = FALSE, 
    showticklabels = TRUE, 
    tick0 = 0, 
    tickangle = "auto", 
    tickcolor = "#000", 
    tickfont = list(
      color = "", 
      family = "", 
      size = 0
    ), 
    ticklen = 5, 
    ticks = "", 
    tickwidth = 1, 
    title = "", 
    titlefont = list(
      color = "", 
      family = "", 
      size = 0
    ), 
    type = "category", 
    zeroline = FALSE, 
    zerolinecolor = "#000", 
    zerolinewidth = 1
  )
)

# ##################################################################
# processFiles function
# ##################################################################

# This function takes any of the input files and creates
# an in-memory data set from which any geoid can be 
# selected and plotted

##################################################################
# Parameters:
# filein:  char - filename of the file to be processed
##################################################################

processFiles <- function(filein) {
  
  filein <- gsub(" ","",paste("./HUD/",filein))
  this.data <- read.csv(file=filein, 
                        header=TRUE, 
                        sep=",")
  
  # create empty list
  this.vector = list()
  
  # create empty data frame
  this.df <- data.frame(matrix(ncol = ncol(this.data), 
                               nrow = nrow(this.data)))
  
  colnames(this.df) <- c("Month.Year",
                         "GEOID",
                         "VAC_3_RESpc",
                         "VAC_3_6_RESpc",
                         "VAC_6_12_RESpc",
                         "VAC_12_24_RESpc",
                         "VAC_24_36_RESpc",
                         "VAC_36_RESpc",
                         "AVG_DAYS_VAC",
                         "RES_VACpc",
                         "AMS_RES")
  
  for (i in 1:nrow(this.data)) {
    
    this.vector <- as.character(this.data[,1][i])
    this.vector <- c(this.vector,this.data[,2][i])
    
    if (this.data[,4][i] != 0) {
      this.vector <- c(this.vector,
                       (this.data[,6][i] / this.data[,4][i]),
                       (this.data[,7][i] / this.data[,4][i]),
                       (this.data[,8][i] / this.data[,4][i]),
                       (this.data[,9][i] / this.data[,4][i]),
                       (this.data[,10][i] / this.data[,4][i]),
                       (this.data[,11][i] / this.data[,4][i]),
                       (this.data[,5][i]),            # calculated in Python
                       (this.data[,4][i] / this.data[,3][i]),
                       (this.data[,3][i]))
      
    } else {
      this.vector <- c(this.vector,0,0,0,0,0,0,
                       #sum(national.data$totalAllAVG_VAC_R[i])/73767,0,0)	
                       this.data[,5][i],0,0)
      
    }	
    
    # append to the data frame
    this.df[i,] <- this.vector
    
    # reset the vector to empty
    this.vector = list()
    
  }
  
  print("Success")
  return(this.df)
}

# ##################################################################
# buildTraces function
# ##################################################################

# This function takes any of the input files and builds
# the traces necessary for plotting

##################################################################
# Parameters:
# datain:  dataframe - subsetted dataframe to be plotted
##################################################################
# Returns:
#    a list of the traces needed for plotting
##################################################################

buildTraces <- function(datain) {
  
  trace1 <- list(
    x = as.numeric(datain[,3])*100, 
    y = datain[,1], 
    marker = list(color = "rgb(17, 78, 166)"), 
    name = "0-3 months", 
    orientation = "h", 
    type = "bar", 
    uid = "063b98", 
    xsrc = "Dreamshot:4231:b631ec", 
    ysrc = "Dreamshot:4231:b4bc0c"
  )
  
  trace2 <- list(
    x = as.numeric(datain[,4])*100,
    y = datain[,1], 
    marker = list(color = "rgb(41, 128, 171)"), 
    name = "3-6 months", 
    orientation = "h", 
    type = "bar", 
    uid = "d2ea67", 
    xsrc = "Dreamshot:4231:9a1926", 
    ysrc = "Dreamshot:4231:b4bc0c"
  )
  
  trace3 <- list(
    x = as.numeric(datain[,5])*100, 
    y = datain[,1], 
    marker = list(color = "rgb(104, 157, 46)"), 
    name = "6-12 months", 
    orientation = "h", 
    type = "bar", 
    uid = "5e63a2", 
    xsrc = "Dreamshot:4231:2ec534", 
    ysrc = "Dreamshot:4231:b4bc0c"
  )
  
  trace4 <- list(
    x = as.numeric(datain[,6])*100, 
    y = datain[,1], 
    marker = list(color = "rgb(36, 118, 23)"), 
    name = "12-24 months", 
    orientation = "h", 
    type = "bar", 
    uid = "24f079", 
    xsrc = "Dreamshot:4231:c7663a", 
    ysrc = "Dreamshot:4231:b4bc0c"
  )
  
  trace5 <- list(
    x = as.numeric(datain[,7])*100, 
    y = datain[,1], 
    marker = list(color = "rgb(169, 140, 31)"), 
    name = "24-36 months", 
    orientation = "h", 
    type = "bar", 
    uid = "ae6448", 
    xsrc = "Dreamshot:4231:8f7c41", 
    ysrc = "Dreamshot:4231:b4bc0c"
  )
  
  trace6 <- list(
    x = as.numeric(datain[,8])*100,
    y = datain[,1], 
    marker = list(color = "rgb(178, 81, 28)"), 
    name = "36+ months", 
    orientation = "h", 
    type = "bar", 
    uid = "173fcb", 
    xsrc = "Dreamshot:4231:a324f1", 
    ysrc = "Dreamshot:4231:b4bc0c"
  )
  
  return(list(trace1, trace2, trace3, trace4, trace5, trace6))
}

# ##################################################################
# plotLevel function
# ##################################################################

# This function plots the selected data frame.  First, it selects
# a subset based on the given parameters.  It then calls
# buildTraces using the subset.  Output is the final plot.

##################################################################
# Parameters:
##################################################################
# indata:  data.frame   # the data to be subset
# geoid:   char		# the selected geoid to plot (which must be
#				contained in indata data.frame)
# level:   char		# level of the plot (e.g. "National", "State", etc.
##################################################################
# Returns:
#    A plot of the selected data
##################################################################

plotLevel <- function(indata,geoid,level) {
  
  # first, select a subset based on the given parameters
  my.subset = subset(indata, GEOID == geoid)
  
  # can't find the geoid!
  stopifnot("can't find geoid!" == "can't find geoid!" ,nrow(my.subset) != 0)
  
  # call buildTraces using the subset
  these.traces <- buildTraces(my.subset)
  
  if (level == "State") {
    
    this.loc = subset(state.fips,StateFIPS == geoid)$State
    this.title <- paste(level,"Level","Geoid:",geoid,"<br>",this.loc,"<br>","Percent Units Vacant by Length of Time")
    
  } else if (level == "County") {
    
    this.loc = paste(subset(county.fips,CountyFIPS == geoid)$CountyName,
                     subset(county.fips,CountyFIPS == geoid)$State)
    this.title <- paste(level,"Level","Geoid:",geoid,"<br>",this.loc,"<br>","Percent Units Vacant by Length of Time")
    
  } else {
    this.loc <- "(United States)"
    this.title <- paste(level,"Level","<br>",this.loc,"<br>","Percent Units Vacant by Length of Time")
  }
  
  # plot the data
  p <- plot_ly(width=layout$width,height=layout$height)
  p <- add_trace(p, x=these.traces[[1]]$x, y=these.traces[[1]]$y, marker=these.traces[[1]]$marker, 
                 name=these.traces[[1]]$name, orientation=these.traces[[1]]$orientation, type=these.traces[[1]]$type, 
                 uid=these.traces[[1]]$uid, xsrc=these.traces[[1]]$xsrc, ysrc=these.traces[[1]]$ysrc)
  p <- add_trace(p, x=these.traces[[2]]$x, y=these.traces[[2]]$y, marker=these.traces[[2]]$marker, 
                 name=these.traces[[2]]$name, orientation=these.traces[[2]]$orientation, type=these.traces[[2]]$type, 
                 uid=these.traces[[2]]$uid, xsrc=these.traces[[2]]$xsrc, ysrc=these.traces[[2]]$ysrc)
  p <- add_trace(p, x=these.traces[[3]]$x, y=these.traces[[3]]$y, marker=these.traces[[3]]$marker, 
                 name=these.traces[[3]]$name, orientation=these.traces[[3]]$orientation, type=these.traces[[3]]$type, 
                 uid=these.traces[[3]]$uid, xsrc=these.traces[[3]]$xsrc, ysrc=these.traces[[3]]$ysrc)
  p <- add_trace(p, x=these.traces[[4]]$x, y=these.traces[[4]]$y, marker=these.traces[[4]]$marker, 
                 name=these.traces[[4]]$name, orientation=these.traces[[4]]$orientation, type=these.traces[[4]]$type, 
                 uid=these.traces[[4]]$uid, xsrc=these.traces[[4]]$xsrc, ysrc=these.traces[[4]]$ysrc)
  p <- add_trace(p, x=these.traces[[5]]$x, y=these.traces[[5]]$y, marker=these.traces[[5]]$marker, 
                 name=these.traces[[5]]$name, orientation=these.traces[[5]]$orientation, type=these.traces[[5]]$type, 
                 uid=these.traces[[5]]$uid, xsrc=these.traces[[5]]$xsrc, ysrc=these.traces[[5]]$ysrc)
  p <- add_trace(p, x=these.traces[[6]]$x, y=these.traces[[6]]$y, marker=these.traces[[6]]$marker, 
                 name=these.traces[[6]]$name, orientation=these.traces[[6]]$orientation, type=these.traces[[6]]$type, 
                 uid=these.traces[[6]]$uid, xsrc=these.traces[[6]]$xsrc, ysrc=these.traces[[6]]$ysrc)
  # removed 'bargroupgap', 'boxgap', 'boxgroupgap', 'boxmode' (deprecated?)
  p <- layout(p, autosize=layout$autosize, bargap=layout$bargap, barmode=layout$barmode, 
              dragmode=layout$dragmode, font=layout$font, hidesources=layout$hidesources, 
              hovermode=layout$hovermode, legend=layout$legend, margin=layout$margin, 
              paper_bgcolor=layout$paper_bgcolor, plot_bgcolor=layout$plot_bgcolor, 
              separators=layout$separators, showlegend=layout$showlegend, smith=layout$smith, 
              title=this.title, titlefont=layout$titlefont, xaxis=layout$xaxis, yaxis=layout$yaxis)
  p
  
}


# ##################################################################
# main()
# ##################################################################

# process the files into memory
national.file <- processFiles("national.csv")
state.file <- processFiles("state.csv")
county.file <- processFiles("county.csv")

# plot some scales
plotLevel(state.file,"26","State")		# Michigan
plotLevel(state.file,"24","State")		# Maryland
plotLevel(national.file,"1","National")
plotLevel(state.file,"3","State")		# Shouldn't work!
plotLevel(state.file,"2","State")   # Alaska
plotLevel(county.file,"26163","County") 	# Wayne County, Michigan (Detroit)

plotLevel(state.file,"12","State")   # Florida
plotLevel(state.file,"32","State")  # Nevada
plotLevel(state.file,"39","State")  # Ohio

