# Leeme

## 1. Entrar al directorio del proyecto
cd terra_aws/terraform

## 2. Inicializar
terraform init -input=false

## 3. Validar
terraform validate

## 4. Planificar
terraform plan -var="aws_region=us-east-1" -var="key_name=${AWS_KEY_FILE}$" -out=tfplan

## 5. Aplicar
terraform apply -auto-approve tfplan

## 6. Obtener la IP pública de la instancia creada
terraform output -raw public_ip

## 7. Destruir la infraestructura al final si es un entorno efímero
terraform destroy -auto-approve -var="aws_region=us-east-1" -var="key_name=${AWS_KEY_FILE}"
