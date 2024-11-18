
# 权限组
resource "tencentcloud_cfs_access_group" "example_access_group" {
  availability_zone = var.app_target.subnet.zone
  name              = "tx_example_cloudapp"
  description       = "desc."
}

# 权限组规则
resource "tencentcloud_cfs_access_rule" "example_access_group_rule" {
  availability_zone = var.app_target.subnet.zone
  access_group_id   = tencentcloud_cfs_access_group.example_access_group.id
  auth_client_ip    = "*"
  priority          = 1
  rw_permission     = "RO"
  user_permission   = "root_squash"
}

# 文件系统
resource "tencentcloud_cfs_file_system" "cfs_file_system" {
  name              = "test_file_system_cloudapp"
  availability_zone = var.app_target.subnet.zone
  access_group_id   = tencentcloud_cfs_access_group.example_access_group.id
  protocol          = "NFS"
  vpc_id            = var.app_target.vpc.id
  subnet_id         = var.app_target.subnet.id
}

# 自动快照策略
resource "tencentcloud_cfs_auto_snapshot_policy" "auto_snapshot_policy" {
  availability_zone = var.app_target.subnet.zone
  day_of_week       = "1,2"
  hour              = "2,3"
  policy_name       = "cloudapp_policy_name"
  alive_days        = 7
}

# 文件系统自动快照策略绑定
resource "tencentcloud_cfs_auto_snapshot_policy_attachment" "auto_snapshot_policy_attachment" {
  availability_zone = var.app_target.subnet.zone
  auto_snapshot_policy_id = tencentcloud_cfs_auto_snapshot_policy.auto_snapshot_policy.id
  file_system_ids         = tencentcloud_cfs_file_system.cfs_file_system.id
}

# 文件系统快照
resource "tencentcloud_cfs_snapshot" "snapshot" {
  availability_zone = var.app_target.subnet.zone
  file_system_id    = tencentcloud_cfs_file_system.cfs_file_system.id
  snapshot_name     = "test_cloudapp"
}
