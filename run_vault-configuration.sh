#!/bin/bash

# Variables
NAMESPACE="myapi-dev"
SECRET_NAME="vault-keys"
VAULT_POD="vault-0"
SERVICE_ACCOUNT="python-api-sa"
SERVICE_ACCOUNT_SECRET=python-api-sa-token
VAULT_ROLE="fastapi-app"
VAULT_POLICY="app-policy"
SECRET_PATH="secret/data/auth"
VAULT_ADDR="http://localhost:8200/"


VAULT_TOKEN=$(kubectl get secret $SECRET_NAME -n $NAMESPACE -o jsonpath="{.data.root_token}" | base64 --decode)

# # Authenticate with Vault
export VAULT_ADDR=$VAULT_ADDR
export VAULT_TOKEN=$VAULT_TOKEN


# Start port forwarding in the background
echo "Starting port forwarding..."
kubectl port-forward -n $NAMESPACE $VAULT_POD 8200:8200 &

# Wait for port forwarding to establish
echo "Waiting for port forwarding to stabilize..."
sleep 5 

# Enable Kubernetes authentication
echo "Enabling Kubernetes authentication..."
vault auth enable kubernetes

echo "Enabling secret path..."
vault secrets enable -path=secret kv-v2


# # Extract and decode the CA certificate
kubectl get secret $SERVICE_ACCOUNT_SECRET -n $NAMESPACE -o jsonpath="{.data.ca\.crt}" | base64 --decode > ca.crt

# Configure Kubernetes authentication
echo "Configuring Kubernetes authentication..."
vault write auth/kubernetes/config \
  token_reviewer_jwt="$TOKEN" \
  kubernetes_host="https://kubernetes.default.svc.cluster.local" \
  kubernetes_ca_cert=@ca.crt

# Create a policy for the application
echo "Creating Vault policy..."
vault policy write $VAULT_POLICY - <<EOF
  path "$SECRET_PATH" {
    capabilities = ["read"]
  }
  path "secret/data/data/auth" {
    capabilities = ["read"]
  }
  path "secret/metadata/auth" {
    capabilities = ["read", "list"]
  }
EOF

# Create a role for Kubernetes authentication
echo "Creating Vault role..."
vault write auth/kubernetes/role/$VAULT_ROLE \
  bound_service_account_names=$SERVICE_ACCOUNT \
  bound_service_account_namespaces=$NAMESPACE \
  policies=$VAULT_POLICY \
  ttl=1h

# Store secrets in Vault
echo "Storing secrets in Vault..."
vault kv put $SECRET_PATH testuser=testuser testpass=testpass

echo "Vault configuration completed!"