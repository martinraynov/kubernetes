M = $(shell printf "\033[34;1m▶\033[0m")

######################
### MAIN FUNCTIONS ###
######################

.PHONY: start_vault_dev
start_vault_dev: ## Start the vault application in dev mode
	@vault server -dev -dev-listen-address="192.168.42.1:8200" -dev-root-token-id="test"

.PHONY: init_oidc_dev
init_oidc_dev: ## Init all the rights for an OIDC login
ifndef VAULT_ADDR
	$(error VAULT_ADDR is not set !(Use "VAULT_ADDR=..."  before the build command) )
endif
ifndef OIDC_URL
	$(error OIDC_URL is not set !(Use "OIDC_URL=..."  before the build command) )
endif
ifndef OIDC_CLIENT_ID
	$(error OIDC_CLIENT_ID is not set !(Use "OIDC_CLIENT_ID=..."  before the build command) )
endif
ifndef OIDC_CLIENT_SECRET
	$(error OIDC_CLIENT_SECRET is not set !(Use "OIDC_CLIENT_SECRET=..."  before the build command) )
endif
	@OIDC_URL=${OIDC_URL} OIDC_CLIENT_ID=${OIDC_CLIENT_ID} OIDC_CLIENT_SECRET=${OIDC_CLIENT_SECRET} ./oidc/oidc-k8s-setup.sh

.PHONY: init_vault_agent_dev
init_vault_agent_dev: ## Init all the configs and rights for the Vault Agent
ifndef VAULT_ADDR
	$(error VAULT_ADDR is not set !(Use "VAULT_ADDR=..."  before the build command) )
endif
	@./vault-k8s-setup.sh

.PHONY: start_vault_agent_dev
start_vault_agent_dev: ## Start the vault agent POD
	@kubectl apply -f kisio-k8s-spec.yml --record

.PHONY: stop_vault_agent_dev
stop_vault_agent_dev: ## Stop the vault agent POD
	@kubectl delete -f kisio-k8s-spec.yml

.PHONY: remove_all
remove_all: ## Remove all the Kube config
	@kubectl delete configmap kisio-vault-agent-config
	@kubectl delete serviceaccount vault-auth

.PHONY: help
help: ## Prints this help message
	@grep -E '^[a-zA-Z_-]+:.*## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

.DEFAULT_GOAL := help
