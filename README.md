# Capstone Project

## Project Overview
This repository provides code for deployment of an image face reconstruction application web application. It showcases the development of a cloudnative application build in a DevOps Its deployment is configured by means of a CirclCi pipeline. The instructions for deployments can be found here. This repository contains code as part of the [Udacity Cloud DevOps Engineer Nanodegree Program](https://www.udacity.com/courses/all) capstone project.

## Application description
Users can upload a picture they wish to reconstruct. After users upload their picture they are prompted to wait by a loading screen. In the backend, the file is renamed to a random name (randomly generated hex string) and is uploaded to an S3 bucket. The upload to the S3 bucket triggers an AWS Lambda function. The picture then runs through an inference model that attempts to properly reconstruct faces on the image (e.g. sharpen contours). The reconstructed picture is returned to the user. All user-related content are automatically destroyed from the servers after 15 min. This is achieved by another AWS Lambda function. The deployment of the code and resources needed are described in the next sections.

---

Project keywords: [`Kubernetes`](https://kubernetes.io/) [`CircleCI`](https://circleci.com) [`Docker`](https://www.docker.com/) [`Docker Compose`](https://docs.docker.com/compose/) [`Makefile`](https://www.gnu.org) [`AWS Infrastructure as Code`](https://aws.amazon.com) [`Django`](https://www.djangoproject.com/) [`Django Cookiecutter`](https://cookiecutter-django.readthedocs.io) [`GitHub`](https://github.com/) [`Slack`](https://slack.com) [`Prometheus`](https://prometheus.io/)

Tags: [`GFPGAN`](https://github.com/TencentARC/GFPGAN.git) `AWS Machine Learning` `AWS Lambda` `AWS EFS mount EC2` `Pipeline` `DevOps`

> **_WARNING:_**  Carefully review costs for all resources used before deploying. Moreover, always avoid unexpected cost by destroying all resources when finished. This project contains AWS resources with costs that are not cheap! Furthermore, the author is not responsible for the use of the information contained in or linked from this repository.

> **_INFO:_**  Make sure to install Git LFS before cloning this repository. Failing to do so will lead to errors due to missing files. Refer to the requirements section for more information regarding Git LFS.

This project operationalizes a Machine Learning Microservice API. In general, it comprises three applications:
  1. A Django [web application](https://github.com/sitWolf/capstone/tree/main/face_reconstruction_web_app) that allows users to submit a picture whom these wish to reconstruct.
  2. An inference application that processes the submitted images
  3. A Lambda function that operationalizes the inference application

### 1. Web application
The web application is build using Django and [Django Cookiecutter](https://github.com/cookiecutter/cookiecutter-django). Although not part of the assignment, it is developed to deliver a usable application. Django provides development of web applications and configuration the frontend and the backend. It includes provisions for an RDS database to store account information. For this project however, no functionalities are used which require a database.

### 2. Inference application
[`GFPGAN`](https://github.com/TencentARC/GFPGAN) is used for the face reconstruction model. Some modifications have been made to read and write from and to AWS S3 (i.e. in memory processing), and other unused features are removed. AWS EFS with Lambda is used. The EFS file system is configured for a Lambda function to import the required libraries and load the model. The AWS [Pay as you go machine learning inference with AWS Lambda](https://aws.amazon.com/blogs/compute/pay-as-you-go-machine-learning-inference-with-aws-lambda/) was used as a guidance for mounting the file system (EFS) on EC2 instance.

### 3. A Lambda function(s)
An Amazon Elastic File System (EFS)is mounted on an EC2 for use with a Lambda function. EFS provides a cost effective tool for using Lambda with heavy packages that require storage space to load models and other dependencies.

---

## Requirements

### Git Large File Storage
* Install [Git LFS](https://docs.github.com/en/repositories/working-with-files/managing-large-files/installing-git-large-file-storage). Git LFS is used for committing the GFPGAN models. These models are over 100MB in size.

### Docker
* Install [Docker](https://docs.docker.com/get-docker/). Docker enables separating the application from your infrastructure.

### Docker Compose
* Install [Docker Compose](https://docs.docker.com/compose/install/). Docker Compose is a tool for defining and running multi-container Docker applications.

### Hadolint
* Install [Hadolint](https://github.com/hadolint/hadolint). Hadolint enables linting of Docker images
```bash
wget -O /bin/hadolint https://github.com/hadolint/hadolint/releases/download/v2.8.0/hadolint-Linux-x86_64
sudo chmod +x /bin/hadolint
```
### Minikube
* Install [Minikube](https://minikube.sigs.k8s.io/docs/start/). Minikube is local Kubernetes, focusing on making it easy to develop for Kubernetes.

### Kubectl
* Install [Kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl-linux/). The kubectl command line tool lets you control Kubernetes clusters. For more information of Kubernetes, see this [link](https://kubernetes.io/docs/concepts/overview/what-is-kubernetes/).

### Amazon eksctl
* Install [eksctl](https://docs.aws.amazon.com/eks/latest/userguide/eksctl.html). The eksctl command line utility provides the fastest and easiest way to create a new cluster with nodes for Amazon EKS.

---

## Preparation
Create an EC2 Key Pair. Write down the key-pair name. You will need it later when setting up environment variables (under KEYNAME).
Copy the contents of the .pem file and use it to create an SSH key is CircleCI.
To add an SSH key navigate to `Project Settings` > `SSH Keys`. Under Additional SSH keys, click on `Add SSH` key and paste the content of the .pem file in it.
Copy the resulting `Fingerprint`.

From the CircleCI main menu navigate to `Organizational Settings`. Create a context and name it `capstone_env_variables`.
If you choose another name, make sure to reflect this change in the CircleCI config file.
After creating the context click on `Add Environment Variable`, and create a new variable with Environment Variable Name `KEYNAME`. Paste the previously acquired fingerprint in the value field. 

Also add the following variables
```
KEYNAME
FINGERPRINT
AMI_TO_USE
AWS_ACCESS_KEY_ID
AWS_DEFAULT_REGION
AWS_SECRET_ACCESS_KEY
S3_BUCKET_IN_NAME
S3_BUCKET_OUT_NAME
S3_BUCKET_SOURCE_NAME
STACK_NAME_INFRASTRUCTURE
STACK_NAME_SERVERLESS
EKS_CLUSTER_NAME
```
---

## Project options and features
In this project the following options are available:
1. `Local deployment, python test and code linting:` The workflow comprises a local run of the docker applications (using docker-compose), pyton tests, and a code linter to catch errors in the Docker files. The local test reflects the production application. The three methods are used to catch errors early in the pipeline. These workflow jobs take approximately 5 minutes to complete. They block any AWS resources from being created in case there are errors in the code.

2. `Application ready deployment:` This repository can be run using the `sitwolf` Docker files, or developers can dockerize their own application. The images used must be entered in the accompanied env file (./capstone/django-k8-deployment/configs/.envs/.env) or directly change `image` references in three files must be changed: The django and postgres yml files in the directory `./django-k8-deployment/configs/deployments` and the traefik yml file in `./capstone/django-k8-deployment/configs/ingress-p2`. When using sitwolf docker files you can use the following images: `sitwolf/django_k8`, `sitwolf/postgres_k8`, `sitwolf/traefik_k8`.

3. `Deployment:` This project uses [kubernetes](https://kubernetes.io/) and [Docker Compose](https://docs.docker.com/compose/). Kubernetes is an open-source system for automating the management of containerized applications. In the context of this projects, Docker-compose provides an easy way to deploy. One can simply deploy using the command `docker-compose -f production.yml up`. However docker-compose does not provide the scaling and replica possibilities provided by Kubernetes. To increase or decrease the number of pods per deployment change `replicas` under specs in the deployment yml file.

4. `Blue Green deployment:` For this deployment a blue-green deployment strategy is adopted. This is achieved using [Amazon Route 53](https://aws.amazon.com/route53/). After successful deployment run the command `kubectl get svc -n capstone`, copy the external IP (load balancer DNS) and update your DNS records accordingly. This [AWS Whitepaper](https://docs.aws.amazon.com/whitepapers/latest/blue-green-deployments/update-dns-routing-with-amazon-route-53.html) describes implementation techniques for updating DNS Routing with Amazon Route 53.

---
## Troubleshooting
This section provides a brief overview of commands that can help with troubleshooting.

1. Get all config resources and check if all is running. Sometimes running does not mean that the application is performing as it should (see next command).
```
kubectl get all -n capstone
```

* Get the  logs. From the above command output. Copy the pod id and replace the pod id in the following command. Make sure to check replicas due to the load balancer.
```
kubectl logs pod/django-12345678-123qr
``` 

* Check what the events have to tell.
```
kubectl get events --sort-by=.metadata.creationTimestamp -n capstone
```

* Check if ACME is empty.
```
kubectl exec -n capstone --stdin --tty traefik-123456789-123nl -- /bin/sh
```

* Check cert for TS
```
kubectl get secret -o yaml
``` 

## TODO
* Automatic certificate generation (Traefik), fails due to Kubernetes read-only file system. A thread was opened for this [issue](https://stackoverflow.com/questions/70948605/working-with-kubernetes-read-only-file-system).
* When the above is resolved, integrate `deploy-django-k8-ingress.sh` in the script. Or modify certificate management to use user-provided certificate rather than using Traefik auto generated certificates.
* Set up the `livenessProbe` and `readinessProbe` for the Django Kubernetes deployment (commented out).