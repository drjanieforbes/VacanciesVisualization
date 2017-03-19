# ##################################################################
# Author:  Dolores Jane Forbes
#
# Date:  03/19/2017
#
# Email:  dolores.j.forbes@census.gov
#
# File: PlotVacantVsTotalUnitsV2.R Version 2
#
# Branch:  Geographic Research & Innovation Staff/Geography
#
# ##################################################################
#
# Using R version 3.2.2 (2015-08-14) -- "Fire Safety"
#
# This file reads summary files generated from a Python script:
# 	ProcessHUDfilesForVizWithFnV2.py
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
# 2)  Opens each of the separate scale summary files:
#		national.csv
#		state.csv
#		county.csv
#		tract.csv
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
# constants
# ##################################################################

NUMTRACTS = 73767

# ##################################################################
# check to see if working directory has already been set
# ##################################################################

# version for on site work
#if(!getwd() == "T:/$$JSL/Janie/Private/VacantHouses") {
#	oldwd = getwd()
#	setwd("T:/$$JSL/Janie/Private/VacantHouses")
#}

# version for telework site (home)
if(!getwd() == "C:/CensusProjs/HUDData/VacantHouses") {
	oldwd = getwd()
	setwd("C:/CensusProjs/HUDData/VacantHouses")
}

# ##################################################################
# process the national level file
# ##################################################################

national.data <- read.csv(file="./HUD/national.csv", 
	header=TRUE, 
	sep=",")

# create empty list
my.vector = list()

# create empty data frame
my.df <- data.frame(matrix(ncol = ncol(national.data)-1, 
	nrow = nrow(national.data)))

colnames(my.df) <- c("Month.Year",
			"VAC_3_RESpc",
			"VAC_3_6_RESpc",
			"VAC_6_12_RESpc",
			"VAC_12_24_RESpc",
			"VAC_24_36_RESpc",
			"VAC_36_RESpc",
			"AVG_DAYS_VAC",
			"RES_VACpc",
			"AMS_RES")

for (i in 1:nrow(national.data)) {

	my.vector <- as.character(national.data$Month.Year[i])

	if (national.data$totalAllRES_VAC[i] != 0) {
		my.vector <- c(my.vector,
			(national.data$totalAllVAC_3_RES[i] / national.data$totalAllRES_VAC[i]),
			(national.data$totalAllVAC_3_6_R[i] / national.data$totalAllRES_VAC[i]),
			(national.data$totalAllVAC_6_12R[i] / national.data$totalAllRES_VAC[i]),
			(national.data$totalAllVAC_12_24R[i] / national.data$totalAllRES_VAC[i]),
			(national.data$totalAllVAC_24_36R[i] / national.data$totalAllRES_VAC[i]),
			(national.data$totalAllVAC_36_RES[i] / national.data$totalAllRES_VAC[i]),
			(national.data$totalAllAVG_VAC_R[i]),            # calculated in Python
			# using a constant!!!!!
			# (sum(national.data$totalAllAVG_VAC_R[i])/NUMTRACTS),
			(national.data$totalAllRES_VAC[i] / national.data$totalAllAMS_RES[i]),
			(national.data$totalAllAMS_RES[i]))

	} else {
		my.vector <- c(my.vector,0,0,0,0,0,0,
			#sum(national.data$totalAllAVG_VAC_R[i])/73767,0,0)	
			national.data$totalAllAVG_VAC_R[i],0,0)
	}	
	
	# append to the data frame
	my.df[i,] <- my.vector
	
	# reset the vector to empty
	my.vector = list()

}

head(my.df)

# ##################################################################
# plot the national level file
# ##################################################################

trace1 <- list(
  x = as.numeric(my.df$VAC_3_RESpc)*100, 
  y = my.df$Month.Year, 
  marker = list(color = "rgb(17, 78, 166)"), 
  name = "0-3 mo", 
  orientation = "h", 
  type = "bar", 
  uid = "063b98", 
  xsrc = "Dreamshot:4231:b631ec", 
  ysrc = "Dreamshot:4231:b4bc0c"
)
trace2 <- list(
  x = as.numeric(my.df$VAC_3_6_RESpc)*100,
  y = my.df$Month.Year, 
  marker = list(color = "rgb(41, 128, 171)"), 
  name = "3-6 mo", 
  orientation = "h", 
  type = "bar", 
  uid = "d2ea67", 
  xsrc = "Dreamshot:4231:9a1926", 
  ysrc = "Dreamshot:4231:b4bc0c"
)
trace3 <- list(
  x = as.numeric(my.df$VAC_6_12_RESpc)*100, 
  y = my.df$Month.Year, 
  marker = list(color = "rgb(104, 157, 46)"), 
  name = "6-12 mo", 
  orientation = "h", 
  type = "bar", 
  uid = "5e63a2", 
  xsrc = "Dreamshot:4231:2ec534", 
  ysrc = "Dreamshot:4231:b4bc0c"
)
trace4 <- list(
  x = as.numeric(my.df$VAC_12_24_RESpc)*100, 
  y = my.df$Month.Year, 
  marker = list(color = "rgb(36, 118, 23)"), 
  name = "12-24 mo", 
  orientation = "h", 
  type = "bar", 
  uid = "24f079", 
  xsrc = "Dreamshot:4231:c7663a", 
  ysrc = "Dreamshot:4231:b4bc0c"
)
trace5 <- list(
  x = as.numeric(my.df$VAC_24_36_RESpc)*100, 
  y = my.df$Month.Year, 
  marker = list(color = "rgb(169, 140, 31)"), 
  name = "24-36 mo", 
  orientation = "h", 
  type = "bar", 
  uid = "ae6448", 
  xsrc = "Dreamshot:4231:8f7c41", 
  ysrc = "Dreamshot:4231:b4bc0c"
)
trace6 <- list(
  x = as.numeric(my.df$VAC_36_RESpc)*100,
  y = my.df$Month.Year, 
  marker = list(color = "rgb(178, 81, 28)"), 
  name = "36+ mo", 
  orientation = "h", 
  type = "bar", 
  uid = "173fcb", 
  xsrc = "Dreamshot:4231:a324f1", 
  ysrc = "Dreamshot:4231:b4bc0c"
)

data <- list(trace1, trace2, trace3, trace4, trace5, trace6)

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
p <- plot_ly(width=layout$width,height=layout$height)
p <- add_trace(p, x=trace1$x, y=trace1$y, marker=trace1$marker, name=trace1$name, orientation=trace1$orientation, type=trace1$type, uid=trace1$uid, xsrc=trace1$xsrc, ysrc=trace1$ysrc)
p <- add_trace(p, x=trace2$x, y=trace2$y, marker=trace2$marker, name=trace2$name, orientation=trace2$orientation, type=trace2$type, uid=trace2$uid, xsrc=trace2$xsrc, ysrc=trace2$ysrc)
p <- add_trace(p, x=trace3$x, y=trace3$y, marker=trace3$marker, name=trace3$name, orientation=trace3$orientation, type=trace3$type, uid=trace3$uid, xsrc=trace3$xsrc, ysrc=trace3$ysrc)
p <- add_trace(p, x=trace4$x, y=trace4$y, marker=trace4$marker, name=trace4$name, orientation=trace4$orientation, type=trace4$type, uid=trace4$uid, xsrc=trace4$xsrc, ysrc=trace4$ysrc)
p <- add_trace(p, x=trace5$x, y=trace5$y, marker=trace5$marker, name=trace5$name, orientation=trace5$orientation, type=trace5$type, uid=trace5$uid, xsrc=trace5$xsrc, ysrc=trace5$ysrc)
p <- add_trace(p, x=trace6$x, y=trace6$y, marker=trace6$marker, name=trace6$name, orientation=trace6$orientation, type=trace6$type, uid=trace6$uid, xsrc=trace6$xsrc, ysrc=trace6$ysrc)
#p <- add_trace(p, x=trace7$x, y=trace7$y, marker=trace7$marker, name=trace7$name, orientation=trace7$orientation, type=trace7$type, uid=trace7$uid, xsrc=trace7$xsrc, ysrc=trace7$ysrc)
# removed 'bargroupgap', 'boxgap', 'boxgroupgap', 'boxmode' (deprecated?)
p <- layout(p, autosize=layout$autosize, bargap=layout$bargap, barmode=layout$barmode, dragmode=layout$dragmode, font=layout$font, hidesources=layout$hidesources, hovermode=layout$hovermode, legend=layout$legend, margin=layout$margin, paper_bgcolor=layout$paper_bgcolor, plot_bgcolor=layout$plot_bgcolor, separators=layout$separators, showlegend=layout$showlegend, smith=layout$smith, title=layout$title, titlefont=layout$titlefont, xaxis=layout$xaxis, yaxis=layout$yaxis)
p

# ##################################################################
# process the state level file
# ##################################################################

state.data <- read.csv(file="./HUD/state.csv", 
                          header=TRUE, 
                          quote = "\"",
                          sep=",")

# create empty list
my.vector = list()

# create empty data frame
my.df <- data.frame(matrix(ncol = ncol(state.data), 
                           nrow = nrow(state.data)))

colnames(my.df) <- c("Month.Year",
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

# rows contain GEOIDs as factors: $Var1, cols contain counts (occurrences): $Freq
my.table<- as.data.frame(table(as.factor(state.data$GEOID)))

for (i in 1:length(my.table[,1])) {
  
  # select each individual state
  my.subset = subset(state.data, GEOID == my.table[i,1])
  
  for (j in 1:length(my.subset$GEOID)) {
    
    # store off the month/year
    my.vector <- as.character(my.subset$Month.Year[j])
    
    # store off the geoid
    my.vector <- c(my.vector, my.subset$GEOID[1])
    
    if (my.subset$totalStateRES_VAC[j] != 0) {
      
      my.vector <- c(my.vector,
                   (my.subset$totalStateVAC_3_RES[j] / my.subset$totalStateRES_VAC[j]),
                   (my.subset$totalStateVAC_3_6_R[j] / my.subset$totalStateRES_VAC[j]),
                   (my.subset$totalStateVAC_6_12R[j] / my.subset$totalStateRES_VAC[j]),
                   (my.subset$totalStateVAC_12_24R[j] / my.subset$totalStateRES_VAC[j]),
                   (my.subset$totalStateVAC_24_36R[j] / my.subset$totalStateRES_VAC[j]),
                   (my.subset$totalStateVAC_36_RES[j] / my.subset$totalStateRES_VAC[j]),
                   (my.subset$totalStateAVG_VAC_R[j]),            # calculated in Python
                   # using a constant!!!!!
                   # (sum(my.subset$totalStateAVG_VAC_R[j])/NUMTRACTS),
                   (my.subset$totalStateRES_VAC[j] / my.subset$totalStateAMS_RES[j]),
                   (my.subset$totalStateAMS_RES[j]))
      
    } else {

      my.vector <- c(my.vector,0,0,0,0,0,0,
                   #sum(my.subset$totalStateAVG_VAC_R[j])/73767,0,0)	
                   my.subset$totalStateAVG_VAC_R[j],0,0)
    }
    
    # append to the data frame
    my.df[j,] <- my.vector
    
    # reset the vector to empty
    my.vector = list()
    
  }
  
}

# SOMETHIGN IS WRONG, BUT I'M TOO TIRED TO FIGURE OUT WHAT IT IS
head(my.df)
tail(my.df)

# ##################################################################
# plot the state level file
# ##################################################################

trace1 <- list(
  x = as.numeric(my.df$VAC_3_RESpc)*100, 
  y = my.df$Month.Year, 
  marker = list(color = "rgb(17, 78, 166)"), 
  name = "0-3 mo", 
  orientation = "h", 
  type = "bar", 
  uid = "063b98", 
  xsrc = "Dreamshot:4231:b631ec", 
  ysrc = "Dreamshot:4231:b4bc0c"
)
trace2 <- list(
  x = as.numeric(my.df$VAC_3_6_RESpc)*100,
  y = my.df$Month.Year, 
  marker = list(color = "rgb(41, 128, 171)"), 
  name = "3-6 mo", 
  orientation = "h", 
  type = "bar", 
  uid = "d2ea67", 
  xsrc = "Dreamshot:4231:9a1926", 
  ysrc = "Dreamshot:4231:b4bc0c"
)
trace3 <- list(
  x = as.numeric(my.df$VAC_6_12_RESpc)*100, 
  y = my.df$Month.Year, 
  marker = list(color = "rgb(104, 157, 46)"), 
  name = "6-12 mo", 
  orientation = "h", 
  type = "bar", 
  uid = "5e63a2", 
  xsrc = "Dreamshot:4231:2ec534", 
  ysrc = "Dreamshot:4231:b4bc0c"
)
trace4 <- list(
  x = as.numeric(my.df$VAC_12_24_RESpc)*100, 
  y = my.df$Month.Year, 
  marker = list(color = "rgb(36, 118, 23)"), 
  name = "12-24 mo", 
  orientation = "h", 
  type = "bar", 
  uid = "24f079", 
  xsrc = "Dreamshot:4231:c7663a", 
  ysrc = "Dreamshot:4231:b4bc0c"
)
trace5 <- list(
  x = as.numeric(my.df$VAC_24_36_RESpc)*100, 
  y = my.df$Month.Year, 
  marker = list(color = "rgb(169, 140, 31)"), 
  name = "24-36 mo", 
  orientation = "h", 
  type = "bar", 
  uid = "ae6448", 
  xsrc = "Dreamshot:4231:8f7c41", 
  ysrc = "Dreamshot:4231:b4bc0c"
)
trace6 <- list(
  x = as.numeric(my.df$VAC_36_RESpc)*100,
  y = my.df$Month.Year, 
  marker = list(color = "rgb(178, 81, 28)"), 
  name = "36+ mo", 
  orientation = "h", 
  type = "bar", 
  uid = "173fcb", 
  xsrc = "Dreamshot:4231:a324f1", 
  ysrc = "Dreamshot:4231:b4bc0c"
)

data <- list(trace1, trace2, trace3, trace4, trace5, trace6)

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
p <- plot_ly(width=layout$width,height=layout$height)
p <- add_trace(p, x=trace1$x, y=trace1$y, marker=trace1$marker, name=trace1$name, orientation=trace1$orientation, type=trace1$type, uid=trace1$uid, xsrc=trace1$xsrc, ysrc=trace1$ysrc)
p <- add_trace(p, x=trace2$x, y=trace2$y, marker=trace2$marker, name=trace2$name, orientation=trace2$orientation, type=trace2$type, uid=trace2$uid, xsrc=trace2$xsrc, ysrc=trace2$ysrc)
p <- add_trace(p, x=trace3$x, y=trace3$y, marker=trace3$marker, name=trace3$name, orientation=trace3$orientation, type=trace3$type, uid=trace3$uid, xsrc=trace3$xsrc, ysrc=trace3$ysrc)
p <- add_trace(p, x=trace4$x, y=trace4$y, marker=trace4$marker, name=trace4$name, orientation=trace4$orientation, type=trace4$type, uid=trace4$uid, xsrc=trace4$xsrc, ysrc=trace4$ysrc)
p <- add_trace(p, x=trace5$x, y=trace5$y, marker=trace5$marker, name=trace5$name, orientation=trace5$orientation, type=trace5$type, uid=trace5$uid, xsrc=trace5$xsrc, ysrc=trace5$ysrc)
p <- add_trace(p, x=trace6$x, y=trace6$y, marker=trace6$marker, name=trace6$name, orientation=trace6$orientation, type=trace6$type, uid=trace6$uid, xsrc=trace6$xsrc, ysrc=trace6$ysrc)
#p <- add_trace(p, x=trace7$x, y=trace7$y, marker=trace7$marker, name=trace7$name, orientation=trace7$orientation, type=trace7$type, uid=trace7$uid, xsrc=trace7$xsrc, ysrc=trace7$ysrc)
# removed 'bargroupgap', 'boxgap', 'boxgroupgap', 'boxmode' (deprecated?)
p <- layout(p, autosize=layout$autosize, bargap=layout$bargap, barmode=layout$barmode, dragmode=layout$dragmode, font=layout$font, hidesources=layout$hidesources, hovermode=layout$hovermode, legend=layout$legend, margin=layout$margin, paper_bgcolor=layout$paper_bgcolor, plot_bgcolor=layout$plot_bgcolor, separators=layout$separators, showlegend=layout$showlegend, smith=layout$smith, title=layout$title, titlefont=layout$titlefont, xaxis=layout$xaxis, yaxis=layout$yaxis)
p
