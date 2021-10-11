#!/usr/bin/env bash
################################################################################
## Resolves the directory this script is in. Tolerates symlinks.
SOURCE="${BASH_SOURCE[0]}" ;
while [[ -h "$SOURCE" ]] ; do TARGET="$(readlink "${SOURCE}")"; if [[ $SOURCE == /* ]]; then SOURCE="${TARGET}"; else DIR="$( dirname "${SOURCE}" )"; SOURCE="${DIR}/${TARGET}"; fi; done
SOURCE_DIR="$( cd -P "$( dirname "${SOURCE}" )" && pwd )"
################################################################################
################################################################################



TEST_PROJECT_HOME="${SOURCE_DIR}/../tmp/bml.api.apibuilder-project-test"

ORG="bml"
GROUP_ID="org.bml"
APP="apibuilder-project-test"
VERSION="0.0.1"

rm -rf ${TEST_PROJECT_HOME} &&

${SOURCE_DIR}/bin/apibuilderproject.rb -o ${ORG} -a ${APP} -v ${VERSION} -d $(dirname ${TEST_PROJECT_HOME})  -L --spring-gradle --group-id ${GROUP_ID}

if [ ${?} -eq 0 ]; then
    pushd ${TEST_PROJECT_HOME}
      if [ ${?} -eq 0 ]; then
        ./bin/pushAndGenerate.sh
        if [ ${?} -eq 0 ]; then
          ls -lha
          find ./src -type f
          #mvn clean verify site
          ./gradlew clean test
        fi
      fi
    popd
fi


###############################################################################
