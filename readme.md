Readme File 

This repo contains the colleteral necessary to deploy your own CO2 Electricty Grid Intensity monitor for Akamai Cloud Computing. 

More details available on this resources:

Blog Post link: 
Youtube Instructional Video Link: 

Here are list of the files contained and there are usage: 

1) readme.readme - This file here :) 
2) LinodeCO2EmissionsDashboard.json - example Grafana dashboard that displays various statistics around the electricty in terms of CO2 grams equivalent per KwH of electricity used.
3) fetch_co2_data.sh -bash script to query Electricity Maps API to get current CO2 Intensity of grid in use 
4) linode_akamai_locations_grid.csv - mapping of Linode Global Core Cloud Compute Locations against Electricity Grids 
5) zones.csv - list of electricity zones from Electricity Maps including country code and grid operator name. 


EmissionsDashboardSample.png
![Alt text](EmissionsDashboardSample.png)

