pipeline {
    agent any
    
    parameters {
        booleanParam(name: 'load_testing', defaultValue: true, description: 'Increase the stree on gke cluster')
    }
    environment {
        PROJECT_ID = credentials('gcp-project-id-secret')          // Replace with your GCP project ID
        GCP_PROJECT_ID = "${PROJECT_ID.split(':')[1]}"
        CLUSTER_NAME = "ey-devops-cluster"          // Replace with your GKE cluster name
        REGION = "us-central1-a"                    // Replace with your cluster's region
        KUBECONFIG = "$WORKSPACE/.kube/config"
    }

    stages {
        stage('Checkout Code') {
            steps {
            checkout([
            $class: 'GitSCM',
            branches: [[name: '*/main']],
            userRemoteConfigs: [[
                url: 'https://github.com/Japinderaulakh1995/gke.git', // Replace with your repository URL
                credentialsId: 'github_cred' // Replace with your Jenkins credential ID
            ]]
        ])
            }
        }



        stage('Authenticate with GKE') {
            steps {
                sh '''
                export PATH=$PATH:$WORKSPACE/google-cloud-sdk/bin
                cd /
                gcloud auth activate-service-account --key-file=/var/lib/jenkins/service_account.json
                gcloud config set project $GCP_PROJECT_ID
                gcloud container clusters get-credentials $CLUSTER_NAME --region $REGION
                '''
            }
        }
        stage('Incrase the load') {
            steps {
                sh '''
                 kubectl apply -f kubernetes/load_testing.yaml
                '''
            }
        }

        stage('Monitor Node Autoscaling') {
            steps {
                script {
                    // Initial count of nodes
                    def initialNodeCount = sh(
                        script: "kubectl get nodes | grep -c 'Ready'",
                        returnStdout: true
                    ).trim().toInteger()

                    echo "Initial node count: ${initialNodeCount}"

                    def retries = 0
                    def maxRetries = 20  // Retry up to 10 times
                    def newNodeCount = initialNodeCount

                    while (newNodeCount <= initialNodeCount && retries < maxRetries) {
                        echo "Checking for node count increase... Attempt ${retries + 1} of ${maxRetries}"

                        sleep(time: 30, unit: 'SECONDS')  // Wait for 30 seconds before retrying

                        newNodeCount = sh(
                            script: "kubectl get nodes | grep -c 'Ready'",
                            returnStdout: true
                        ).trim().toInteger()

                        echo "Current node count: ${newNodeCount}"

                        retries++
                    }

                }
            }
        }
    }
}
