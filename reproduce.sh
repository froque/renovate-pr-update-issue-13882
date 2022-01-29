
docker run --rm -d -p 8081:8081 --name nexus sonatype/nexus:oss
# admin:admin123
#http://localhost:8082/nexus/#welcome

GITLAB_TOKEN="xxx"
GITLAB_ADDRESS_DNS="gitlab.example.com"
GITLAB_ADDRESS_IP="192.0.2.0"

function run_renovate {
  docker run --rm \
      -e LOG_LEVEL=debug \
      --link=nexus \
       --add-host="${GITLAB_ADDRESS_DNS}:${GITLAB_ADDRESS_IP}" \
      renovate/renovate:latest \
        --platform=gitlab \
        --token=${GITLAB_TOKEN} \
        --endpoint="https://${GITLAB_ADDRESS_DNS}/api/v4/" \
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

# deploy lib 1.0
deploy_lib
change_deployed_timestamp 1.0 10
run_renovate

# change lib to 1.1
bump_version_lib 1.1
deploy_lib
change_deployed_timestamp 1.1 5
run_renovate

# change lib to 1.2
bump_version_lib 1.2
deploy_lib
run_renovate