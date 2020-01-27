storage "file" {
  path = "/mnt/vault/data"
}

listenr "tcp" {
  address = "0.0.0.0:8200"
}
