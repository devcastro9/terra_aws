pipeline {
  agent any

  environment {
    AWS_REGION = 'us-east-1'
    // Configura tus credenciales en Jenkins (ej. AWS, SSH)
  }

  stages {
    stage('Checkout') {
      steps {
        checkout scm
      }
    }

    stage('Instalar dependencias') {
      steps {
        sh 'python3 -m venv venv || true'
        sh '. venv/bin/activate && pip install -r app/requirements.txt && pip install pytest'
      }
    }

    stage('Pruebas') {
      steps {
        sh '. venv/bin/activate && pytest -q'
      }
      post {
        always {
          junit testResults: '**/pytest*.xml', allowEmptyResults: true
        }
      }
    }

    stage('Terraform Init/Plan') {
      steps {
        dir('terraform') {
          sh 'terraform init -input=false'
          sh 'terraform validate'
          sh 'terraform plan -var="aws_region=${AWS_REGION}" -var="key_name=$KEY_NAME" -out tfplan'
        }
      }
    }

    stage('Terraform Apply (manual)') {
      when {
        expression { return params.APPLY == true }
      }
      steps {
        dir('terraform') {
          sh 'terraform apply -auto-approve tfplan'
        }
      }
    }

    stage('Ansible Deploy') {
      steps {
        sh 'which ansible-playbook || sudo apt-get update && sudo apt-get install -y ansible'
        sh 'ansible --version'
        sh 'ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -i ansible/inventory ansible/playbook.yml'
      }
    }
  }

  parameters {
    booleanParam(name: 'APPLY', defaultValue: false, description: 'Aplicar cambios de Terraform')
  }

  post {
    always {
      echo 'Pipeline finalizado.'
    }
  }
}
