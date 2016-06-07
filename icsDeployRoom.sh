#!/bin/bash

echo "To run this script you will need to set the following:"
echo "DEPLOY_PROPERTY_FILE=a location for the dpeloyment pipeline to place deployment info."
echo "GAMEON_USERID=The full userID in Gameon. You can find this in your profile"
echo "GAMEON_SHARED_SECRECT=Your shared secret. You can find this near your full ID in you GameOn profile"

pipeline_utils/icsDeploy.sh

source $DEPLOY_PROPERTY_FILE

sed s/WEBSOCKET_ENDPOINT/${TEST_IP}:${TEST_PORT}/ registrationTemplate.json > reg.json

echo "REG file:"
cat reg.json
echo "FILE END"

export JAVA_HOME=$JAVA8_HOME
export PATH=$JAVA_HOME/bin:$PATH
java -cp regutil-app.jar net.wasdev.gameon.util.RegistrationUtility -m=POST -i=${GAMEON_USERID} -s=${GAMEON_SHARED_SECRET}  reg.json > create.log

if [ "$?" != "0" ]; then
  grep -q "(exit code = 409)" create.log
  if [ "$?" == "0" ]; then
    java -cp regutil-app.jar net.wasdev.gameon.util.RegistrationUtility -m=PUT -i=${GAMEON_USERID} -s=${GAMEON_SHARED_SECRET}  reg.json > update.log
    if [ "$?" != "0" ]; then
      echo "Update attempt failed"
      cat update.log
      exit 1
    else
      echo "Update suceeded"
      exit 0
    fi
  else
    echo "Request failed"
    cat create.log
    exit 1
  fi
fi
echo "Registration successful"
exit 0
