# GKE Cluster Deployment with Auto-Scaling and Blue-Green Strategy

This repository demonstrates how to set up a Google Kubernetes Engine (GKE) cluster using Terraform, deploy a simple "Hello World" application, enable auto-scaling, create CI-CD pipeline and implement a blue-green deployment strategy for zero-downtime updates.

## Table of Contents

1. [Prerequisites](#prerequisites)
2. [Setup GKE Cluster with Terraform](#setup-gke-cluster-with-terraform)
3. [Blue-Green Deployment Strategy](#blue-green-deployment-strategy)
4. [Deploy Using Jenkins/Cloud Build](#deploy-using-jenkinscloud-build)


## 1. Prerequisites
- Google cloud free tier account
- Github account
- Github actions
- Jenkins server

## 2. Setup GKE Cluster with Terraform

 **Terraform Configuration**: We used Terraform to create a GKE cluster with auto-scaling enabled. This setup allows the cluster to scale between 1 and 3 nodes depending on the demand.

### Steps to create the GKE cluster:
1. Clone this repository.
2. Run the github workflow by providing the below values
GCP_CRED, GCP_PROJECT_ID, PROJECT_NAME, GCP_REGIONS
3. We can store these values as secrets in github
4. Run the github workflow using actions

## 3. blue-green-deployment-strategy

**Blue-Green deployment strategy**:
In kubernetes folder of this repo there are two deployment files green and blue also there is one service file present.
Let's suppose the blue deployment is currently running on gke cluster and we have few changes in image and now we will 
first deploy the green deployment and ensure it looks good and everything working well with new changes in the image.
After ensuring this we will update the service file by changing the selector version to 'green' which will send the flow to
green deployment and if we face any issues we can change the service back to blue. This way we are ensuring minimal downtime.

## 4. deploy-using-jenkins

These blue and green environments are being deployed using jenkins pipeline. I have created a jenkins pipeline and parametrized it to take user input on whether they want to deploy blue or green environment. After taking the input, the pipeline deploys the new changes in following stages:
Stage 1: Checkout Code	
Stage 2: Authenticate with GKE	
Stage 3: Deploy Blue Environment	
Stage 4: Switch Traffic to blue	
Stage 5: Wait for External IP of blue deployment	
Stage 6: Test the blue application	
Stage 7: Scale Down green	
Stage 8: Deploy to Green Environment	
Stage 9: Switch Traffic to Green	
Stage 10: Wait for External IP of green deployment	
Stage 11: Test the green application	
Stage 12: Scale Down Blue

**Cloudbuild**:
Create the cloudbuild trigger by auth the github repo and provide the service account which has the access to gke cluster.
Now set the cloudbuild/cloudbuild.yaml file as a path from the repo which cloud build trigger will use to run the execution.
Just mannual run the job on GCP console and it will deploy the blue deployment and service on it also based on our requirement
we can change to green deployment file then it will deploy green and we can also delete blue deployment after ensuing everything 
running fine
