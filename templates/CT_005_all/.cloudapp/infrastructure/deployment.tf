
# 随机密码（通过站内信发送）
resource "random_password" "cvm_password" {
  length           = 16
  override_special = "_+-&=!@#$%^*()"
}

# 安全组
resource "tencentcloud_security_group" "demo_sg" {
  name        = "云应用全产品安全组CT_005_all"
  description = "云应用全产品模板安全组CT_005_all"
}

# 安全组规则（入规则）
resource "tencentcloud_security_group_rule" "ingress" {
  security_group_id = tencentcloud_security_group.demo_sg.id
  type              = "ingress"
  cidr_ip           = "0.0.0.0/0"
  ip_protocol       = "ALL"
  policy            = "DROP"
  description       = "drop ingress all"
}

# 安全组规则（出规则）
resource "tencentcloud_security_group_rule" "egress" {
  security_group_id = tencentcloud_security_group.demo_sg.id
  type              = "egress"
  cidr_ip           = "0.0.0.0/0"
  ip_protocol       = "ALL"
  policy            = "DROP"
  description       = "drop egress all"
}

# CVM
resource "tencentcloud_instance" "demo_cvm" {
  # CVM 镜像ID
  image_id = "img-eb30mz89"

  # CVM 机型
  instance_type = var.cvm_type.instance_type

  # 云硬盘大小，单位：GB
  system_disk_size = 50

  # 公网IP（与 internet_max_bandwidth_out 同时出现）
  allocate_public_ip = true

  # 最大带宽
  internet_max_bandwidth_out = 1

  # 付费类型（例：按小时后付费）
  instance_charge_type = "POSTPAID_BY_HOUR"

  # 可用区
  availability_zone = var.app_target.subnet.zone

  # VPC ID
  vpc_id = var.app_target.vpc.id

  # 子网ID
  subnet_id = var.app_target.subnet.id

  # 安全组ID列表
  security_groups = [tencentcloud_security_group.demo_sg.id]

  # CVM 密码（由上方 random_password 随机密码生成）
  password = random_password.cvm_password.result

  # 启动脚本
  user_data_raw = <<-EOT
#!/bin/bash

# 检查目录是否存在，如果不存在则创建
directory="/usr/local/cloudapp"
if [ ! -d "$directory" ]; then
    mkdir "$directory"
fi

# 输出 .config 文件
echo "cloudappId=${var.cloudapp_id}" >>  $directory/.config
echo "cloudappName=${var.cloudapp_name}" >>  $directory/.config

# 执行启动脚本
if [ -f "/usr/local/cloudapp/startup.sh" ]; then
  sh /usr/local/cloudapp/startup.sh
fi
    EOT
}

# CBS 云硬盘
resource "tencentcloud_cbs_storage" "demo_storage" {
  storage_type      = "CLOUD_SSD"
  storage_size      = 100
  availability_zone = var.app_target.subnet.zone
  encrypt           = false
  charge_type       = "POSTPAID_BY_HOUR"
}

# 将云硬盘绑定到CVM
resource "tencentcloud_cbs_storage_attachment" "demo_attachment" {
  storage_id           = tencentcloud_cbs_storage.demo_storage.id
  instance_id          = tencentcloud_instance.demo_cvm.id
  delete_with_instance = true
}


# 声明 MySQL 随机密码（通过站内信发送密码内容）
resource "random_password" "mysql_password" {
  length           = 16
  override_special = "_+-&=!@#$%^*()"
}

# MySQL 实例
resource "tencentcloud_mysql_instance" "demo_mysql" {
  # 可用区（例：广州六区）
  availability_zone = var.app_target.subnet.zone
  # 安全组
  security_groups = [tencentcloud_security_group.demo_sg.id]
  # VPC ID
  vpc_id = var.app_target.vpc.id
  # 子网 ID
  subnet_id = var.app_target.subnet.id
  # 核心数
  cpu = 1
  # 内存大小，单位：MB
  mem_size = 1000
  # 磁盘大小，单位：GB
  volume_size = 50
  # MySQL 版本
  engine_version = "5.7"
  # root 帐号密码
  root_password = random_password.mysql_password.result
  # 0 - 表示单可用区，1 - 表示多可用区
  slave_deploy_mode = 0
  # 数据复制方式，0 - 表示异步复制，1 - 表示半同步复制，2 - 表示强同步复制
  slave_sync_mode = 0
  # 自定义端口
  intranet_port = 3306
  # 计费方式
  charge_type = "POSTPAID"
}


# CLB 负载均衡实例（公网CLB）
resource "tencentcloud_clb_instance" "open_clb" {
  # 负载均衡实例的网络类型，OPEN：公网，INTERNAL：内网
  network_type = "OPEN"
  # 安全组ID列表
  security_groups = [tencentcloud_security_group.demo_sg.id]
  # VPC ID
  vpc_id = var.app_target.vpc.id
  # 子网 ID
  subnet_id = var.app_target.subnet.id
  # 启用默认放通，即 Target 放通来自 CLB 的流量
  load_balancer_pass_to_target = true
}

################################################
################## http 路由 ###################
################################################

# CLB 监听器
resource "tencentcloud_clb_listener" "http_listener" {
  clb_id        = tencentcloud_clb_instance.open_clb.id
  listener_name = "http_listener"
  port          = 80
  protocol      = "HTTP"
}

# CLB 转发规则
resource "tencentcloud_clb_listener_rule" "api_http_rule" {
  clb_id      = tencentcloud_clb_instance.open_clb.id
  listener_id = tencentcloud_clb_listener.http_listener.id
  # 转发规则的域名（仅为示例）
  domain = "app.cloud.tencent.com"
  # 转发规则的路径（仅为示例）
  url = "/"
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
    port = 80
    # 权重
    weight = 100
  }
}

# CLS 日志集
resource "tencentcloud_cls_logset" "demo_logset" {
  # 日志集名称
  logset_name = "CT_005_all-demo-logset"
}

# CLS 日志主题
resource "tencentcloud_cls_topic" "demo_topic" {
  # 日志主题名称
  topic_name = "CT_005_all-demo-topic"
  # 日志集ID
  logset_id = tencentcloud_cls_logset.demo_logset.id
  # 是否开启自动分裂
  auto_split = false
  # 开启自动分裂后，每个主题能够允许的最大分区数
  max_split_partitions = 20
  # 日志主题分区个数
  partition_count = 1
  # 生命周期，单位天
  period = 30
  # 日志主题的存储类型，可选值 hot（标准存储），cold（低频存储）
  storage_type = "hot"
  # 日志主题描述
  describes = "Test Demo.CT_005_all"
  # hot_period 需要大于等于7，且小于 period
  hot_period = 10
}

# 声明 Redis 随机密码
resource "random_password" "redis_password" {
  length           = 16
  override_special = "_+-&=!@#$%^*()"
}


# Redis 实例
resource "tencentcloud_redis_instance" "demo_redis" {
  vpc_id            = var.app_target.vpc.id
  subnet_id         = var.app_target.subnet.id
  availability_zone = var.app_target.subnet.zone
  # 实例类型（例：6 Redis 4.0 内存版（标准架构））
  type_id = 6
  # 实例密码
  password = random_password.redis_password.result
  # 内存容量，单位：MB
  mem_size = 2048
  # 实例副本数量
  redis_replicas_num = 1
  # 端口
  port = 6379
}


# RabbitMQ 实例
# resource "tencentcloud_tdmq_rabbitmq_vip_instance" "demo_rabbitmq" {
#   availability_zone                     = var.app_target.subnet.zone
#   zone_ids_str                          = "100003,100004"
#   vpc_id                                = var.app_target.vpc.id
#   subnet_id                             = var.app_target.subnet.id
#   node_spec                             = "rabbit-vip-basic-1"
#   node_num                              = 3
#   storage_size                          = 200
#   enable_create_default_ha_mirror_queue = false
#   # 付费模式（0：按量计费，1：包年包月）
#   pay_mode = 0
#   # auto_renew_flag                       = false
#   # time_span                             = 1
# }

# SQL Server 基础版实例
# resource "tencentcloud_sqlserver_basic_instance" "demo_sqlserver_basic" {
#   availability_zone = var.app_target.subnet.zone
#   charge_type       = "POSTPAID_BY_HOUR"
#   vpc_id            = var.app_target.vpc.id
#   subnet_id         = var.app_target.subnet.id
#   memory            = 2
#   storage           = 20
#   cpu               = 1
#   machine_type      = "CLOUD_SSD"
#   security_groups   = [tencentcloud_security_group.demo_sg.id]
# }

# SQL Server 高可用实例
# resource "tencentcloud_sqlserver_instance" "demo_sqlserver" {
#   availability_zone = var.app_target.subnet.zone
#   vpc_id            = var.app_target.vpc.id
#   subnet_id         = var.app_target.subnet.id
#   charge_type       = "POSTPAID_BY_HOUR"
#   memory            = 2
#   storage           = 100
# }

# SQL Server 只读实例
# resource "tencentcloud_sqlserver_readonly_instance" "demo_sqlserver_readonly" {
#   availability_zone   = var.app_target.subnet.zone
#   vpc_id              = var.app_target.vpc.id
#   subnet_id           = var.app_target.subnet.id
#   charge_type         = "POSTPAID_BY_HOUR"
#   memory              = 2
#   storage             = 10
#   master_instance_id  = tencentcloud_sqlserver_instance.demo_sqlserver.id
#   readonly_group_type = 1
#   # 是否强制升级实例
#   force_upgrade = true
# }

# 声明 PostgreSQL 随机密码
resource "random_password" "postgresql_password" {
  length           = 16
  override_special = "_+-&=!@#$%^*()"
}

# PostgreSQL 实例
resource "tencentcloud_postgresql_instance" "demo_postgresql" {
  availability_zone = var.app_target.subnet.zone
  vpc_id            = var.app_target.vpc.id
  subnet_id         = var.app_target.subnet.id
  root_password     = random_password.postgresql_password.result
  charset           = "UTF8"
  spec_code         = "pg.it.small2"
  security_groups   = [tencentcloud_security_group.demo_sg.id]
  storage           = 100
  engine_version    = "16.4"
  db_major_version  = "16"
  db_kernel_version = "v16.4_r1.7"
}


# 声明 MongoDB 随机密码
resource "random_password" "mongodb_password" {
  length           = 16
  override_special = "_+-&=!@#$%^*()"
  special          = false
}

# MongoDB 实例
resource "tencentcloud_mongodb_instance" "demo_mongodb" {
  memory            = 4
  volume            = 100
  engine_version    = "MONGO_44_WT"
  machine_type      = "HIO10G"
  availability_zone = var.app_target.subnet.zone
  vpc_id            = var.app_target.vpc.id
  subnet_id         = var.app_target.subnet.id
  password          = random_password.mongodb_password.result
  security_groups   = [tencentcloud_security_group.demo_sg.id]
}

# MongoDB 灾备实例
# resource "tencentcloud_mongodb_standby_instance" "demo_mongodb_readonly" {
#   memory                 = 4
#   volume                 = 30
#   availability_zone      = var.app_target.subnet.zone
#   vpc_id                 = var.app_target.vpc.id
#   subnet_id              = var.app_target.subnet.id
#   father_instance_id     = tencentcloud_mongodb_instance.demo_mongodb.id
#   father_instance_region = var.app_target.region
#   security_groups        = [tencentcloud_security_group.demo_sg.id]
# }

# EIP 弹性公网IP
resource "tencentcloud_eip" "demo_eip" {
  availability_zone    = var.app_target.subnet.zone
  name                 = "CT_005_all-eip"
  internet_charge_type = "TRAFFIC_POSTPAID_BY_HOUR"
  type                 = "EIP"
}

# NAT 网关
resource "tencentcloud_nat_gateway" "demo_nat" {
  name                = "CT_005_all-demo-nat"
  assigned_eip_set    = [tencentcloud_eip.demo_eip.public_ip]
  vpc_id              = var.app_target.vpc.id
  subnet_id           = var.app_target.subnet.id
  bandwidth           = 100
  max_concurrent      = 1000000
  nat_product_version = 1
  availability_zone   = var.app_target.subnet.zone
}

# Prometheus 实例（普罗米修斯监控）
resource "tencentcloud_monitor_tmp_instance" "demo_prometheus" {
  availability_zone   = var.app_target.subnet.zone
  vpc_id              = var.app_target.vpc.id
  subnet_id           = var.app_target.subnet.id
  zone                = var.app_target.subnet.zone
  data_retention_time = 15
  instance_name       = "CT_005_all-demo-prometheus"
}

# RocketMQ 5.x 实例
resource "tencentcloud_trocket_rocketmq_instance" "demo_rocketmq" {
  name          = "CT_005_all-demo-rocketmq"
  instance_type = "BASIC"
  sku_code      = "basic_1k"
  remark        = "全产品用例，basic_1k"
  # 公网访问白名单
  ip_rules          = []
  vpc_id            = var.app_target.vpc.id
  subnet_id         = var.app_target.subnet.id
  availability_zone = var.app_target.subnet.zone
}
