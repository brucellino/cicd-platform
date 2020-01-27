data "local_file" "manifest" {
  filename = "${path.module}/manifest.json"
}

output "ami_id" {
  value = trimprefix(
            lookup(
              element(
                lookup(
                  jsondecode(data.local_file.manifest.content),
                "builds"),
              1),
            "artifact_id"),
          "eu-central-1:")
}
