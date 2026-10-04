resource "local_file" "compose" {
  filename = var.output_path
  content = templatefile("${path.module}/templates/docker-compose.yml.tftpl", {
    service_name = var.service_name
    image        = var.image
    ports        = var.ports
    environment  = var.environment
  })
}
