
pipeline {
    agent any

    // Parameters shown when starting a Jenkins build
    parameters {

        choice(
            name: 'ENVIRONMENT',
            choices: ['dev', 'production'],
            description: 'Select deployment environment'
        )

        string(
            name: 'IMAGE_TAG',
            defaultValue: 'v1',
            description: 'Enter Docker image tag'
        )

        booleanParam(
            name: 'DEPLOY_TO_SERVERS',
            defaultValue: true,
            description: 'Deploy application to EC2 servers?'
        )
    }

    // Create Docker image name using selected tag
    environment {
        DOCKER_IMAGE = "rushikesh6022/hello-maven:${params.IMAGE_TAG}"
    }

    stages {

        // Stage 1: Checkout source code
        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        // Stage 2: Display selected parameters
        stage('Show Parameters') {
            steps {
                echo "Environment: ${params.ENVIRONMENT}"
                echo "Docker Tag: ${params.IMAGE_TAG}"
                echo "Deployment: ${params.DEPLOY_TO_SERVERS}"
            }
        }

        // Stage 3: Build Java application
        stage('Maven Build') {
            steps {
                sh 'mvn clean package'
            }
        }

        // Stage 4: Archive generated JAR
        stage('Archive Artifact') {
            steps {
                archiveArtifacts artifacts: 'target/*.jar',
                                 fingerprint: true
            }
        }

        // Stage 5: Build Docker image
        stage('Docker Build') {
            steps {
                sh 'docker build -t "$DOCKER_IMAGE" .'
            }
        }

        // Stage 6: Push Docker image to Docker Hub
        stage('Docker Hub Login and Push') {
            steps {
                withCredentials([
                    usernamePassword(
                        credentialsId: 'dockerhub-credentials',
                        usernameVariable: 'DOCKER_USER',
                        passwordVariable: 'DOCKER_TOKEN'
                    )
                ]) {
                    sh '''
                        set -e

                        echo "$DOCKER_TOKEN" | docker login \
                            -u "$DOCKER_USER" --password-stdin

                        docker push "$DOCKER_IMAGE"

                        docker logout
                    '''
                }
            }
        }

        // Stage 7: Deploy only when checkbox is enabled
        stage('Deploy Using Ansible') {
            when {
                expression {
                    return params.DEPLOY_TO_SERVERS
                }
            }

            steps {
                withCredentials([
                    sshUserPrivateKey(
                        credentialsId: 'maven-deploy-ssh-key',
                        keyFileVariable: 'SSH_KEY',
                        usernameVariable: 'SSH_USER'
                    )
                ]) {
                    sh '''
                        set -e

                        export ANSIBLE_HOST_KEY_CHECKING=False

                        ansible-playbook \
                            -i inventory.ini \
                            -u "$SSH_USER" \
                            --private-key "$SSH_KEY" \
                            deploy-docker.yml \
                            -e docker_image="$DOCKER_IMAGE"
                    '''
                }
            }
        }
    }

    // Pipeline result handling
    post {

        success {
            echo "Pipeline completed for ${params.ENVIRONMENT}!"
        }

        failure {
            echo 'Pipeline failed. Check Console Output.'
        }

        always {
            echo 'Pipeline execution finished.'
        }
    }
}

