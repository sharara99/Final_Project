pipeline {
    agent any
    stages {
        stage('Docker Login') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'dockerhub', passwordVariable: 'dockerpass', usernameVariable: 'dockeruser')]) {
                    sh "docker login -u $dockeruser -p $dockerpass"
                }
            }
        }
        stage('Build & push & run cont') {
            steps {
                sh "ansible-playbook ansible-playbook.yml"
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