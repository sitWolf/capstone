# Deploy Django web app on AWS EKS.

## Project Overview
This repository provides code for deployment of a Django web app on [Amazon Elastic Kubernetes Service (EKS)](https://aws.amazon.com/eks/).

## Description
The code provided in this repository deploys an app (Django web app) on an existing cluster. This Django app makes part of a larger deployment. It can still be tested as standalone. However, some additional AWS resources (AWS S3) are still required.

---

## Prerequisites
Create three AWS S3 buckets. One bucket will serve the static files. The other two buckets will serve as ingress and egress hubs.

## Requirements

### Kubernetes kubectl
* Install [kubectl](https://kubernetes.io/docs/tasks/tools/). The Kubernetes command-line tool, kubectl, allows you to run commands against Kubernetes clusters.

---

## Setup
The code contained in this repository is originally developed to work with CircleCI.

> **_NOTE:_**  A blue/green deployment strategy is adopted. Therefore a CircleCI workflow ID is used. The workflow ID will be suffixed to the namespace. For example, mynamespacename-2423434354. This makes it easier for rollbacks. The only thing you need to do is to set in the .env file whether you wish to use the workflow id or not (true or false). The rest is done for you. Setting to false will result in a `mynamespacename` whereas true will result in `mynamespacename-2423434354`. Note that the bash script does not check whether CircleCI workflow ID variable is empty.

## Setting environment variables.
### Environment variables (secrets)
Set the below variables as CircleCI context variables, or export them manually (when testing) as shown below.

> **_WARNING:_**  Do not store secrets (permanently) on your machine (e.g., in .bashrc).

```
export DJANGO_ADMIN_URL=
export DJANGO_AWS_ACCESS_KEY_ID=
export DJANGO_AWS_SECRET_ACCESS_KEY=
export DJANGO_SECRET_KEY=
export POSTGRES_PASSWORD=
```

### Environment variables (basic configuration)
Navigate to capstone/django-k8/configs/.envs/.env and enter your values.

### Deploying
After all is set, run the following command:
```
bash deploy-django-k8-app.sh
```
or:
```
chmod +x deploy-django-k8-app.sh
./deploy-django-k8-app.sh
```

