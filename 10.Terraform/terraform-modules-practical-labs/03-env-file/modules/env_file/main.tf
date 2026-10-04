locals {
  env_content = join("\n", [
    for key, value in var.variables : "${upper(key)}=${value}"
  ])
}

resource "local_file" "env" {
  filename = var.output_path
  content  = "${local.env_content}\n"
}
