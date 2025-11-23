resource "aws_instance" "docker_ec2" {
  ami           = "ami-0c02fb55956c7d316" # Amazon Linux 2
  instance_type = "t2.micro"
  vpc_security_group_ids = [aws_security_group.allow_http.id]
  user_data = <<-EOF
    #!/bin/bash
    # -------------------------------------------
    # EC2 bootstrap: Docker + HTML + Run Container
    # -------------------------------------------
    yum update -y
    # Install Docker
    amazon-linux-extras install docker -y
    systemctl enable docker
    systemctl start docker
    # Allow ec2-user to run docker
    usermod -aG docker ec2-user
    # Install AWS CLI (optional)
    yum install -y aws-cli
    # Create directory
    mkdir -p /opt/app
    cd /opt/app
    # Create Dockerfile
    cat << 'EOD' > Dockerfile
    FROM nginx:latest
    COPY index.html /usr/share/nginx/html/index.html
    EXPOSE 80
    CMD ["nginx", "-g", "daemon off;"]
    EOD
    # Create HTML page
    cat << 'EOD' > index.html
    <h1>my-project hasbeen created successfully: Terraform + Docker Build + Docker Run</h1>
    <p>App deployed successfully!</p>
    EOD
    # Build Docker image
    docker build -t my-nginx-image .
    # Run container on port 80
    docker run -d --name myweb -p 80:80 my-nginx-image
  EOF
  tags = {
    Name = "Docker-EC2"
  }
}
