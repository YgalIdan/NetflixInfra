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
  profile = "default"  # change in case you want to work with another AWS account profile
}

resource "aws_security_group" "netflix_app_sg" {
  name        = "TF-netflix-app-sg"   # change <your-name> accordingly
  description = "Allow SSH and HTTP traffic"

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
  ami           = var.ami_id
  depends_on  = [aws_s3_bucket.s3netflix]
  instance_type = var.type
  security_groups = [aws_security_group.netflix_app_sg.name]
  key_name = var.key_pair
  availability_zone = "${var.region}a"
  user_data = file("./deploy.sh")
  tags = {
    Name = "tf_1"
  }
}

resource "aws_ebs_volume" "AddNetflixVolume" {
  availability_zone = "${var.region}a"
  size              = 5

  tags = {
    Name = "netflix"
  }
}