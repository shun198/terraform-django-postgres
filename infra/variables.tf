# ------------------------------
# Variables
# ------------------------------

# プリフィックスを設定
variable "prefix" {
  default = "tf-pg"
}

# プロジェクトを識別する一意の識別子を設定
variable "project" {
  default = "terraform-playground"
}

# プロジェクトのオーナーを設定
variable "owner" {
  default = "shun198"
}

# プロジェクトのオーナーを設定
variable "db_username" {
  description = "Username for the RDS postgres instance"
}

variable "db_password" {
  description = "Password for the RDS postgres instance"
}