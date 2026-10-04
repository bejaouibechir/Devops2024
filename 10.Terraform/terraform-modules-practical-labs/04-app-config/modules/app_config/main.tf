resource "local_file" "app_config" {
  filename = var.output_path
  content = templatefile("${path.module}/templates/app-config.yaml.tftpl", {
    app_name    = var.app_name
    environment = var.environment
    port        = var.port
    settings    = var.settings
  })
}
