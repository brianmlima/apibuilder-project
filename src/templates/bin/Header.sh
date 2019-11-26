#!/usr/bin/env bash
BIN_DIR="$( cd -P "$( dirname "${SOURCE}" )" && pwd )" ;
PROJECT_HOME="$( cd -P "${BIN_DIR}/../" && pwd )"
CONF_HOME="${PROJECT_HOME}"
################################################################################
################################################################################
source ${BIN_DIR}/Functions.sh
################################################################################
###############################################################################
#Import project-config.yaml
eval $(parse_yaml ${PROJECT_HOME}/project-config.yaml "conf_")

function pushApiJson(){
    printMSG "${INFO} Moving to working directory at ${PROJECT_HOME}"
    pushd ${PROJECT_HOME} > /dev/null ;
        apibuilder upload \
        ${conf_apibuilder_app_organization} \
        ${conf_apibuilder_app_application} \
        api.json \
        --version ${conf_apibuilder_app_version} --update-config | while read line ; do  printMSG "${INFO} ${line}"; done;
    checkStatus ${PIPESTATUS[0]} "Push Success" "Push FAILURE"
    popd > /dev/null
}

function pushLatest(){
    printMSG "${INFO} Moving to working directory at ${PROJECT_HOME}"
    pushd ${PROJECT_HOME} > /dev/null ;
        apibuilder upload \
        ${conf_apibuilder_app_organization} \
        ${conf_apibuilder_app_application} \
        api.json \
        --version latest --update-config | while read line ; do  printMSG "${INFO} ${line}"; done;
    checkStatus ${PIPESTATUS[0]} "Push Success" "Push FAILURE"
    popd > /dev/null
}

function generate(){
    printMSG "${INFO} Moving to working directory at ${PROJECT_HOME}"
    pushd ${PROJECT_HOME} > /dev/null ;
        apibuilder update | while read line ; do  printMSG "${INFO} ${line}"; done;
        checkStatus ${PIPESTATUS[0]} "Update Success" "Update FAILURE"
    popd > /dev/null
}