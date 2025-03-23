#!/bin/bash

# check if an argument is provided 

if [ "$#" -ne 1 ]; then 
    echo "Usage: $0 <apply|helm >"
    exit 1
fi

DEPLOY_METHOD=$1

if [ "$DEPLOY_METHOD" == "apply" ]; then
    echo "Deleting API resources using 'kubectl apply'!"
    kubectl delete -f k8s/api/api-service-clusterip.yaml
    kubectl delete -f k8s/api/api-ingress.yaml
    kubectl delete -f k8s/api/api-deployment.yaml
    kubectl delete -f k8s/api/api-secret.yaml
    kubectl delete -f k8s/api/api-configmap.yaml
elif [ "$DEPLOY_METHOD" == "helm" ]; then
    echo "Deleting API resources using 'using Helm'!"
    helm uninstall -n myapi-dev vault
    helm uninstall -n myapi-dev my-api
else
    echo "Invalid option: $DEPLOY_METHOD"
    echo "Usage: $0 <apply|helm>"
    exit 1
fi
kubectl delete -f k8s/vault/python-api-sa.yaml
kubectl delete -f k8s/vault/service_account_secret.yaml
echo "Deleting PostgreSQL resources..."
kubectl delete -f k8s/postgres/postgres-service.yaml
kubectl delete -f k8s/postgres/postgres-deployment.yaml
kubectl delete -f k8s/postgres/postgres-pvc.yaml
kubectl delete -f k8s/postgres/postgres-pv.yaml
kubectl delete -f k8s/postgres/postgres-storageclass.yaml
kubectl delete -f k8s/postgres/postgres-configmap.yaml

echo "Deleting Kubernetes Namespace..."
kubectl delete -f k8s/namespace/k8s-namespace.yaml

echo "All Kubernetes resources have been deleted!"
