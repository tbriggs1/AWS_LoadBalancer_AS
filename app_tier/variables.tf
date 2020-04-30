variable "vpc_id" {
  description = "pass the vpc id to app tier"
}

variable "name" {
  description = "pass the name to app tier"
}

variable "gateway_id" {
  description = "pass the gateway id to app tier"
}

variable "db_private_ip" {
  description = "pass the db private ip to the app tier"
}

variable "app_ami_id" {
  description = "ami id"
}

variable "name1" {
  default = "app-FP1"
}

variable "name2" {
  default = "app-FP2"
}
