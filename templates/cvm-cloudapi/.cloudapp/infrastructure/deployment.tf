
# 随机密码（通过站内信发送）
resource "random_password" "cvm_password" {
  length           = 16
  override_special = "_+-&=!@#$%^*()"
}

# CVM
resource "tencentcloud_instance" "demo_cvm" {
  # CVM 镜像ID
  image_id = var.cvm_image_id

  # CVM 机型
  instance_type = var.cvm_type.instance_type

  # 云硬盘类型
  system_disk_type = var.cvm_system_disk_type

  # 云硬盘大小，单位：GB
  system_disk_size = var.cvm_system_disk_size

  # 公网IP（与 internet_max_bandwidth_out 同时出现）
  allocate_public_ip = var.cvm_public_ip

  # 最大带宽
  internet_max_bandwidth_out = var.max_bandwidth

  # 付费类型（例：按小时后付费）
  instance_charge_type = var.cvm_charge_type

  # 可用区
  availability_zone = var.app_target.subnet.zone

  # VPC ID
  vpc_id = var.app_target.vpc.id

  # 子网ID
  subnet_id = var.app_target.subnet.id

  # 安全组ID列表
  security_groups = [var.sg.security_group.id]

  # CVM 密码（由上方 random_password 随机密码生成）
  password = random_password.cvm_password.result

  # 启动脚本
  user_data_raw = <<-EOT
#!/bin/bash

# 检查目录是否存在，如果不存在则创建
if [ ! -d "/usr/local/cloudapp" ]; then
    mkdir "/usr/local/cloudapp"
fi

# 输出 .config 文件
echo "CLOUDAPP_ID=${var.cloudapp_id}" >>  /usr/local/cloudapp/.config
echo "CLOUDAPP_NAME=${var.cloudapp_name}" >>  /usr/local/cloudapp/.config
echo "CLOUDAPP_CAM_ROLE=${var.cloudapp_cam_role}" >>  /usr/local/cloudapp/.config

echo "${var.cloudapp_cam_role}" > /usr/local/cloudapp/.cloudapp_cam_role

# 执行启动脚本
if [ -f "/usr/local/cloudapp/startup.sh" ]; then
  sh /usr/local/cloudapp/startup.sh
fi
    EOT
}
