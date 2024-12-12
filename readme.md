# Readme File 

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


## How it works 

The fetch_co2_data.sh is scheduled to run every half an hour to collect data from Electricity Maps API, the actual update to Electricity Maps data is currently every hour. The data is placed in buckets in the InfluxDB instance according to the Linode given name for a location example us-southeast as per the Linode API. 
The dashboard LinodeCO2EmissionsDashboard.json gives an example of a few graphs for some locations, simply copy the charts and make new ones for new locations by modifying the bucket that is being queried and also changing the title on the charts to reflect the bucket change. 



EmissionsDashboardSample.png
![Alt text](EmissionsDashboardSample.png)


## Firewall Requirements 

In order to access the deployment there are number of ports in use 

InfluxDB - Port 8086 
Grafana - Port 3000
SSH - Port 22 (required for command line access to the instance) 


## Some known limitations 

- This is using the free tier of Electricity Maps which only provides the current live data for forecasted CO2 Intensity of the grids it is required to have a paid for subscription to Electricity Maps API https://www.electricitymaps.com/free-tier-api 
- Some grids and Akamai Cloud Compute Locations do not have real time CO2 intensity information, example Jakarta, IN
  


