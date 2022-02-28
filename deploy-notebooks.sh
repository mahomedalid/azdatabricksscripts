#!/bin/bash

DATABRICKS_NOTEBOOK_PATH="/Shared/Default"
SCRIPT_DIR=`dirname "$0"`
NOTEBOOK_DIR="${SCRIPT_DIR}/notebooks/"
OVERRIDE=true

while getopts :a:p:n:o: option
do
    case "${option}" in
    a) DATABRICKS_PROFILE_NAME=${OPTARG};;
    p) DATABRICKS_NOTEBOOK_PATH=${OPTARG};;
    n) DATABRICKS_PROFILE_NAME=${OPTARG};;
    o) OVERRIDE=${OPTARG};;
    esac
done

if [ -z "$DATABRICKS_PROFILE_NAME" ]; then
    echo "usage: $0 -a <profile name> [-p workspace_notebook_path] [-n local_notebook_dir] [-o true|false]"
    echo " ex.: $0 -u aad -p '/Shared/MyFolder' -n './notebooks' -o false"
    echo " "
    echo " Arguments "
    echo "  -a  : Databricks profile to be used. "
    echo "  -p  : Databricks Workspace notebook path. If does not exists will be created."
    echo "        Default: /Shared/Default."
    echo "  -a  : Local directory of notebooks to be deployed. "
    echo "        Default: ${SCRIPT_DIR}/notebooks/"
    echo "  -o  : If folder exists override notebook. Allowed values: true or false."
    echo "        Default: true"
    exit 1
fi

echo "- Deploying databricks notebooks"

if [ "$OVERRIDE" = false ] ; then
    echo " ... checking if ${DATABRICKS_NOTEBOOK_PATH} notebooks exists"

    databricks --profile ${DATABRICKS_PROFILE_NAME} workspace ls ${DATABRICKS_NOTEBOOK_PATH} $2>/dev/null

    if [ $? -eq 0 ]
    then
      echo " ... success: notebook folder exists in the workspace. Skipping."
      exit 0
    fi
fi

databricks --profile ${DATABRICKS_PROFILE_NAME} workspace import_dir ${NOTEBOOK_DIR} ${DATABRICKS_NOTEBOOK_PATH} -o