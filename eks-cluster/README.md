# Amazon Elastic Kubernetes Service (EKS)

## Project Overview
This repository provides instructions for deployment of a Kubernetes cluster on AWS EKS.
The steps provided here are for Linux. Check out the references to install on other systems.

> **_INFO:_**  The easiest way to deploy a kubernetes cluster is to perform these instructions within an AWS Cloud9 environment. The instructions provided here is a collection of instructions. These are referenced throughout this document.

---
## Instructions: Deploying a Kubernetes cluster on AWS EKS

### Install Kubectl (client)
[Reference](https://kubernetes.io/docs/tasks/tools/install-kubectl-linux/)
```
curl -LO "https://dl.k8s.io/release/v1.21.2/bin/linux/amd64/kubectl"
curl -LO "https://dl.k8s.io/v1.21.2/bin/linux/amd64/kubectl.sha256"
echo "$(<kubectl.sha256)  kubectl" | sha256sum --check
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
kubectl version --client
```

### Install eksctl command line utility (server)
[Reference](https://docs.aws.amazon.com/eks/latest/userguide/eksctl.html)
```
curl --silent --location "https://github.com/weaveworks/eksctl/releases/latest/download/eksctl_$(uname -s)_amd64.tar.gz" | tar xz -C /tmp
sudo mv /tmp/eksctl /usr/local/bin
eksctl version
```

### Define some variables for names that we will be using.
```
clusterName=mycluster; \
awsAccountNumber=myawsaccountnumber; \
nameSpace=mynamespace; \
AWS_DEFAULT_REGION=aws-region
```

### Create AWS EKS cluster
```
eksctl create cluster --version 1.21 --name "$clusterName" --region "$AWS_DEFAULT_REGION"
```

### Check if Kubernetes Client and Server versions are aligned.
A warning is displayed if the versions are more than 1 minor version apart.
Since we uses the latest release for eksctl, correct the Kubectl version installed at the first step to match the server.
```
kubectl version --short
```

---

## Deploy AWS Load Balancer Controller to the EKS cluster
The load balancer is used to expose the deployment to the outside world

### Create an IAM OIDC identity provider for our cluster
[Reference](https://docs.aws.amazon.com/eks/latest/userguide/enable-iam-roles-for-service-accounts.html)
```
echo "$clusterName"
eksctl utils associate-iam-oidc-provider --cluster "$clusterName" --approve
```

### Create an IAM OIDC identity provider for our cluster
[Reference](https://docs.aws.amazon.com/eks/latest/userguide/enable-iam-roles-for-service-accounts.html)

### IAM policy for the AWS Load Balancer Controlle
[Reference](https://docs.aws.amazon.com/eks/latest/userguide/aws-load-balancer-controller.html)
Download an IAM policy for the AWS Load Balancer Controller that allows it to make calls to AWS APIs on your behalf, and use it to create an IAM policy: 

```
curl -o iam_policy.json https://raw.githubusercontent.com/kubernetes-sigs/aws-load-balancer-controller/v2.3.1/docs/install/iam_policy.json
```
Create an IAM policy using the policy downloaded in the previous step.
```
aws iam create-policy \
    --policy-name AWSLoadBalancerControllerIAMPolicy \
    --policy-document file://iam_policy.json
```

### Get AWS account ID (double-check)
```
sudo yum install jq -y
awsAccountId=$(aws sts get-caller-identity | jq -r '.Account')
```
Should be the same as `"$awsAccountNumber"`
```
echo "$awsAccountId"
```

### IAM  role for Kubernetes service account
Create an IAM role for use with a Kubernetes service account, replacing the cluster name and account ID as appropriate: 
eksctl create iamserviceaccount \
  --cluster="$clusterName" \
  --namespace=kube-system \
  --name=aws-load-balancer-controller  \
  --attach-policy-arn=arn:aws:iam::"$awsAccountId":policy/AWSLoadBalancerControllerIAMPolicy \
  --override-existing-serviceaccounts \
  --approve

> **_INFO:_**  With reference to the original [AWS instructions](https://docs.aws.amazon.com/eks/latest/userguide/aws-load-balancer-controller.html) you will need to get the files referenced, enter your data and then run the command.

### Install cert-manager to the cluster for managing certificate-related tasks
Download the controller specification. For more information about the controller, see the documentation on GitHub.
```
curl -Lo v2_3_1_full.yaml https://github.com/kubernetes-sigs/aws-load-balancer-controller/releases/download/v2.3.1/v2_3_1_full.yaml
```

Make the following edits to the v2_3_1_full.yaml file:
Delete the ServiceAccount section of the file. Deleting this section prevents the annotation with the IAM role from being overwritten when the controller is deployed and preserves the service account that you created in step 3 if you delete the controller.
Remove this part of the code:
```
 apiVersion: v1
 kind: ServiceAccount
 metadata:
   labels:
     app.kubernetes.io/component: controller
     app.kubernetes.io/name: aws-load-balancer-controller
   name: aws-load-balancer-controller
   namespace: kube-system
```

And, replace your-cluster-name in the Deployment spec section of the file with the name of your cluster.
```
...
spec:
      containers:
        - args:
            - --cluster-name=your-cluster-name
...
```

If you are deploying the controller to Amazon EC2 nodes that have restricted access to the Amazon EC2 instance metadata service (IMDS) , or if you're deploying to Fargate, then add the following parameters under - args:.
```
    ...
    spec:
          containers:
            - args:
                - --cluster-name=your-cluster-name
                - --ingress-class=alb
                - --aws-vpc-id=vpc-xxxxxxxx
                - --aws-region=region-code
    ...
```

Apply the file.
```
kubectl apply -f v2_3_1_full.yaml
```

### Verify the controller is properly installed
```
kubectl get deployment/aws-load-balancer-controller -n kube-system
```

## Install 
[Reference](https://aws.amazon.com/premiumsupport/knowledge-center/eks-persistent-storage/)
Use the provided reference to set up persistent storage in Amazon EKS

---

## You are all set!
