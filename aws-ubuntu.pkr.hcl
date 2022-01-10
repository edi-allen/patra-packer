packer {
  required_plugins {
    amazon = {
      version = ">= 0.0.2"
      source  = "github.com/hashicorp/amazon"
    }
  }
}

variable "region" {
    type = string
    default = "us-east-2"
}

source "amazon-ebs" "ubuntu" {
  ami_name      = "nginx-cloudwatch-${var.region}"
  instance_type = "t2.micro"
  region        = var.region
  source_ami_filter {
    filters = {
      name                = "ubuntu/images/*ubuntu-xenial-16.04-amd64-server-*"
      root-device-type    = "ebs"
      virtualization-type = "hvm"
    }
    most_recent = true
    owners      = ["099720109477"]
  }
  ssh_username = "ubuntu"
}

build {
  name = "nginx-cloudwatch"
  sources = [
    "source.amazon-ebs.ubuntu"
  ]

  provisioner "file" {
    destination = "/tmp/"
    source      = "./agent-config.json"
  }

  provisioner "file" {
    destination = "/tmp/"
    source      = "./index.html"
  }
  
  provisioner "shell" {
    environment_vars = [
        "FOO=hello world",
    ]
    script = "nginx-cloudwatch-config.sh"
  }
}
