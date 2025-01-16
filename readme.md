# Readme File 

This repo contains the colleteral necessary to deploy your own CO2 Electricty Grid Intensity monitor for Akamai Cloud Computing. 

Here are list of the files contained and there are usage: 

1) readme.readme - This file here :) 
2) LinodeCO2EmissionsDashboard.json - example Grafana dashboard that displays various statistics around the electricty in terms of CO2 grams equivalent per KwH of electricity used.
3) fetch_co2_data.sh -bash script to query Electricity Maps API to get current CO2 Intensity of grid in use 
4) linode_akamai_locations_grid.csv - mapping of Linode Global Core Cloud Compute Locations against Electricity Grids 
5) zones.csv - list of electricity zones from Electricity Maps including country code and grid operator name. 


## How it works 

Follow the instructions below which how to run the stackscript which will setup the basic Grafana and InfluxDB stack. 
The fetch_co2_data.sh is scheduled to run every hour in crontab to collect data from Electricity Maps API, updates to Electricity Maps data are currently every hour. The data is placed in buckets in the InfluxDB instance according to the Linode given name for a location example us-southeast as per the Linode API. 
The dashboard LinodeCO2EmissionsDashboard.json gives an example of a few graphs for some locations, simply copy the charts and make new ones for new locations by modifying the bucket that is being queried and also changing the title on the charts to reflect the bucket change. 
linode_akamai_locations_grid.csv is a mapping between the regions in Electricity Maps and the Akamai Core Cloud Compute locations. 

Here is a list of 15/1/25 of the sites and the corresponding buckets.
This list is maintained in linode_akamai_locations_grid.csv
The influxDB bucket uses the standard Linode Location ID in the first column below. 

| Location       | Country Code | Zone Name                          | Display Name   |
|----------------|--------------|------------------------------------|----------------|
| us-southeast   | US           | Southern Company Services          | US-SE-SOCO     |
| us-ord         | US           | PJM interconnection                | US-MIDA-PJM    |
| us-central     | US           | Electric Reliability Council of Texas | US-TEX-ERCO |
| us-west        | US           | California ISO                     | US-CAL-CISO    |
| us-lax         | US           | California ISO                     | US-CAL-CISO    |
| us-mia         | US           | City of Homestead                  | US-FLA-HST     |
| us-east        | US           | PJM interconnection                | US-MIDA-PJM    |
| us-sea         | US           | Puget Sound Energy                 | US-NW-PSEI     |
| us-iad         | US           | PJM interconnection                | US-MIDA-PJM    |
| ca-central     | CA           | Ontario                            | CA-ON          |
| nl-ams         | NL           | Netherlands                        | NL             |
| it-mil         | IT           | Central North Italy                | IT-CNO         |
| eu-west        | UK           | Great Britain                      | GB             |
| gb-lon         | UK           | Great Britain                      | GB             |
| fr-par         | FR           | France                             | FR             |
| es-mad         | ES           | Spain                              | ES             |
| eu-central     | DE           | Germany                            | DE             |
| de-fra-2       | DE           | Germany                            | DE             |
| se-sto         | SE           | South Central Sweden               | SE-SE3         |
| sg-sin-2       | SG           | Singapore                          | SG             |
| jp-osa         | JP           | Kansai                             | JP-KN          |
| ap-northeast   | JP           | Tokyo                              | JP-TK          |
| jp-tyo-3       | JP           | Tokyo                              | JP-TK          |
| in-maa         | IN           | Southern India                     | IN-SO          |
| in-bom-2       | IN           | Western India                      | IN-WE          |
| id-cgk         | ID           | Indonesia                          | ID             |
| br-gru         | BR           | South Brazil                       | BR-S           |
| ap-southeast   | AU           | New South Wales                    | AU-NSW         |
| au-mel         | AU           | Victoria                           | AU-VIC         |



EmissionsDashboardSample.png
![Alt text](EmissionsDashboardSample.png)

THe sample dashboard can be modified with new charts for different locations, just copy the chart and change the InfuxDB bucket with the desired new location, eu-west as an example here:

### Example Flux Query

```flux
from(bucket: "**`eu-west`**")
  |> range(start: -30d)  // Adjust time range as needed
  |> filter(fn: (r) => r._measurement == "co2_intensity")
  |> filter(fn: (r) => r._field == "value")
  |> aggregateWindow(every: 5m, fn: mean, createEmpty: false)  // Aggregate by 5-minute intervals
  |> yield(name: "mean")
```


## Linode Firewall Requirements 

In order to access the deployment there are number of ports in use 

InfluxDB - Port 8086 

Grafana - Port 3000

SSH - Port 22 (required for command line access to the instance) 

## How to Deploy 

1. Find the stackscript called AkamaiConnectedCloudElectricityEmissionsTracker
2. Select Deploy new Linode
3. Enter various passowrd and username entries, select a shared instance type shared CPU, a nanode is enough resources. VPC and VLAN is not required. Backup is optional. Select a infosec complaint firewall. 
4. Allow the Linode to provision and then note the Public IP address on the node that has been assigned
5. Using the public IP provisioned on the Linode first login to the InfluxDB instance to provision using a browser e.g. X.X.X.X:8086 (make sure the Linode Firewall allows access from your public IP to port 8086 on your laptop whatsmpip.org) 
6. Click Get Started and setup a username, password, Initial Org Name and Initial Bucket Name for the InfluxDB instance
7. Copy the API token key provided by the InfluxDB instance
8. Next login to the Grafana Instance on the same public provisioned on your Linode instance on port 3000 X.X.X.X:3000 enter username/password configured during stackscript provisioning
9. Click Connections on the left hand menu and select Add New Connection, search for InfluxDB and "add new data source"
10. On the InfluxDB DataSources select the following config 1) Query Language: Flux 2) HTTP URL http://127.0.0.1:8086 where X.X.X.X is the public of the linode instance 3) timeout 600 seconds 4) deselect basic auth 5) InflxuDB details Organisation configured on INfluxDB setup in step 6, Token API Token for InfluxDB got in Step 7 7) click save and test, you should recieve a message that says "datasource is working, 3 buckets found"
11. Go to dashboards in Grafana and Click Create new Dashboard, then click import a dashboard, copy and paste the json code here: https://github.com/Aka-JKiely/co2intensitymonitoring/blob/main/LinodeCO2EmissionsDashboard.json, this should import a dashboard called Linode Regions CO2 Dashboard Overview
12. Next ssh to the Public of the Linode instance and navigate to the directory /scripts/co2intensitymonitoring, there should be 2 files linode_akamai_locations_grid.csv and fetch_co2_data.sh
13. Create an API key for Electricty Maps using this link: https://api-portal.electricitymaps.com/ using the free tier, email address required.
14. Copy the contents of the script here in to fetch_co2_data.sh
15. Modify the values here: # Configuration parameters
EMAPS_API_TOKEN="INSERT_ELECTRICTY_MAPS_API_KEY_HERE"
INFLUXDB_URL="http://127.0.0.1:8086"
INFLUXDB_TOKEN="INSERT_INFLUXDB_API_KEY_HERE"
INFLUXDB_ORG="Akamai"
CSV_FILE="/scripts/co2intensitymonitoring/linode_akamai_locations_grid.csv"
to the Electricity Maps API Token key and also the InfluxDB Token Key and the InfluxDB Org if different from default "Akamai" in the script.
16. Test the script at the command line: bash -x fetch_co2_data.sh
17. Check crontab (crontab -l: */30 * * * * /scripts/co2intensitymonitoring/fetch_co2_data.sh) Check InfluxDB buckets for data
18. Refresh charts in Grafana to see data points in preconfigured sample locations.
19. Add new charts by copying and pasting and modifying bucket name to get desired Linode locations.
    

## Some known limitations 

- This is using the free tier of Electricity Maps which only provides the current live data for forecasted CO2 Intensity of the grids it is required to have a paid for subscription to Electricity Maps API https://www.electricitymaps.com/free-tier-api 
- In Electricity Maps some grids and Akamai Cloud Compute Locations do not have real time CO2 intensity information, example Jakarta, IN
- 
  


