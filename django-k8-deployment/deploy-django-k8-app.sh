#! /bin/bash
# Get variables from .env file
set -a
. ./django-k8-deployment/configs/.envs/.env
set +a

printenv

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

find .

# Create a namespace
echo "=NAMESPACE ====="
echo "Namespace: ${K8_NAMESPACE}"
envsubst < ./django-k8-deployment/configs/namespaces/capstone.yaml | kubectl apply -f -

echo -e "\n=CONFIGMAPS ====="
# Create the configmaps for django and postgres
envsubst < ./django-k8-deployment/configs/configmaps/django-config.yaml | kubectl apply -f -
envsubst < ./django-k8-deployment/configs/configmaps/postgres-config.yaml | kubectl apply -f -

# Create the configmap for traefik (2-step)
# STEP 1: Include domain name in the yaml snippet
echo "Variables used:"
echo "domain: $DOMAIN"
echo "www domain: www.$DOMAIN"
echo "email: $DOMAIN_EMAIL"
sed -e "s/\${domain}/$DOMAIN/" -e "s/\${domain_email}/$DOMAIN_EMAIL/"  -e "s/\${wwwdomain}/$WWWDOMAIN/" ./django-k8-deployment/configs/.envs/.configmaps/.traefik >> ./django-k8-deployment/configs/traefik/traefik.yml
# STEP 2: Create the configmap
kubectl create configmap envs-production-traefik -n "${K8_NAMESPACE}" --from-env-file=./django-k8-deployment/configs/traefik/traefik.yml
envsubst < ./django-k8-deployment/configs/configmaps/traefik-configmap.yaml | kubectl apply -f -

echo -e "\n=SECTRETS ====="
# Create secrets
export DSK=$(echo -n "$DJANGO_SECRET_KEY" | base64)
envsubst < ./django-k8-deployment/configs/secrets/django.yaml | kubectl apply -f -
export PGPW=$(echo -n "$POSTGRES_PASSWORD" | base64)
envsubst < ./django-k8-deployment/configs/secrets/postgres.yaml | kubectl apply -f -

echo -e "\n=STORAGECLASS ====="
# Create storageclass
# We identify a single AZ due to having multiple (2) nodes in different availability zones.
# Without is, it will lead to an affinity conflict. 
# https://stackoverflow.com/questions/51946393/kubernetes-pod-warning-1-nodes-had-volume-node-affinity-conflict
export AZONE=${DJANGO_AWS_REGION}${AVAILABILITY_ZONE_SUFFIX}
echo "Availability Zone used for AWS EBS: $AZONE"
envsubst < ./django-k8-deployment/configs/storageclass/storageclass-ingress.yaml | kubectl apply -f -
envsubst < ./django-k8-deployment/configs/storageclass/storageclass-postgres.yaml | kubectl apply -f -

echo -e "\n=VOLUMECLAIMS ====="
# Create volumes claims
envsubst < ./django-k8-deployment/configs/volume-claims/postgres-backups-pv-claim.yaml | kubectl apply -f -
envsubst < ./django-k8-deployment/configs/volume-claims/postgres-data-pv-claim.yaml | kubectl apply -f -
envsubst < ./django-k8-deployment/configs/volume-claims/traefik-pv-claim.yaml | kubectl apply -f -

echo -e "\n=DEPLOYMENTS ====="
envsubst < ./django-k8-deployment/configs/deployments/django-deployment.yaml | kubectl apply -f -
envsubst < ./django-k8-deployment/configs/deployments/postgres-deployment.yaml | kubectl apply -f -
envsubst < ./django-k8-deployment/configs/deployments/redis-deployment.yaml | kubectl apply -f -

echo -e "\n=INGRESS PT1 ====="
# Create ingress service
envsubst < ./django-k8-deployment/configs/ingress-p1/traefik-service.yaml | kubectl apply -f -

echo -e "\n=Pausing 10 seconds for the external IP to populate"
sleep 10

echo -e "\n=EXTERNAL IP (NETWORK LOAD BALANCER) ====="
kubectl get svc -n $K8_NAMESPACE

echo -e "\n=REVIEW THE DEPLOYMENT====="
kubectl get all -n $K8_NAMESPACE

echo -e "\n"
echo "If all successfull, update your DNS records."
echo "Do this by creating a simple A record pointing to the loadbalancer IP (Network Load Balancer)"
echo "If no NLB external IP is shown, rerun this file."

# Certificate will not be generated with this method.
envsubst < ./django-k8-deployment/configs/ingress-p2/traefik-controller-deployment.yaml | kubectl apply -f -

#echo "Confirm that DNS has been updated (may take several minutes). Continuing without updated DNS records will fail certificate generation."

#read -p "Are you sure?[yN] " -n 1 -r
#
#if [[ $REPLY =~ ^[Yy]$ ]]
#then
#    envsubst < ./django-k8-deployment/configs/ingress-p2/traefik-controller-deployment.yaml | kubectl apply -f -
#else
#    exit 0
#fi