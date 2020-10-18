#!/bin/bash

# Create a service account, 'vault-auth'
kubectl create serviceaccount vault-auth

# Update the 'vault-auth' service account
kubectl apply --filename vault-auth-service-account.yml

# Create a policy named kisio-kv-ro
vault policy write kisio-kv-ro kisio-kv-ro.hcl

# Enable K/V v1 at secret/ if it's not already available
# vault secrets enable -path=secret kv

# Create the configmap that will be used by the pods
kubectl create configmap kisio-vault-agent-config --from-file=./configs-k8s/

# Create test data in the `secret/kisio` path.
vault kv put secret/kisio/config username='martin' password='martin_pass' ttl='10s'
vault secrets tune -default-lease-ttl=30s -max-lease-ttl=1m secret/kisio/config

# Enable userpass auth method
# vault auth enable userpass

# Create a user named "kisio-user"
# vault write auth/userpass/users/kisio-user password=training policies=kisio-kv-ro

# Set VAULT_SA_NAME to the service account you created earlier
export VAULT_SA_NAME=$(kubectl get sa vault-auth -o jsonpath="{.secrets[*]['name']}")

# Set SA_JWT_TOKEN value to the service account JWT used to access the TokenReview API
export SA_JWT_TOKEN=$(kubectl get secret $VAULT_SA_NAME -o jsonpath="{.data.token}" | base64 --decode; echo)

# Set SA_CA_CRT to the PEM encoded CA cert used to talk to Kubernetes API
export SA_CA_CRT=$(kubectl get secret $VAULT_SA_NAME -o jsonpath="{.data['ca\.crt']}" | base64 --decode; echo)

# Set K8S_HOST to minikube IP address
# export K8S_HOST=$(minikube ip)
export K8S_HOST=10.152.183.1
export K8S_PORT=443

# Enable the Kubernetes auth method at the default path ("auth/kubernetes")
vault auth enable kubernetes

# Tell Vault how to communicate with the Kubernetes (Minikube) cluster
# vault write auth/kubernetes/config token_reviewer_jwt="$SA_JWT_TOKEN" kubernetes_host="https://$K8S_HOST:$K8S_PORT" kubernetes_ca_cert="$SA_CA_CRT"
vault write auth/kubernetes/config token_reviewer_jwt="$SA_JWT_TOKEN" kubernetes_host="https://$K8S_HOST:$K8S_PORT" kubernetes_ca_cert="$SA_CA_CRT"

# Create a role named, 'kisio' to map Kubernetes Service Account to
# Vault policies and default token TTL
vault write auth/kubernetes/role/kisio bound_service_account_names=vault-auth bound_service_account_namespaces=default policies=kisio-kv-ro ttl=24h

# Create a symbolic link for the nginx folder
# Error when using symlink and the mount of the containers 
# ln -s ${PWD}/nginx /tmp/kube-vault-nginx
cp -R ./nginx /tmp/kube-vault-nginx