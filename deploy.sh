#!/bin/bash
# TechEazy - Assignment 1: Lift & Shift Deployment
# Usage: ./deploy.sh Dev  OR ./deploy.sh Prod

set -e  # Exit if any command fails

STAGE=$1
if [ -z "$STAGE" ]; then
  echo "❌ Stage parameter missing! Usage: ./deploy.sh Dev|Prod"
  exit 1
fi

# Load config file based on stage
CONFIG_FILE="${STAGE,,}_config"   # dev_config or prod_config
if [ ! -f "$CONFIG_FILE" ]; then
  echo "❌ Config file $CONFIG_FILE not found!"
  exit 1
fi

source $CONFIG_FILE

echo "🚀 Starting deployment for stage: $STAGE"
echo "📦 Using config: $CONFIG_FILE"

# Update and install dependencies
sudo apt update -y
sudo apt install -y openjdk-${JAVA_VERSION}-jdk git maven

echo "✅ Java installed: $(java -version 2>&1 | head -n 1)"
echo "✅ Maven installed: $(mvn -version 2>&1 | head -n 1)"

# Clone the repo
if [ ! -d "test-repo-for-devops" ]; then
  git clone $REPO_URL
fi
cd test-repo-for-devops

# Build the project
mvn clean package -DskipTests

# Kill any existing process on port 80
sudo fuser -k 80/tcp || true

# Run app in background
JAR_FILE=target/techeazy-devops-0.0.1-SNAPSHOT.jar
if [ -f "$JAR_FILE" ]; then
  echo "🚀 Running app..."
  sudo nohup java -jar $JAR_FILE --server.port=80 > app.log 2>&1 &
  echo $! > app.pid
else
  echo "❌ JAR file not found!"
  exit 1
fi

# Wait and check if running
sleep 10
APP_STATUS=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:80 || true)
if [ "$APP_STATUS" == "200" ] || [ "$APP_STATUS" == "302" ]; then
  echo "✅ App is running at: http://$(curl -s http://checkip.amazonaws.com):80"
else
  echo "❌ App failed to start. Check app.log"
fi

# Auto stop after configured time
if [ ! -z "$STOP_AFTER" ]; then
  echo "⏳ Instance will stop after $STOP_AFTER seconds"
  nohup bash -c "sleep $STOP_AFTER && sudo shutdown -h now" &
fi
