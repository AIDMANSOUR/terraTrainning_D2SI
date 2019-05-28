terraform {
   backend "s3" {
    bucket = "my-tfstat-bucket"
    key = "vpc/terraform.tfstat"
    region = "eu-west-1"
    dynamodb_table = "foo"
    }
}
