# ==========================================================
#               下方变量通常需要根据实际情况修改
# ==========================================================



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
      id      = string
      zone    = string
      zone_id = string
    })
  })
}


# ==========================================================
#                        云应用系统变量
# ==========================================================

variable "cloudapp_id" {}
variable "cloudapp_name" {}
