
pipeline {
    agent any

    stages {

        stage('Checkout') {
            steps {
                checkout scm
                echo 'Source code checked out'
            }
        }

        stage('Check Tools') {
            steps {
                sh 'java -version'
                sh 'mvn -version'
                sh 'ansible --version'
            }
        }

        stage('Build') {
            steps {
                sh 'mvn clean package'
            }
        }

        stage('Archive Artifact') {
            steps {
                archiveArtifacts artifacts: 'target/*.jar',
                                 fingerprint: true
            }
        }

        stage('Deploy Using Ansible') {
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
        			deploy-maven.yml
			'''
                }
            }
        }
    }

    post {
        success {
            echo 'Jenkins + Ansible deployment completed successfully!'
        }

        failure {
            echo 'Deployment failed. Check Console Output.'
        }

        always {
            echo 'Pipeline execution finished.'
        }
    }
}

