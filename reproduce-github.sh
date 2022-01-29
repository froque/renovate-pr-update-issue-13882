#!/usr/bin/env bash

docker run --rm -d -p 8081:8081 --name nexus sonatype/nexus:oss
# admin:admin123
#http://localhost:8082/nexus/#welcome

GITHUB_COM_TOKEN=""

function run_renovate {
  docker run --rm \
      -e LOG_LEVEL=debug \
      --link=nexus \
      renovate/renovate:latest \
        --token=${GITHUB_COM_TOKEN} \
        froque/renovate-pr-update-issue-13882
}

function deploy_lib {
  docker run -it \
      --rm \
      --link=nexus \
      -v $(pwd)/:/opt/ \
      -w /opt/ \
      maven \
        mvn --quiet --settings maven-settings.xml --file lib/pom.xml clean package install deploy
}

function bump_version_lib {
  local version=$1
  docker run -it \
      --rm \
      --link=nexus \
      -v $(pwd)/:/opt/ \
      -w /opt/ \
      maven \
        mvn --quiet --file lib/pom.xml versions:set -DnewVersion=$version -DgenerateBackupPoms=false
}

function change_deployed_timestamp {
  local version=$1
  local days=$2
  docker exec -it nexus \
    sh -c 'touch -d "'${days}' days ago" /sonatype-work/storage/releases/com/premiumminds/test/renovate-pr-update-issue-13882-lib/'${version}'/*'
}

# lib 1.0
deploy_lib
change_deployed_timestamp 1.0 10
run_renovate > run_renovate_1.0.txt

# change lib to 1.1
bump_version_lib 1.1
deploy_lib
change_deployed_timestamp 1.1 5
run_renovate > run_renovate_1.1.txt

# change lib to 1.2
bump_version_lib 1.2
deploy_lib
change_deployed_timestamp 1.2 1
run_renovate > run_renovate_1.2.txt