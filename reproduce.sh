
# self hosted maven repository
docker run --name reposilite \
    --rm \
    -d \
    -p 8080:80 \
    -e REPOSILITE_OPTS="--token user1:secret1" \
    dzikoysk/reposilite:3.0.0-alpha.15

mvn --quiet --settings maven-settings.xml --file lib/pom.xml clean package install deploy

GITLAB_TOKEN="xxx"
GITLAB_ADDRESS_DNS="gitlab.example.com"
GITLAB_ADDRESS_IP="192.0.2.0"

docker run --rm \
    -e LOG_LEVEL=debug \
     --add-host="${GITLAB_ADDRESS_DNS}:${GITLAB_ADDRESS_IP}" \
    renovate/renovate:latest \
      --platform=gitlab \
      --token=${GITLAB_TOKEN} \
      --endpoint="https://${GITLAB_ADDRESS_DNS}/api/v4/" \
      froque/renovate-pr-update-issue-13882
