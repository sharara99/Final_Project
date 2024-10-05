pipeline {
    agent any
    stages {
        stage('Docker Login') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'dockerhub', passwordVariable: 'dockerpass', usernameVariable: 'dockeruser')]) {
                    sh 'echo $dockerpass | docker login -u $dockeruser --password-stdin'
                }
            }
        }
        stage('Test Ansible') {
            steps {
                sh "ansible --version"
            }
        }
        stage('Build & push & run cont') {
            steps { 
                sh "ansible-playbook -i ./inventory.txt ansible-playbook.yml"
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
