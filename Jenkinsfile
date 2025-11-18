pipeline {
  agent any

  environment {
    AWS_REGION = 'us-east-1'
    KEY_NAME   = 'mi-keypair'
  }

  stages {
    stage('Checkout') {
      steps {
        checkout scm
      }
    }

    stage('Pruebas unitarias') {
      steps {
        sh '''
          python3 -m venv venv || true
          . venv/bin/activate
          pip install -r app/requirements.txt
          pip install pytest
          pytest -q --junitxml=results.xml
        '''
      }
      post {
        always {
          junit 'results.xml'
        }
      }
    }

    stage('Terraform Init/Apply') {
      steps {
        dir('terraform') {
          sh '''
            terraform init -input=false
            terraform apply -auto-approve \
              -var="aws_region=${AWS_REGION}" \
              -var="key_name=${KEY_NAME}"
          '''
        }
      }
    }

    stage('Generar Inventory dinámico') {
      steps {
        script {
          def ip = sh(script: "cd terraform && terraform output -raw public_ip", returnStdout: true).trim()
          writeFile file: 'ansible/inventory.json', text: """
          {
            "app": {
              "hosts": ["${ip}"],
              "vars": {
                "ansible_user": "ec2-user",
                "ansible_ssh_private_key_file": "~/.ssh/${KEY_NAME}.pem"
              }
            }
          }
          """
        }
      }
    }

    stage('Desplegar con Ansible') {
      steps {
        sh '''
          ansible-playbook -i ansible/inventory.json ansible/playbook.yml
        '''
      }
    }

    stage('Smoke Test') {
      steps {
        script {
          def ip = sh(script: "cd terraform && terraform output -raw public_ip", returnStdout: true).trim()
          sh "curl -s http://${ip}:5000/health | grep 'ok'"
        }
      }
    }
  }

  post {
    always {
      echo 'Pipeline finalizado.'
    }
    success {
      echo 'Despliegue exitoso'
    }
    failure {
      echo 'Existe error'
    }
  }
}
