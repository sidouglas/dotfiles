#!/bin/bash

curl -s\
 --form-string "token=${PUSHOVER_APP_TOKEN}"\
 --form-string "user=${PUSHOVER_USER_KEY}"\
 --form-string "message=$1" https://api.pushover.net/1/messages.json > /dev/null
