#!/bin/bash

# Variables
VAULT_POD="vault-0"
NAMESPACE="myapi-dev"
SECRET_NAME="vault-keys"

# Function to initializing Vault
initialized_vault() {
    echo "Initialized Vault ...."
    INIT_OUTPUT=$(kubectl exec -n $NAMESPACE $VAULT_POD -- vault operator init -format=json)
    if [ $? -ne 0 ]; then
      echo "Failed to initialize Vault."
      exit 1
    fi

    UNSEAL_KEYS=$(echo $INIT_OUTPUT | jq -r '.unseal_keys_b64[]')
    ROOT_TOKEN=$(echo $INIT_OUTPUT | jq -r '.root_token')

    # Create kubernetes Secret 
    kubectl create secret generic $SECRET_NAME -n $NAMESPACE \
      --from-literal=unseal_keys="$(echo $UNSEAL_KEYS | tr ' ' ',')" \
      --from-literal=root_token="$ROOT_TOKEN"
    if [ $? -eq 0 ]; then
      echo "Unseal keys and root token stored in Kubernetes Secret: $SECRET_NAME"
    else
      echo "Failed to create Kubernetes Secret."
      exit 1
    fi
}

# Function to unseal Vault
unseal_vault() {
    echo "Unsealing Vault...."
    for KEY in $UNSEAL_KEYS; do
       kubectl exec -n $NAMESPACE $VAULT_POD -- vault operator unseal $KEY
    done
}

# Function to check Vault status
check_vault_status() {
    echo "Checking Vault status..."
    STATUS=$(kubectl exec -n $NAMESPACE $VAULT_POD -- vault status -format=json)
    if [ $? -eq 0 ]; then
      echo "Failed to check Vault status."
      exit 1
    fi

    echo $STATUS | jq
}

# Check if vault is already initialized
INITIALIZED=$(kubectl exec -n $NAMESPACE $VAULT_POD -- vault status -format=json | jq -r '.initialized')
if [ "$INITIALIZED" == "false" ]; then
  initialized_vault
fi

# Unseal Vault
SEALED=$(kubectl exec -n $NAMESPACE $VAULT_POD -- vault status -format=json |jq -r '.sealed')
if [ "$SEALED" == "true" ]; then
  unseal_vault
fi

echo "Vault initialization and unsealing complete."