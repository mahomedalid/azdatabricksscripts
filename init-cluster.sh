#!/bin/bash

# Requirements:
# * Azure CLI, https://docs.microsoft.com/en-us/cli/azure/
# * BASH
# * Databricks cli, https://docs.microsoft.com/en-us/azure/databricks/dev-tools/cli/

CLUSTER_NAME="default"
SCRIPT_DIR=`dirname "$0"`
CLUSTER_LIBRARIES_FILE="$SCRIPT_DIR/clusters/libraries.txt"
CLUSTER_DEFINITION_FILE="$SCRIPT_DIR/clusters/default.json"

WAIT_SECONDS=30

while getopts :a:l:d:n:c: option
do
    case "${option}" in
    a) DATABRICKS_PROFILE_NAME=${OPTARG};;
    l) CLUSTER_LIBRARIES_FILE=${OPTARG};;
    d) CLUSTER_DEFINITION_FILE=${OPTARG};;
    n) CLUSTER_NAME=${OPTARG};;
    c) SPARK_CONF_FILE=${OPTARG};;
    esac
done

#CLUSTER_LIBRARIES=("com.microsoft.azure:azure-eventhubs-spark_2.12:2.3.18" "com.microsoft.azure:spark-mssql-connector_2.12:1.2.0")
readarray -t CLUSTER_LIBRARIES < $CLUSTER_LIBRARIES_FILE

echo "- Creating databricks cluster"

DB_CLUSTER_IDS=`databricks clusters list --profile $DATABRICKS_PROFILE_NAME | grep $CLUSTER_NAME | grep -v TERMINATED | awk '{ print $1 }'`

if [ -z "$DB_CLUSTER_IDS" ]
then
  echo " ... no existing cluster $CLUSTER_NAME found, creating a new one ..."

  if [ -z "$SPARK_CONF_FILE" ]; then
    CLUSTER_DEFINITION=`cat "$CLUSTER_DEFINITION_FILE" | jq -c --arg CLUSTER_NAME $CLUSTER_NAME '(.cluster_name) |= $CLUSTER_NAME'`
  else
    echo "- Configuration file $SPARK_CONF_FILE provided loading content, remember to not store secrets in this file ..."
    SPARK_CONTENT=`cat $SPARK_CONF_FILE`
    echo " "
    echo "  * Configuration: "
    echo $SPARK_CONTENT | jq -c
    CLUSTER_DEFINITION=`cat "$CLUSTER_DEFINITION_FILE" | jq -c --arg CLUSTER_NAME $CLUSTER_NAME ".spark_conf |= . + $SPARK_CONTENT | (.cluster_name) |= \\\$CLUSTER_NAME"`
  fi  
  echo " "
  echo "  * Cluster Definition: "
  echo $CLUSTER_DEFINITION | jq
  echo "- Creating cluster ..."
  databricks clusters create --profile $DATABRICKS_PROFILE_NAME --json "${CLUSTER_DEFINITION}"
  echo " ... waiting $WAIT_SECONDS seconds for the cluster to start ..."
  sleep $WAIT_SECONDS
else
  echo " ... success: cluster $CLUSTER_NAME exists and is not TERMINATED. ID(s): ${DB_CLUSTER_IDS}"
fi

echo " - Installing databricks cluster libraries"

for CLUSTER_ID in $(databricks clusters list --profile $DATABRICKS_PROFILE_NAME | grep $CLUSTER_NAME | grep -v TERMINATED | awk '{ print $1 }')
do
  echo "        ... $CLUSTER_ID"
  for CLUSTER_LIBRARY in "${CLUSTER_LIBRARIES[@]}"
  do
    echo "           ... $CLUSTER_LIBRARY"
    databricks --profile $DATABRICKS_PROFILE_NAME libraries install \
        --maven-coordinates "$CLUSTER_LIBRARY" \
        --cluster-id $CLUSTER_ID
  done
done