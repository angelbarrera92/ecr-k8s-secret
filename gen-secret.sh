#!/bin/bash
set -e

SECRET_NAME=$1

regex="docker login -u (.+) -p (.+) -e (.+) (.+)"
if [[ $(aws ecr get-login) =~ $regex ]]
then
  kubectl delete secret $SECRET_NAME || echo 'The secret $SECRET_NAME does not exists'
  kubectl create secret docker-registry $SECRET_NAME --docker-server=${BASH_REMATCH[4]} --docker-username=${BASH_REMATCH[1]} --docker-password=${BASH_REMATCH[2]} --docker-email=${BASH_REMATCH[3]}
  cat <<EOF
In order to use the new secret to pull images, add the following to your Pod definition:
    spec:
      imagePullSecrets:
        - name: $SECRET_NAME
      [...]
Remember that AWS ECR login credentials expire in 12 hours!
More info at https://kubernetes.io/docs/tasks/configure-pod-container/pull-image-private-registry/
EOF
fi
