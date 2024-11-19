resource "random_password" "ckafka_password" {
  length           = 8
  override_special = "_+-&=!@#$%^*()"
}


# 预付费实例
resource "tencentcloud_ckafka_instance" "kafka_instance_prepaid" {
  availability_zone  = var.app_target.subnet.zone
  instance_name      = "ckafka-instance-prepaid"
  zone_id            = var.app_target.subnet.zone_id * 1
  period             = 1
  vpc_id             = var.app_target.vpc.id
  subnet_id          = var.app_target.subnet.id
  msg_retention_time = 1300
  renew_flag         = 0
  kafka_version      = "2.8.1"
  disk_size          = 200
  disk_type          = "CLOUD_BASIC"
  band_width         = 20
  partition          = 400

  instance_type       = 1
  specifications_type = "profession"

  config {
    auto_create_topic_enable   = true
    default_num_partitions     = 3
    default_replication_factor = 3
  }

  dynamic_retention_config {
    enable = 1
  }
}

# 后付费实例
resource "tencentcloud_ckafka_instance" "kafka_instance_postpaid" {
  availability_zone  = var.app_target.subnet.zone
  instance_name      = "ckafka-instance-postpaid"
  zone_id            = var.app_target.subnet.zone_id * 1
  vpc_id             = var.app_target.vpc.id
  subnet_id          = var.app_target.subnet.id
  msg_retention_time = 1300
  kafka_version      = "2.8.1"
  disk_size          = 200
  band_width         = 20
  disk_type          = "CLOUD_BASIC"
  partition          = 400
  charge_type        = "POSTPAID_BY_HOUR"

  config {
    auto_create_topic_enable   = true
    default_num_partitions     = 3
    default_replication_factor = 3
  }

  dynamic_retention_config {
    enable = 1
  }
}

# 创建topic
resource "tencentcloud_ckafka_topic" "local_foo" {
  availability_zone              = var.app_target.subnet.zone
  instance_id                    = tencentcloud_ckafka_instance.kafka_instance_postpaid.id
  topic_name                     = "example-local-cloudapp"
  note                           = "topic note"
  replica_num                    = 2
  partition_num                  = 1
  enable_white_list              = true
  ip_white_list                  = ["ip1", "ip2"]
  clean_up_policy                = "delete"
  sync_replica_min_num           = 1
  unclean_leader_election_enable = false
  segment                        = 3600000
  retention                      = 60000
  max_message_bytes              = 1024
}

# 创建用户
resource "tencentcloud_ckafka_user" "foo" {
  availability_zone = var.app_target.subnet.zone
  instance_id       = tencentcloud_ckafka_instance.kafka_instance_postpaid.id
  account_name      = "cloudapp"
  password          = random_password.ckafka_password.result
}

# 创建路由
resource "tencentcloud_ckafka_route" "example" {
  availability_zone = var.app_target.subnet.zone
  instance_id       = tencentcloud_ckafka_instance.kafka_instance_postpaid.id
  vip_type          = 3
  vpc_id            = var.app_target.vpc.id
  subnet_id         = var.app_target.subnet.id
  access_type       = 0
  public_network    = 3
}

# 创建ACL
resource "tencentcloud_ckafka_acl" "foo" {
  availability_zone = var.app_target.subnet.zone
  instance_id       = tencentcloud_ckafka_instance.kafka_instance_postpaid.id
  resource_type     = "TOPIC"
  resource_name     = tencentcloud_ckafka_topic.local_foo.topic_name
  operation_type    = "WRITE"
  permission_type   = "ALLOW"
  host              = "*"
  principal         = tencentcloud_ckafka_user.foo.account_name
}

# 消费组
resource "tencentcloud_ckafka_consumer_group" "consumer_group" {
  availability_zone = var.app_target.subnet.zone
  instance_id       = tencentcloud_ckafka_instance.kafka_instance_postpaid.id
  group_name        = "GroupNamebro"
  topic_name_list   = [tencentcloud_ckafka_topic.local_foo.topic_name]
}

# 输出密码
output "ckafka_password_output" {
  value       = random_password.ckafka_password.result
  description = "CKafka用户密码"

}
