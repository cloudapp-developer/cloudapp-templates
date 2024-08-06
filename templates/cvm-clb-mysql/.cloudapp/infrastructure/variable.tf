# ==========================================================
#               下方变量通常需要根据实际情况修改
# ==========================================================

# CVM 镜像ID
variable "cvm_image_id" {
  type    = string
  default = "img-o68xyn9q"
}

# CVM 系统盘类型
variable "cvm_system_disk_type" {
  type    = string
  default = "CLOUD_HSSD"
}

# CVM 系统盘大小，单位：GB
variable "cvm_system_disk_size" {
  type    = number
  default = 20
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


# MySQL 核心数
variable "mysql_cpu" {
  type    = number
  default = 1
}

# MySQL 内存大小，单位：MB
variable "mysql_mem_size" {
  type    = number
  default = 1000
}

# MySQL 磁盘大小，单位：GB
variable "mysql_disk_size" {
  type    = number
  default = 50
}

# MySQL 版本
variable "mysql_engine_version" {
  type    = string
  default = "5.7"
}

# MySQL 部署模式，0-单可用区，1-多可用区
variable "mysql_slave_deploy_mode" {
  type    = number
  default = 0
}

# MySQL 数据同步方式，0 - 表示异步复制，1 - 表示半同步复制，2 - 表示强同步复制
variable "mysql_slave_sync_mode" {
  type    = number
  default = 0
}

# MySQL 自定义端口
variable "mysql_intranet_port" {
  type    = number
  default = 3306
}

# MySQL 计费方式
variable "mysql_charge_type" {
  type    = string
  default = "POSTPAID"
}

# CLB 网络类型，OPEN：公网，INTERNAL：内网
variable "clb_network_type" {
  type    = string
  default = "OPEN"
}

# CLB 监听器名称
variable "clb_listener_name" {
  type    = string
  default = "http_listener"
}

# CLB 监听器协议
variable "clb_listener_protocol" {
  type    = string
  default = "HTTP"
}

# CLB 监听器端口
variable "clb_listener_port" {
  type    = number
  default = 80
}

# CLB 转发规则域名（需替换成真实的域名）
variable "clb_rule_domain" {
  type    = string
  default = "cloudapp.tencent.com"
}

# CLB 转发规则路径
variable "clb_rule_url" {
  type    = string
  default = "/"
}

# CLB 后端服务端口
variable "clb_attachment_port" {
  type    = number
  default = 80
}

# CLB 后端服务权重（需要根据实例数量调整权重）
variable "clb_attachment_weight" {
  type    = number
  default = 50
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
