pipeline {
    agent any
    stages {
        stage('Setup') {
            steps {
                git branch: 'main', credentialsId: 'Github', url: 'https://github.com/sharara99/Final_Project.git'
            }
        }

        stage('Test Ansible') {
            steps {
                sh "ansible --version"
            }        
        
        stage('Build') {
            steps {
                script {

                    withCredentials([usernamePassword(credentialsId: 'DockerHub', passwordVariable: 'DOCKER_PASS', usernameVariable: 'DOCKER_USER')]) {
                        sh "docker login -u $DOCKER_USER -p $DOCKER_PASS"
                    }
                    
                }
            }
        }
        
    post{ 
        always{ 
            script { 
                def emailNotification = load 'mail-notification.groovy'
                emailNotification.sendEmailNotification()
            } 
        } 
    } 

    }
}
}
