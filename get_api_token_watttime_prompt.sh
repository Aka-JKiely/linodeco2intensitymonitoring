#!/bin/bash

# Prompt for user credentials
read -p "Enter your username: " USERNAME
read -sp "Enter your password: " PASSWORD
echo

# API endpoint
LOGIN_URL="https://api.watttime.org/v2/login"

# Send GET request with Basic Authentication
response=$(curl --silent --request GET \
                --url "$LOGIN_URL" \
                --user "$USERNAME:$PASSWORD")

# Extract token from response
TOKEN=$(echo "$response" | jq -r '.token')

# Check if token extraction was successful
if [ "$TOKEN" != "null" ]; then
    echo "Authentication successful. Token: $TOKEN"
else
    echo "Authentication failed. Response: $response"
fi
