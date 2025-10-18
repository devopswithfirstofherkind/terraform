data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}



resource "aws_vpc" "webserver-vpc" {
  cidr_block = "172.16.0.0/16"

  tags = {
    Name = "tf-vpc"
  }
}

resource "aws_subnet" "webserver-subnet" {
  vpc_id            = aws_vpc.webserver-vpc.id
  cidr_block        = "172.16.10.0/24"
  availability_zone = "us-east-1a"

  tags = {
    Name = "tf-subnet"
  }
}

resource "aws_network_interface" "webserver-NIC" {
  subnet_id   = aws_subnet.webserver-subnet.id
  private_ips = ["172.16.10.100"]

  tags = {
    Name = "primary_network_interface"
  }
}


resource "aws_key_pair" "deployer" {
  key_name   = "deployer"
  public_key = var.public_key
}

resource "aws_instance" "mywebserverr" {
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = "t2.small"
  key_name                    = aws_key_pair.deployer.id
  subnet_id                   = aws_subnet.webserver-subnet.id
  associate_public_ip_address = true


}


resource "aws_s3_bucket" "s3" {
  bucket = "firstofherkind-demo-bucket"
}

resource "aws_s3_bucket_ownership_controls" "s3" {
  bucket = aws_s3_bucket.s3.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_acl" "s3" {
  depends_on = [aws_s3_bucket_ownership_controls.s3]

  bucket = aws_s3_bucket.s3.id
  acl    = "private"
}