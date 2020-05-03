pipeline {
    agent { label 'zowe-agent' }
    environment {
        // z/OS Host Information
        ZOWE_OPT_HOST=credentials('eosHost')
    }
    stages {
        stage('Step1') {
            steps {
                    sh 'rexx rexxfile step1'
                }
            }

        stage('Step2') {
            steps {
                    sh 'rexx rexxfile step2'
                }
            }

        stage('Step3') {
            steps {
                    sh 'rexx rexxfile step3'
                }
            }

        stage('Step4') {
            steps {
                    sh 'rexx rexxfile step4'
                }
            }

        stage('Step5') {
            steps {
                    sh 'rexx rexxfile step5'
                }
            }
        }

 }