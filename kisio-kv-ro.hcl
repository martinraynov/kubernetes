# For K/V v1 secrets engine
path "secret/kisio/*" {
    capabilities = ["read", "list"]
}

# For K/V v2 secrets engine
path "secret/data/kisio/*" {
    capabilities = ["read", "list"]
}
