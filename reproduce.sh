
# self hosted maven repository
docker run --name reposilite \
    --rm \
    -d \
    -p 8080:8080 \
    -e REPOSILITE_OPTS="--token user1:secret1 --port=8080" \
    dzikoysk/reposilite:3.0.0-alpha.15

# deploy lib 1.0
docker run -it \
    --rm \
    --link=reposilite \
    -v $(pwd)/:/opt/ \
    -w /opt/ \
    maven \
      mvn --quiet --settings maven-settings.xml --file lib/pom.xml clean package install deploy

GITLAB_TOKEN="xxx"
GITLAB_ADDRESS_DNS="gitlab.example.com"
GITLAB_ADDRESS_IP="192.0.2.0"

docker run --rm \
    -e LOG_LEVEL=debug \
    --link=reposilite \
     --add-host="${GITLAB_ADDRESS_DNS}:${GITLAB_ADDRESS_IP}" \
    renovate/renovate:latest \
      --platform=gitlab \
      --token=${GITLAB_TOKEN} \
      --endpoint="https://${GITLAB_ADDRESS_DNS}/api/v4/" \
      froque/renovate-pr-update-issue-13882

# change lib to 1.1
docker run -it \
    --rm \
    --link=reposilite \
    -v $(pwd)/:/opt/ \
    -w /opt/ \
    maven \
      mvn --quiet --file lib/pom.xml versions:set -DnewVersion=1.1 -DgenerateBackupPoms=false

# deploy lib 1.1
docker run -it \
    --rm \
    --link=reposilite \
    -v $(pwd)/:/opt/ \
    -w /opt/ \
    maven \
      mvn --quiet --settings maven-settings.xml --file lib/pom.xml clean package install deploy

# creates pull request for 1.1
docker run --rm \
    -e LOG_LEVEL=debug \
    --link=reposilite \
     --add-host="${GITLAB_ADDRESS_DNS}:${GITLAB_ADDRESS_IP}" \
    renovate/renovate:latest \
      --platform=gitlab \
      --token=${GITLAB_TOKEN} \
      --endpoint="https://${GITLAB_ADDRESS_DNS}/api/v4/" \
      froque/renovate-pr-update-issue-13882

# change lib to 1.2
docker run -it \
    --rm \
    --link=reposilite \
    -v $(pwd)/:/opt/ \
    -w /opt/ \
    maven \
      mvn --quiet --file lib/pom.xml versions:set -DnewVersion=1.2 -DgenerateBackupPoms=false

# deploy lib 1.2
docker run -it \
    --rm \
    --link=reposilite \
    -v $(pwd)/:/opt/ \
    -w /opt/ \
    maven \
      mvn --quiet --settings maven-settings.xml --file lib/pom.xml clean package install deploy

# creates pull request for 1.2
docker run --rm \
    -e LOG_LEVEL=debug \
    --link=reposilite \
     --add-host="${GITLAB_ADDRESS_DNS}:${GITLAB_ADDRESS_IP}" \
    renovate/renovate:latest \
      --platform=gitlab \
      --token=${GITLAB_TOKEN} \
      --endpoint="https://${GITLAB_ADDRESS_DNS}/api/v4/" \
      froque/renovate-pr-update-issue-13882