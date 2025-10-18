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



resource "aws_instance" "mywebserver" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t2.micro"



  network_interface {
    network_interface_id = aws_network_interface.webserver-NIC.id
    device_index         = 0
  }


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