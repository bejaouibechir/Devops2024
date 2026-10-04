locals {
  parts = [
    lower(var.project),
    lower(var.environment),
    lower(var.resource_type),
    var.instance,
  ]

  name        = join(var.separator, local.parts)
  name_prefix = join(var.separator, slice(local.parts, 0, 2))
}
