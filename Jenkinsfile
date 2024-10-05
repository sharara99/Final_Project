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
                withCredentials([file(credentialsId: 'key', variable: 'PEM_KEY')]) {
                    sh 'ansible-playbook -i inventory.txt ansible-playbook.yml --private-key=$PEM_KEY'
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
