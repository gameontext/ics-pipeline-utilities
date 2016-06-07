#!/bin/bash

pipeline_utils/icsDeploy.sh

source $DEPLOY_PROPERTY_FILE

sed s/WEBSOCKET_ENDPOINT/${TEST_IP}:${TEST_PORT}/ registrationTemplate.json > reg.json

echo "REG file:"
cat reg.json
echo "FILE END"

export JAVA_HOME=$JAVA8_HOME
export PATH=$JAVA_HOME/bin:$PATH
java -cp regutil-app.jar net.wasdev.gameon.util.RegistrationUtility -m=POST -i=${GAMEON_USERID} -s=${GAMEON_SHARED_SECRET}  reg.json

