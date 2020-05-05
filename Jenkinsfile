pipeline {
    agent any
    stages {
        stage('Step1') {
            steps {
                    sh 'rexx rexxfile get_lib_info'
                }
            }

        stage('Step2') {
            steps {
                    sh 'rexx rexxfile load_info'
                }
            }

        stage('Step3') {
            steps {
                    sh 'rexx rexxfile allocate_files'
                }
            }

        stage('Step4') {
            steps {
                    sh 'rexx rexxfile load_files'
                }
            }

        }

 }