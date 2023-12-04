#!/usr/bin/env bash

#set -x

vendir sync
. ./vendir/demo-magic/demo-magic.sh
export TYPE_SPEED=100
export DEMO_PROMPT="${GREEN}➜ ${CYAN}\W ${COLOR_RESET}"
TEMP_DIR=upgrade-example
PROMPT_TIMEOUT=5

function talkingPoint() {
  wait
  clear
}

# Initialize SDKMAN and install required Java versions
function initSDKman() {
  local sdkman_init="${SDKMAN_DIR:-$HOME/.sdkman}/bin/sdkman-init.sh"
  if [[ -f "$sdkman_init" ]]; then
    source "$sdkman_init"
  else
    echo "SDKMAN not found. Please install SDKMAN first."
    exit 1
  fi
  sdk update
  sdk install java 8.0.392-librca
  sdk install java 21.0.1-librca
}

function init {
  rm -rf $TEMP_DIR
  mkdir $TEMP_DIR
  cd $TEMP_DIR || exit
  clear
}

# Switch to Java 8 and display version
function useJava8 {
  displayMessage "Use Java 8, this is for educational purposes only, don't do this at home! (I have jokes.)"
  pei "sdk use java 8.0.392-librca"
  pei "java -version" 
}

function useJava21 {
  echo "#### Java 21 is GA so lets switch to Java 21"
  echo ""
  pei "sdk use java 21.0.1-librca"
  pei "java -version"
}

# Clone a simple Spring Boot application
function cloneApp {
  displayMessage "Clone a Spring Boot 2.7.0 application."
  pei "git clone https://github.com/dashaun/hello-spring-boot-2-7.git ./"
}

# Start the Spring Boot application
function springBootStart {
  displayMessage "Start the Spring Boot application"
  pei "./mvnw -q clean package spring-boot:start -Dfork=true -DskipTests 2>&1 | tee '$1' &"
  PROMPT_TIMEOUT=15
}

# Stop the Spring Boot application
function springBootStop {
  displayMessage "Stop the Spring Boot application"
  pei "./mvnw spring-boot:stop -Dfork=true"
}

# Check the health of the application
function validateApp {
  displayMessage "Check application health"
  pei "http :8080/actuator/health"
  PROMPT_TIMEOUT=5
}

# Display memory usage of the application
function showMemoryUsage {
  local pid=$1
  local log_file=$2
  local rss=$(ps -o rss= "$pid" | tail -n1)
  local mem_usage=$(bc <<< "scale=1; ${rss}/1024")
  echo "The process was using ${mem_usage} megabytes"
  echo "${mem_usage}" >> "$log_file"
}

function rewriteApplication {
  echo "#### Use the Spring Boot Migrator"
  echo "#### To upgrade to the latest version of Spring Boot"
  echo ""
  pei "java -jar --add-opens 'java.base/sun.nio.ch=ALL-UNNAMED' --add-opens 'java.base/java.io=ALL-UNNAMED'  ../vendir/spring-boot-migrator/spring-boot-upgrade.jar ./"
}

# Display a message with a header
function displayMessage() {
  echo "#### $1"
  echo ""
}

initSDKman
init
useJava8
talkingPoint
cloneApp
talkingPoint
springBootStart java8with2.7.log
talkingPoint
validateApp
talkingPoint
showMemoryUsage "$(jps | grep 'HelloSpringApplication' | cut -d ' ' -f 1)" java8with2.7.log2
talkingPoint
springBootStop
talkingPoint
useJava21
rewriteApplication