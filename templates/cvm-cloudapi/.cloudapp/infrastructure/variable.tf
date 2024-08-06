# ==========================================================
#               下方变量通常需要根据实际情况修改
# ==========================================================

# CVM 镜像ID
variable "cvm_image_id" {
  type    = string
  default = "img-8epmk362"
}

# CVM 系统盘类型
variable "cvm_system_disk_type" {
  type    = string
  default = "CLOUD_HSSD"
}

# CVM 系统盘大小，单位：GB
variable "cvm_system_disk_size" {
  type    = number
  default = 50
}

# CVM 公网IP（与最大带宽同时存在）
variable "cvm_public_ip" {
  type    = bool
  default = true
}

# CVM 最大公网带宽
variable "max_bandwidth" {
  type    = number
  default = 1
}

# CVM 计费方式
variable "cvm_charge_type" {
  type    = string
  default = "POSTPAID_BY_HOUR"
}


# ==========================================================
#                     下方变量通常不需要修改
# ==========================================================

# CVM 机型选择变量
variable "cvm_type" {
  type = object({
    region        = string
    region_id     = string
    zone          = string
    instance_type = string
  })
}

# 用户选择的安装目标位置，VPC 和子网，在 package.yaml 中定义了输入组件
variable "app_target" {
  type = object({
    region    = string
    region_id = string
    vpc = object({
      id         = string
      cidr_block = string
    })
    subnet = object({
      id   = string
      zone = string
    })
  })
}

# 安全组变量
variable "sg" {
  type = object({
    region    = string
    region_id = string
    security_group = object({
      id = string
    })
  })
}



# ==========================================================
#                        云应用系统变量
# ==========================================================

# 云应用系统变量
variable "cloudapp_cam_role" {}
variable "cloudapp_repo_server" {}
variable "cloudapp_repo_username" {}
variable "cloudapp_repo_password" {}
variable "cloudapp_id" {}
variable "cloudapp_name" {}
