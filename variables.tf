variable "region" {
    description = "Region for deployment (default matches AMI)"
    type        = string
    default     = "us-east-1"
}

variable "ami-linux" {
    description = "AMI de Amazon Linux 2 en us-east-1"
    type        = string
    default = "ami-0532be01f26a3de55"
  
}