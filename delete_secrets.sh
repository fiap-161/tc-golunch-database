#!/bin/bash
set -e

SECRETS=("golunch/db-url")

for SECRET in "${SECRETS[@]}"; do
  echo "Verificando secret: $SECRET"

  if aws secretsmanager describe-secret --secret-id "$SECRET" --region us-east-1 >/dev/null 2>&1; then
    echo "Secret $SECRET existe. Forçando exclusão..."
    ARN=$(aws secretsmanager describe-secret --secret-id "$SECRET" --region us-east-1 --query 'ARN' --output text)
    aws secretsmanager delete-secret --secret-id "$ARN" --region us-east-1 --force-delete-without-recovery
  else
    echo "Secret $SECRET não existe."
  fi
done