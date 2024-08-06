
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

  # 实例数量
  count = 2

  # 启动脚本
  user_data_raw = <<-EOT
#!/bin/bash

# 检查目录是否存在，如果不存在则创建
directory="/usr/local/cloudapp"
if [ ! -d "$directory" ]; then
    mkdir "$directory"
fi

# 输出 数据库连接信息 到 .config 文件
echo "DB_HOST=${tencentcloud_mysql_instance.demo_mysql.intranet_ip}" >> $directory/.config
echo "DB_PORT=${tencentcloud_mysql_instance.demo_mysql.intranet_port}" >> $directory/.config
echo "DB_USER=root" >> $directory/.config
echo "DB_PASS=${random_password.mysql_password.result}" >> $directory/.config

# 执行启动脚本
if [ -f "/usr/local/cloudapp/startup.sh" ]; then
  sh /usr/local/cloudapp/startup.sh
fi

# 执行数据库初始化脚本
if [ -f "/usr/local/cloudapp/init-db.sh" ]; then
  sh /usr/local/cloudapp/init-db.sh
fi
    EOT
}


# 声明随机密码（通过站内信发送密码内容）
resource "random_password" "mysql_password" {
  length           = 16
  override_special = "_+-&=!@#$%^*()"
}

# MySQL 实例
resource "tencentcloud_mysql_instance" "demo_mysql" {
  # 可用区（例：广州六区）
  availability_zone = var.app_target.subnet.zone
  # 安全组
  security_groups = [var.sg.security_group.id]
  # VPC ID
  vpc_id = var.app_target.vpc.id
  # 子网 ID
  subnet_id = var.app_target.subnet.id
  # 核心数
  cpu = var.mysql_cpu
  # 内存大小，单位：MB
  mem_size = var.mysql_mem_size
  # 磁盘大小
  volume_size = var.mysql_disk_size
  # MySQL 版本
  engine_version = var.mysql_engine_version
  # root 帐号密码
  root_password = random_password.mysql_password.result
  # 0 - 表示单可用区，1 - 表示多可用区
  slave_deploy_mode = var.mysql_slave_deploy_mode
  # 数据复制方式，0 - 表示异步复制，1 - 表示半同步复制，2 - 表示强同步复制
  slave_sync_mode = var.mysql_slave_sync_mode
  # 自定义端口
  intranet_port = var.mysql_intranet_port
  # 计费方式
  charge_type = var.mysql_charge_type
}


# CLB 负载均衡实例
resource "tencentcloud_clb_instance" "open_clb" {
  # 负载均衡实例的网络类型，OPEN：公网，INTERNAL：内网
  network_type = var.clb_network_type
  # 安全组ID列表
  security_groups = [var.sg.security_group.id]
  # VPC ID
  vpc_id = var.app_target.vpc.id
  # 子网 ID
  subnet_id = var.app_target.subnet.id
}

# CLB 监听器
resource "tencentcloud_clb_listener" "http_listener" {
  clb_id        = tencentcloud_clb_instance.open_clb.id
  listener_name = var.clb_listener_name
  port          = var.clb_listener_port
  protocol      = var.clb_listener_protocol
}

# CLB 转发规则
resource "tencentcloud_clb_listener_rule" "api_http_rule" {
  clb_id      = tencentcloud_clb_instance.open_clb.id
  listener_id = tencentcloud_clb_listener.http_listener.id
  # 转发规则的域名
  domain = var.clb_rule_domain
  # 转发规则的路径
  url = var.clb_rule_url
}

# CLB 后端服务1
resource "tencentcloud_clb_attachment" "api_http_attachment1" {
  clb_id      = tencentcloud_clb_instance.open_clb.id
  listener_id = tencentcloud_clb_listener.http_listener.id
  rule_id     = tencentcloud_clb_listener_rule.api_http_rule.id

  targets {
    # CVM 实例ID（需替换成真实的实例ID）
    instance_id = tencentcloud_instance.demo_cvm[0].id
    # 端口
    port = var.clb_attachment_port
    # 权重
    weight = var.clb_attachment_weight
  }
}


# CLB 后端服务2
resource "tencentcloud_clb_attachment" "api_http_attachment2" {
  clb_id      = tencentcloud_clb_instance.open_clb.id
  listener_id = tencentcloud_clb_listener.http_listener.id
  rule_id     = tencentcloud_clb_listener_rule.api_http_rule.id

  targets {
    # CVM 实例ID（需替换成真实的实例ID）
    instance_id = tencentcloud_instance.demo_cvm[1].id
    # 端口
    port = var.clb_attachment_port
    # 权重
    weight = var.clb_attachment_weight
  }
}
