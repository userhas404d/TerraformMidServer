
data "aws_partition" "current" {}

module "iam" {
  source         = "./modules"
  rand_id        = "${random_id.this.hex}"
  aws_partition  = "${data.aws_partition.current.partition}"
}

data "http" "ip" {
  # Get local ip for security group ingress
  url = "http://ipv4.icanhazip.com"
}

data "aws_vpc" "this" {
  default = "true"
}

data "aws_ami" "this" {
  most_recent = true

  filter {
    name   = "name"
    values = ["amzn-ami-hvm-2017.09.*-x86_64-gp2"]
  }

  filter {
    name   = "owner-alias"
    values = ["amazon"]
  }

  name_regex = "amzn-ami-hvm-2017\\.09\\.\\d\\.[\\d]{8}-x86_64-gp2"
}

resource "random_id" "this" {
  keepers = {
    # Generate a new id each time we change the instance_ip
    instance_ip = "${chomp(data.http.ip.body)}"
  }

  byte_length = 8
}

resource "aws_iam_instance_profile" "this" {
  name = "linux-MidServer-${random_id.this.hex}"
  role = "${module.iam.host_role_name}"
}

resource "tls_private_key" "this" {
  algorithm = "RSA"
  rsa_bits  = "4096"
}

resource "aws_key_pair" "this" {
  key_name   = "linux-MidServer-${random_id.this.hex}"
  public_key = "${tls_private_key.this.public_key_openssh}"
}

resource "aws_security_group" "this" {
  name   = "linux-MidServer-${random_id.this.hex}"
  vpc_id = "${data.aws_vpc.this.id}"

  tags {
    Name = "linux-MidServer-${random_id.this.hex}"
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["${chomp(data.http.ip.body)}/32"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

// resource "aws_s3_bucket" "tftemplates" {
//    bucket = "terraform-templates-${random_id.this.hex}"
//    acl = "private"
//
//    tags {
//      Name        = "terraform-templates-${random_id.this.hex}"
//      Environment = "Dev"
//   }
// }
//
// resource "aws_s3_bucket" "tfstate" {
//    bucket = "terraform-state-files-${random_id.this.hex}"
//    acl = "private"
//
//    tags {
//      Name        = "terraform-state-files-${random_id.this.hex}"
//      Environment = "Dev"
//   }
// }

resource "aws_instance" "this" {
  ami                    = "${data.aws_ami.this.id}"
  instance_type          = "t2.micro"
  iam_instance_profile   = "${aws_iam_instance_profile.this.name}"
  key_name               = "${aws_key_pair.this.id}"
  vpc_security_group_ids = ["${aws_security_group.this.id}"]

  tags {
    Name = "linux-MidServer-${random_id.this.hex}"
  }

  provisioner "remote-exec" {
    inline = [
      "set -e",
      "mkdir servicenow && cd servicenow",
      "wget ${var.midserver_installer}",
      "unzip *.zip && cd agent",
      "sed -i s@https:\\/\\/YOUR_INSTANCE.service-now.com@https:\\/\\/${var.MidServerUrl}@g config.xml",
      "sed -i s@YOUR_INSTANCE_USER_NAME_HERE@${var.MidServerUser}@g config.xml",
      "sed -i s@YOUR_INSTANCE_PASSWORD_HERE@${var.MidServerUserPassword}@g config.xml",
      "sed -i s@YOUR_MIDSERVER_NAME_GOES_HERE@${var.MidServerName}@g config.xml",
      "./start.sh",
      "cd ..",
      "rm *.zip",
    ]

    connection {
      port        = 22
      user        = "${var.host_user}"
      private_key = "${tls_private_key.this.private_key_pem}"
    }
  }
}

output "public_ip" {
  description = "Public IP of the EC2 instance"
  value       = "${join("", aws_instance.this.*.public_ip)}"
}

output "private_key" {
  description = "Private key for the keypair"
  value       = "${join("", tls_private_key.this.*.private_key_pem)}"
}
