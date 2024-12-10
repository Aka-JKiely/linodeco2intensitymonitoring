#!/bin/bash

# Configuration parameters
EMAPS_API_TOKEN="INSERT_ELECTRICTY_MAPS_API_KEY_HERE"
INFLUXDB_URL="http://127.0.0.1:8086"
INFLUXDB_TOKEN="INSERT_INFLUXDB_API_KEY_HERE"
INFLUXDB_ORG="Akamai"
CSV_FILE="/scripts/co2intensitymonitoring/linode_akamai_locations_grid.csv"

# Function to check if a bucket exists in InfluxDB
check_and_create_bucket() {
  local bucket_name=$1
  bucket_exists=$(influx bucket list -o "$INFLUXDB_ORG" -t "$INFLUXDB_TOKEN" | grep -w "$bucket_name")

  if [ -z "$bucket_exists" ]; then
    echo "Bucket $bucket_name does not exist. Creating it."
    influx bucket create -n "$bucket_name" -o "$INFLUXDB_ORG" -t "$INFLUXDB_TOKEN"
  else
    echo "Bucket $bucket_name already exists."
  fi
}

# Read locations from CSV file and process each one
while IFS=, read -r location country_code zone_name display_name; do
  if [ "$location" != "Location" ]; then
    echo "Processing location: $zone_name with DisplayName: $display_name"

    # Define InfluxDB bucket name for the location (use the Location column)
    INFLUXDB_BUCKET="$location"

    # Check if the bucket exists and create it if necessary
    check_and_create_bucket "$INFLUXDB_BUCKET"

    # Fetch CO2 intensity data for the location using DisplayName
    URL="https://api.electricitymap.org/v3/carbon-intensity/latest?zone=${display_name}"
    response=$(curl -s -H "auth-token: ${EMAPS_API_TOKEN}" "${URL}")

    # Extract relevant fields from the JSON response
    carbonIntensity=$(echo "$response" | jq '.carbonIntensity')
    datetime=$(echo "$response" | jq -r '.datetime')
    zone=$(echo "$response" | jq -r '.zone')

    # Convert datetime to Unix timestamp (seconds)
    timestamp=$(date -d "$datetime" +%s)

    # Escape spaces in tag values (e.g., location)
    escaped_location=$(echo "$zone_name" | sed 's/ /\\ /g')

    # Write data to the InfluxDB bucket
    curl -i -XPOST "${INFLUXDB_URL}/api/v2/write?org=${INFLUXDB_ORG}&bucket=${INFLUXDB_BUCKET}&precision=s" \
    --header "Authorization: Token ${INFLUXDB_TOKEN}" \
    --data-binary "co2_intensity,location=${escaped_location},zone=${zone} value=${carbonIntensity} ${timestamp}"

  fi
done < "$CSV_FILE"
