#!/bin/bash

# Prompt for user details
read -p "Enter your desired username: " USERNAME
read -sp "Enter your desired password: " PASSWORD
echo
read -p "Enter your email address: " EMAIL
read -p "Enter your organization: " ORG

# API endpoint
REGISTER_URL="https://api.watttime.org/register"

# JSON payload
JSON_PAYLOAD=$(jq -n \
                  --arg user "$USERNAME" \
                  --arg pass "$PASSWORD" \
                  --arg email "$EMAIL" \
                  --arg org "$ORG" \
                  '{username: $user, password: $pass, email: $email, org: $org}')

# Send POST request
response=$(curl --silent --request POST \
                --url "$REGISTER_URL" \
                --header "Content-Type: application/json" \
                --data "$JSON_PAYLOAD")

# Output response
echo "Response from WattTime API:"
echo "$response"
