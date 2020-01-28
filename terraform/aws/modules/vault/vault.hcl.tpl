storage "file" {
  path = "/mnt/vault/data"
}

ui = true

listener "tcp" {
  address = "${ip}:8200"
  disable_tls = 1
}
