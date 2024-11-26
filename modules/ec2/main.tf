resource "aws_instance" "this" {
  count                  = var.instance_count
  ami                    = var.ami_id
  instance_type          = var.instance_type
  subnet_id              = element(var.subnet_ids, count.index % length(var.subnet_ids))
  vpc_security_group_ids = var.security_group_ids
  iam_instance_profile   = var.iam_instance_profile
  # Configure SSH key
  key_name = var.key_name

  # Configure user and password authentiction
  # user_data = <<-EOF
  #             #!/bin/bash
  #             # Update Packages
  #             yum update -y
  #             #Configure SSHD daemon
  #             sed -i 's/^#PasswordAuthentication no/PasswordAuthentication yes/' /etc/ssh/sshd_config
  #             sed -i 's/^PasswordAuthentication no/PasswordAuthentication yes/' /etc/ssh/sshd_config
  #             sed -i 's/^#ChallengeResponseAuthentication no/ChallengeResponseAuthentication yes/' /etc/ssh/sshd_config
  #             sed -i 's/^#PubkeyAuthentication yes/PubkeyAuthentication no/' /etc/ssh/sshd_config
  #             sed -i 's/^PubkeyAuthentication yes/#PubkeyAuthentication no/' /etc/ssh/sshd_config
  #             # Restart SSH service
  #             systemctl restart sshd
  #             # Create user and password
  #             useradd ${var.username}
  #             echo "${var.username}:${var.password}" | chpasswd
  #             EOF

  root_block_device {
    delete_on_termination = true
  }

  tags = {
    Name = "${var.prefix_instance_name}-${count.index + 1}"
  }

}

resource "aws_eip" "eip_instances" {
  count    = var.eip_count
  instance = aws_instance.this[count.index].id
}