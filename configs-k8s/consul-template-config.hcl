vault {
  renew_token = false
  vault_agent_token_file = "/home/vault/.vault-token"
  retry {
    backoff = "10s"
  }
}

template {
  destination = "/etc/secrets/index.html"
  contents = <<EOH
  {{- with secret "secret/data/kisio/config" }}
  <ul>
  <li><pre>username: {{ .Data.data.username }}</pre></li>
  <li><pre>password: {{ .Data.data.password }}</pre></li>
  </ul>
  {{ end }}
  EOH
}
