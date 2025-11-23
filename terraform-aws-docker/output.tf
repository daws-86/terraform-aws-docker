output "public_ip" {
description = "the ip of public for nginx application"
value = aws_instance.docker_ec2.public_ip
}

