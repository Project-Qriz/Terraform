variable "environment" {
  type = string
}

variable "region" {
  type = string
}

variable "vpc_cidr" {
  type = string
}

variable "public_subnets" {
  type = list(string)
}

variable "private_subnets" {
  type = list(string)
}

variable "availability_zones" {
  type = list(string)
}

variable "nat_instance_eni_id" {
  type = string
}

# Transit Gateway 관련 변수 추가
variable "enable_tgw" {
  description = "Transit Gateway 활성화 여부"
  type        = bool
  default     = false
}

variable "tgw_destination_cidr" {
  description = "Transit Gateway를 통해 라우팅할 대상 CIDR"
  type        = string
  default     = ""
}