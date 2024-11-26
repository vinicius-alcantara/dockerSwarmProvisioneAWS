resource "aws_ebs_volume" "this" {
  count             = length(var.instance_ids)
  availability_zone = data.aws_instance.this[count.index].availability_zone
  size              = var.volume_sizes[count.index]
  type              = var.volume_types[count.index % length(var.volume_types)]
}

resource "aws_volume_attachment" "this" {
  count        = length(var.instance_ids)
  device_name  = "/dev/sd${element(["b", "c", "d", "e"], count.index % 4)}"
  volume_id    = aws_ebs_volume.this[count.index].id
  instance_id  = var.instance_ids[count.index]
  force_detach = true
}

data "aws_instance" "this" {
  count       = length(var.instance_ids)
  instance_id = var.instance_ids[count.index]
}