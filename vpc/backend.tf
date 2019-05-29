terraform {
   backend "s3" {
    bucket = "my-tfstat-bucket1"
    key = "vpc/terraform.tfstat"
    region = "eu-west-1"
    dynamodb_table = "foo"
    }
}
