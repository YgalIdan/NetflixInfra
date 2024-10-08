terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">=5.55"
    }
  }

  backend "s3" {
    bucket = "ygal-tf-state"
    key    = "tfstate.json"
    region = "us-east-1"
    # optional: dynamodb_table = "<table-name>"
  }

  required_version = ">= 1.7.0"
}

provider "aws" {
  region  = var.region
}

resource "aws_security_group" "netflix_app_sg" {
  name        = "TF-netflix-app-sg"   # change <your-name> accordingly
  description = "Allow SSH and HTTP traffic"
  vpc_id      = module.netflix_app_vpc.vpc_id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_s3_bucket" "s3netflix" {
  bucket = var.name_bucket

  tags = {
    Name        = "bucket_tf"
    Environment = "Dev"
  }
}

resource "aws_volume_attachment" "ebs_att" {
  device_name = "/dev/sdh"
  volume_id   = aws_ebs_volume.AddNetflixVolume.id
  instance_id = aws_instance.netflix_app.id
}

resource "aws_instance" "netflix_app" {
  ami           = data.aws_ami.ubuntu_ami.id
  depends_on  = [aws_s3_bucket.s3netflix]
  instance_type = var.type
  key_name = var.key_pair
  user_data = file("./deploy.sh")
  subnet_id   = module.netflix_app_vpc.public_subnets[0]
  vpc_security_group_ids = [aws_security_group.netflix_app_sg.id]

  tags = {
    Name = var.env
  }
}

resource "aws_ebs_volume" "AddNetflixVolume" {
  availability_zone = aws_instance.netflix_app.availability_zone
  size              = 5

  tags = {
    Name = "netflix"
  }
}

module "netflix_app_vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.8.1"

  name = "netflix-app"
  cidr = "10.0.0.0/16"

  azs             = data.aws_availability_zones.available_azs.names
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24"]
  public_subnets  = ["10.0.3.0/24", "10.0.4.0/24"]

  enable_nat_gateway = false
  map_public_ip_on_launch = true

  tags = {
    Env         = var.env
  }
}