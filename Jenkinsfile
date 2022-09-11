pipeline {
  //agent any
  agent any
  tools {
      maven '3.8.6'
  }
  stages {
    stage('deploy-to-exchange') {
      steps {
        // deploys the same binary zip file exchange
        
        sh "mvn clean deploy"
      }
    }
    stage('deploy-to-rtf') {
      steps {
        sh './deploy.sh'
    }
      post {
        success {
          sh 'echo RTF CICD all done!  '
        }
      }
    }
  }
}
