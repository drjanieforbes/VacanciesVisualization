# VacanciesVisualization
This project seeks to develop a visualization of vacant residence data from Housing and Urban Development (HUD) data.

An initial attempt to use R to both process and visualize the data failed. Python is just better at text processing than R.  However, R is better at reading .dbf files.

The plan uses Python to munge and summarize the data, and then R to visualize it.

Summarization of the data involves calculating summary percentages aggregated at multiple spatial scales:  national, state, county.  The data is already available at individual Census Tract level.  These calculations are performed in Python.

The resulting summary data is then imported into an R script for developing an R Shiny visualization.

IMPORTANT:  the HUD data is not open source, and will not be included in this repository.  In order to access the HUD data, you must register with HUD for your own access.

See:  https://www.huduser.gov/portal/datasets/usps.html
