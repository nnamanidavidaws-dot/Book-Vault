variable "azs" {
  #type    = list(string)
  default = ["us-east-1a", "us-east-1b"]
}

variable "db_username" {
  sensitive = true
}

variable "db_password" {
  sensitive = true
}

variable "db_nosql_username" {
  sensitive = true
}

variable "db_nosql_password" {
  sensitive = true
}