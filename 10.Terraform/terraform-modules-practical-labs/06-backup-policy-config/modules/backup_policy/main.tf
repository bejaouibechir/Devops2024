resource "local_file" "policy" {
  filename = var.output_path
  content = templatefile("${path.module}/templates/backup-policy.yaml.tftpl", {
    policy_name    = var.policy_name
    schedule       = var.schedule
    retention_days = var.retention_days
    targets        = var.targets
  })
}
