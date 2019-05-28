# AWS provider
provider "aws" {
  region = "${var.aws_region}"
}

## Bucket pour le tfstate"
resource "aws_s3_bucket" "terraform_backend" {
bucket = "my-tfstat-bucket"
acl = "private"

tags {
    Name = "labs1"
  }
}

resource "aws_dynamodb_table" "terraform_labs_lock" {
    name = "foo"
    read_capacity = 1
    write_capacity = 1
    hash_key = "LockID"

    attribute {
        name = "LockID"
        type = "S"
    }
  }