pipeline {
    agent any
    stages {
        stage('Step1') {
            steps {
                    sh 'rexx clone get_lib_info'
                }
            }

        stage('Step2') {
            steps {
                    sh 'rexx clone load_info'
                }
            }

        stage('Step3') {
            steps {
                    sh 'rexx clone allocate_files'
                }
            }

        stage('Step4') {
            steps {
                    sh 'rexx clone load_files'
                }
            }

        }

 }