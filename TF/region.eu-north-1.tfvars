env = "dev"
region = "eu-north-1"
ami_id = "ami-04cdc91e49cb06165"
type = "t3.micro"
name_bucket = "bucketeuygal"
key_pair = "10-09-2024"
azs = data.aws_availability_zones.available_azs.names