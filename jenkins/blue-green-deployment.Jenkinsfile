pipeline {
    agent any
    
    parameters {
        booleanParam(name: 'DEPLOY_BLUE', defaultValue: true, description: 'check box to deploy Blue environment first and uncheck for green deployment')
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

        stage('Deploy Blue Environment') {
            when {
                expression { return params.DEPLOY_BLUE }
            }
            steps {
                script {
                    // Deploy the blue environment
                    sh """
                    kubectl apply -f kubernetes/blue-deployment.yaml
                    kubectl rollout status deployment/nginx-blue
                    """
                    
                }
            }
        }
        stage('Switch Traffic to blue') {
            when {
                expression { return params.DEPLOY_BLUE }
            }
            steps {
                script {
                   // Update the service to point to the blue deployment
                    sh """
                    sed -i 's/version: green/version: blue/' kubernetes/service.yaml
                    kubectl apply -f kubernetes/service.yaml
                    """
                }
            }
        }
        stage('Wait for External IP of blue deployment') {
            when {
                expression { return params.DEPLOY_BLUE }
            }
            steps {
                script {
                    // Wait until the external IP is assigned
                    timeout(time: 5, unit: 'MINUTES') { // Set a 5-minute timeout
                        def externalIp = ''
                        while (externalIp == '') {
                            externalIp = sh(
                                script: "kubectl get svc nginx-service -o jsonpath='{.status.loadBalancer.ingress[0].ip}'",
                                returnStdout: true
                            ).trim()
                            if (externalIp == '') {
                                echo 'External IP not assigned yet. Retrying in 10 seconds...'
                                sleep(10)
                            }
                        }
                        echo "External IP assigned: ${externalIp}"
                        // Save external IP for later stages or output
                        env.EXTERNAL_IP = externalIp
                    }
                }
            }
        }
        stage('Test the blue application') {
            when {
                expression { return params.DEPLOY_BLUE }
            }
            steps {
                script {
                    echo "Testing application availability at: http://${env.EXTERNAL_IP}"
                    sh "curl -m 10 http://${env.EXTERNAL_IP}"
                }
            }
        }

        stage('Scale Down green') {
            when {
                expression { return params.DEPLOY_BLUE }
            }
            steps {
                script {
                    // Scale down the green deployment
                    sh """
                    kubectl scale deployment/nginx-green --replicas=0
                    """
                }
            }
        }
        stage('Deploy to Green Environment') {
            when {
                expression { return !params.DEPLOY_BLUE }
            }
            steps {
                script {
                    // Deploy the green environment
                    sh """
                    kubectl apply -f kubernetes/green-deployment.yaml
                    kubectl rollout status deployment/nginx-green
                    """
                }
            }
        }
        stage('Switch Traffic to Green') {
            when {
                expression { return !params.DEPLOY_BLUE }
            }
            steps {
                script {
                    // Update the service to point to the green deployment
                    sh """
                    sed -i 's/version: blue/version: green/' kubernetes/service.yaml
                     kubectl apply -f kubernetes/service.yaml
                    """
                }
            }
        }
        stage('Wait for External IP of green deployment') {
            when {
                expression { return !params.DEPLOY_BLUE }
            }
            steps {
                script {
                    // Wait until the external IP is assigned
                    timeout(time: 5, unit: 'MINUTES') { // Set a 5-minute timeout
                        def externalIp = ''
                        while (externalIp == '') {
                            externalIp = sh(
                                script: "kubectl get svc nginx-service -o jsonpath='{.status.loadBalancer.ingress[0].ip}'",
                                returnStdout: true
                            ).trim()
                            if (externalIp == '') {
                                echo 'External IP not assigned yet. Retrying in 10 seconds...'
                                sleep(10)
                            }
                        }
                        echo "External IP assigned: ${externalIp}"
                        // Save external IP for later stages or output
                        env.EXTERNAL_IP = externalIp
                    }
                }
            }
        }
        stage('Test the green application') {
            when {
                expression { return !params.DEPLOY_BLUE }
            }
            steps {
                script {
                    echo "Testing application availability at: http://${env.EXTERNAL_IP}"
                    sh "curl -m 10 http://${env.EXTERNAL_IP}"
                }
            }
        }
        stage('Scale Down Blue') {
            when {
                expression { return !params.DEPLOY_BLUE }
            }
            steps {
                script {
                    // Scale down the blue deployment
                    sh """
                    kubectl scale deployment/nginx-blue --replicas=0
                    """
                }
            }
        }
    }
}
