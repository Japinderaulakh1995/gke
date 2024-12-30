# GKE Cluster Deployment with Auto-Scaling and Blue-Green Strategy

This repository demonstrates how to set up a Google Kubernetes Engine (GKE) cluster using Terraform, deploy a simple "Hello World" application, enable auto-scaling, and implement a blue-green deployment strategy for zero-downtime updates.

## Table of Contents

1. [Prerequisites](#prerequisites)
2. [Setup GKE Cluster with Terraform](#setup-gke-cluster-with-terraform)
3. [Blue-Green Deployment Strategy](#blue-green-deployment-strategy)
4. [Deploy Using Jenkins/Cloud Build](#deploy-using-jenkinscloud-build)


## 1. Prerequisites
- Google cloud free tier account
- Github account
- Github actions
- Cloud build

## 2. Setup GKE Cluster with Terraform

 **Terraform Configuration**: We used Terraform to create a GKE cluster with auto-scaling enabled. This setup allows the cluster to scale between 3 and 6 nodes depending on the demand.

### Steps to create the GKE cluster:
1. Clone this repository.
2. Run the github workflow by providing the below values
GCP_CRED, GCP_PROJECT_ID, PROJECT_NAME, GCP_REGIONS
3. We can store this values as secrets in github
4. Run the github workflow using actions

## 3. blue-green-deployment-strategy

**Blue-Green deployment strategy**:
In kubernetes folder of this repo there are two deployment files green and blue also there is one service file present.
Let's suppose the blue deployment is currently running on gke cluster and we have few changes in image and now we will 
first deploy the green deployment and ensure it looks good and everything working well with new changes in the image.
After ensuring this we will update the service file by changing the selector version to 'green' which will send the flow to
green deployment and if we face any issues we can change the service back to blue. With this way we can ensure less downtime.

## 4. deploy-using-jenkinscloud-build

**Cloudbuild**:
Create the cloudbuild trigger by auth the github repo and provide the service account which has the access to gke cluster.
Now set the cloudbuild/cloudbuild.yaml file as a path from the repo which cloud build trigger will use to run the execution.
Just mannual run the job on GCP console and it will deploy the blue deployment and service on it also based on our requirement
we can change to green deployment file then it will deploy green and we can also delete blue deployment after ensuing everything 
running fine
