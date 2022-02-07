#! /bin/bash

# Get variables from .env file
set -a
. ./django-k8-deployment/configs/.envs/.env
set +a

if [[ "${USE_WORKFLOWID^^}" == "TRUE" ]]
then
    export K8_NAMESPACE="$NAMESPACE-$CIRCLE_WORKFLOW_ID"
elif [[ "${USE_WORKFLOWID^^}" == "FALSE" ]]
then
    export K8_NAMESPACE="$NAMESPACE"
else
    echo "Incorrect value set for USE_WORKFLOWID. Valid values are true or false."
    exit 0
fi

echo "=SLEEP 10 SECONDS (wait for DNS to populate====="
sleep 10

# Deploy Ingress (Traefik)
echo "=DEPLOY INGRESS CONTROLLER ====="
envsubst < configs/ingress-p2/traefik-controller-deployment.yaml | kubectl apply -f -
