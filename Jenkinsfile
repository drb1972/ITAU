pipeline {
    agent any
    stages {
        stage('get_lib_info') {
            steps {
                    sh 'rexx clone get_lib_info'
                }
            }

        stage('load_info') {
            steps {
                    sh 'rexx clone load_info'
                }
            }

        stage('allocate_files') {
            steps {
                    sh 'rexx clone allocate_files'
                }
            }

        stage('load_files') {
            steps {
                    sh 'rexx clone load_files'
                }
            }

        }

 }