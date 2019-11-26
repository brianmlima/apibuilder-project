#!/usr/bin/env bash
################################################################################
## Resolves the directory this script is in. Tolerates symlinks.
SOURCE="${BASH_SOURCE[0]}" ;
while [[ -h "$SOURCE" ]] ; do TARGET="$(readlink "${SOURCE}")"; if [[ $SOURCE == /* ]]; then SOURCE="${TARGET}"; else DIR="$( dirname "${SOURCE}" )"; SOURCE="${DIR}/${TARGET}"; fi; done
SOURCE_DIR="$( cd -P "$( dirname "${SOURCE}" )" && pwd )"
################################################################################
################################################################################


${SOURCE_DIR}/bin/apibuilderproject.rb -o bml -a test-service-api -v 0.0.1-dev -t ~/.github-api-token -d ./target/ -c -L

###############################################################################
