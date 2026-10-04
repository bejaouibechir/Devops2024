output "tags" {
  description = "Map de tags standardises (standards + extra_tags)"
  value       = merge(local.standard_tags, var.extra_tags)
}
