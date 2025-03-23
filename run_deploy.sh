#!/bin/bash

# check if an argument is provided 

if [ "$#" -ne 1 ]; then 
    echo "Usage: $0 <apply|helm >"
    exit 1
fi

DEPLOY_METHOD=$1

echo "Applying Kubernetes Namespace..."
kubectl apply -f k8s/namespace/k8s-namespace.yaml

echo "Deploying PostgreSQL resources..."
kubectl apply -f k8s/postgres/postgres-configmap.yaml
kubectl apply -f k8s/postgres/postgres-storageclass.yaml
kubectl apply -f k8s/postgres/postgres-pv.yaml
kubectl apply -f k8s/postgres/postgres-pvc.yaml
kubectl apply -f k8s/postgres/postgres-deployment.yaml
kubectl apply -f k8s/postgres/postgres-service.yaml

kubectl apply -f k8s/vault/python-api-sa.yaml
kubectl apply -f k8s/vault/service_account_secret.yaml

if [ "$DEPLOY_METHOD" == "apply" ]; then
    
    echo "Deploying API resources using 'kubectl apply'!"
    kubectl apply -f k8s/api/api-configmap.yaml
    kubectl apply -f k8s/api/api-secret.yaml
    kubectl apply -f k8s/api/api-deployment.yaml
    # kubectl apply -f k8s/api/api-service-nodeport.yaml
    kubectl apply -f k8s/api/api-service-clusterip.yaml
    kubectl apply -f k8s/api/api-ingress.yaml
    echo "Kubernetes deployment completed!"
elif [ "$DEPLOY_METHOD" == "helm" ]; then
    echo "Deploying API resources using Helm..."
    # Ensure Helm is installed
    if ! command -v helm &> /dev/null; then
        echo "Helm is not installed. Please install Helm first."
        exit 1
    fi
    helm install -n myapi-dev vault hashicorp/vault -f k8s/vault/values.yaml 
    helm install -n myapi-dev my-api ./helm/api-chart/
    echo "Kubernetes deployment completed!"
else
    echo "Invalid option: $DEPLOY_METHOD"
    echo "Usage: $0 <apply|helm>"
    exit 1
fi
