# VacanciesVisualization
This project seeks to develop a data visualization of vacant residence data from Housing and Urban Development (HUD) data.

An initial attempt to use R to both process and visualize the data has failed (see PlotVacantVsTotalUnits.R Version 2).

The plan is to use Python to summarize the data, and R to visualize it.

Summarization of the data involves calculating summary percentages aggregated at multiple spatial scales:  national, state, county.  The data is already available at individual Census Tract level.

The resulting summary data will then be imported into an R script for developing an R Shiny visualization.

IMPORTANT:  the HUD data is not open source, and will not be included in this repository.  In order to access the HUD data, you must register with HUD for your own access.

See:  https://www.huduser.gov/portal/datasets/usps.html
