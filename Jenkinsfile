pipeline {
  agent any

  parameters {
    choice(name: 'ACTION', choices: ['apply', 'destroy'], description: 'Create or delete the infrastructure')
  }

  environment {
    AWS_ACCESS_KEY_ID     = credentials('aws-access-key-id')      // Secret text
    AWS_SECRET_ACCESS_KEY = credentials('aws-secret-access-key')  // Secret text
    AWS_DEFAULT_REGION    = 'ap-south-1'
  }

  stages {
    stage('Checkout') {
      steps { checkout scm }
    }

    stage('Terraform Init') {
      steps { sh 'terraform init -input=false' }
    }

    stage('Terraform Plan') {
      steps {
        script {
          def flag = (params.ACTION == 'destroy') ? '-destroy' : ''
          sh "terraform plan ${flag} -input=false -out=tfplan"
        }
      }
    }

    stage('Approval') {
      steps { input message: "Proceed with ${params.ACTION}?", ok: 'Yes' }
    }

    stage('Terraform Apply') {
      steps { sh 'terraform apply -input=false tfplan' }
    }

    stage('Show URL') {
      when { expression { params.ACTION == 'apply' } }
      steps { sh 'terraform output website_url' }
    }
  }
}
