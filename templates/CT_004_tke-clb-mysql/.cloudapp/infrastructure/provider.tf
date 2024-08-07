# provider tencentcloud 需要声明，对云厂商供应方进行基本的属性设置

provider "tencentcloud" {
  region = var.app_zone.region
}
