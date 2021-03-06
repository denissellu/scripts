#!/bin/bash
# Install a custom DynamoDB version - https://docs.aws.amazon.com/amazondynamodb/latest/developerguide/DynamoDBLocal.DownloadingAndRunning.html
#
# To run this script on Codeship, add the following
# command to your project's setup commands:
# \curl -sSL https://raw.githubusercontent.com/codeship/scripts/master/packages/dynamodb.sh | bash -s
#
# Add the following environment variables to your project configuration
# (otherwise the defaults below will be used).
# * DYNAMODB_VERSION
# * DYNAMODB_PORT
#
DYNAMODB_VERSION=${DYNAMODB_VERSION:="latest"}
DYNAMODB_PORT=${DYNAMODB_PORT:="8000"}
DYNAMODB_DIR=${DYNAMODB_DIR:="$HOME/dynamodb"}
DYNAMODB_WAIT_TIME=${DYNAMODB_WAIT_TIME:="10"}

set -e
CACHED_DOWNLOAD="${HOME}/cache/dynamodb_local_${DYNAMODB_VERSION}.tar.gz"

mkdir -p "${DYNAMODB_DIR}"
wget --continue --output-document "${CACHED_DOWNLOAD}" "https://s3-us-west-2.amazonaws.com/dynamodb-local/dynamodb_local_${DYNAMODB_VERSION}.tar.gz"
tar -xaf "${CACHED_DOWNLOAD}" --directory "${DYNAMODB_DIR}"

# Make sure to use the exact parameters you want for DynamoDB and give it enough sleep time to properly start up
(
  cd ${DYNAMODB_DIR} || exit 1
  bash -c "java -Djava.library.path=./DynamoDBLocal_lib -jar DynamoDBLocal.jar -sharedDb -inMemory -port ${DYNAMODB_PORT} 2>&1 >/dev/null" >/dev/null & disown
  sleep "${DYNAMODB_WAIT_TIME}"
)
