#!/bin/bash
# File: bin/notify_deployment.sh
# This script sends a POST request with the Heroku app name.
# Make sure this file is executable by running: chmod +x bin/notify_deployment.sh

# Exit immediately if a command fails, to ensure the deployment is marked as failed if the script errors out.
set -e

# The endpoint to send the notification to.
NOTIFICATION_ENDPOINT="https://aa-admin-2cb242e66780.herokuapp.com/heroku-app-deploy-events"

# The HEROKU_APP_NAME environment variable is automatically set by Heroku in the postdeploy environment.
# We check if it's set and provide a fallback just in case.
APP_NAME=${HEROKU_APP_NAME:-"unknown_app"}
DEPLOYMENT_SOURCE=${1:-"unknown"}
DEPLOY_ID=${DEPLOY_ID:-"unknown"}

echo "---"
echo "Starting deployment notification script."
echo "App Name: $APP_NAME"
echo "Sending notification to: $NOTIFICATION_ENDPOINT"
echo "---"

# Construct the JSON payload. Using a heredoc makes it easy to write multi-line JSON.
JSON_PAYLOAD=$(cat <<EOF
{
  "source": "$DEPLOYMENT_SOURCE",
  "app_name": "$APP_NAME",
  "deploy_id": "$DEPLOY_ID",
  "deployed_at": "$(date -u +%Y-%m-%dT%H:%M:%SZ)"
}
EOF
)

# Use curl to send the POST request.
# -X POST: Specifies the request method.
# -H "Content-Type: application/json": Sets the content type header.
# -d "$JSON_PAYLOAD": Provides the data for the request body.
# --fail: Makes curl exit with an error code if the HTTP request fails (e.g., 4xx or 5xx response).
curl --fail --location -X POST \
  -H "Content-Type: application/json" \
  -d "$JSON_PAYLOAD" \
  "$NOTIFICATION_ENDPOINT"

echo "---"
echo "Deployment notification sent successfully."
echo "---"

