# Ce module installe Docker sur la machine distante via SSH.
resource "terraform_data" "install" {

  # Cette valeur force Terraform à garder une trace logique de l'installation.
  input = "docker-install"

  # Bloc connection : définit comment se connecter à la machine distante.
  connection {
    type        = "ssh"
    host        = var.remote_host
    user        = var.remote_user
    private_key = file(var.ssh_private_key_path)
  }

  # remote-exec exécute les commandes sur la machine distante via SSH.
  #
  # Toutes les commandes privilégiées sont regroupées dans un seul appel
  # "sudo bash -c '...'" pour éviter l'erreur Terraform :
  # "remote command exited without exit status or exit signal".
  #
  # Cause : inline envoie chaque commande comme une requête SSH séparée.
  # Une commande systemctl peut faire vaciller la session SSH et priver
  # Terraform du code de sortie de la commande suivante.
  # Solution : une seule requête SSH = un seul code de sortie propre.
  provisioner "remote-exec" {
    inline = [
      "sudo bash -c 'apt-get update -y && apt-get install -y docker.io && systemctl enable docker && systemctl start docker && usermod -aG docker ${var.remote_user} && chmod 660 /var/run/docker.sock && docker --version'",
      "touch ${var.marker_file}",
    ]
  }
}
