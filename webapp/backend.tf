terraform {
   backend "s3" {
    bucket = "my-tfstat-bucket1"
    key = "webapp/terraform.tfstat"
    region = "eu-west-1"
    }
}