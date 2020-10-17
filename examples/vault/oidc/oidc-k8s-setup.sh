#!/bin/bash

# CHeck if variables are set and init if needed
if [ -z "${OIDC_URL}" ]; then read -p "OIDC_URL: " OIDC_URL; fi
if [ -z "${OIDC_CLIENT_ID}" ]; then read -p "OIDC_CLIENT_ID: " OIDC_CLIENT_ID; fi
if [ -z "${OIDC_CLIENT_SECRET}" ]; then read -p "OIDC_CLIENT_SECRET: " OIDC_CLIENT_SECRET; fi

# Enable oidc auth method
vault auth enable oidc

# Configure the oidc auth method
vault write auth/oidc/config \
        oidc_discovery_url="${OIDC_URL}" \
        oidc_client_id="${OIDC_CLIENT_ID}" \
        oidc_client_secret="${OIDC_CLIENT_SECRET}" \
        default_role="reader"

# Create the reader Default Role
vault write auth/oidc/role/reader \
        bound_audiences="vault" \
        allowed_redirect_uris="http://192.168.42.1:8200/ui/vault/auth/oidc/oidc/callback" \
        allowed_redirect_uris="http://192.168.42.1:8200/oidc/callback" \
        user_claim="sub" \
        policies="reader"
