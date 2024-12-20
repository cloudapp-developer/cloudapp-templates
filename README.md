# 云应用-模板项目

为方便开发者快速启动项目开发，此项目根据不同的架构分场景提供了部分项目模板

参考目录：`/templates/`

### 当前支持的模板项目：

编号 | 模板名 | 涉及云资源 | 技术场景
-----|------|-------------|-----------
`CT_001` | `CT_001_cvm-ip` | 云服务器 | 单服务器应用，暴漏外网 IP 使用
`CT_002` | `CT_002_cvm-cloudapi` | 云服务器 | 单服务器应用，演示如何使用使用角色调用云 API
`CT_003` | `CT_003_cvm-clb-mysql` | 云服务器、负载均衡、MySQL | 多服务器，MySQL数据库，通过 CLB 实现负载均衡，并暴露公网VIP供外部使用
`CT_004` | `CT_004_tke-clb-mysql` | TKE容器服务、负载均衡、MySQL | 基于容器实现的应用程序，通过Ingress暴露外网IP使用
`CT_005` | `CT_005_all` | 全部 | 所有支持的云资源安装示例
`CT_006` | `CT_006_cvm-ip-vpc-subnet` | 云服务器、VPC、子网 | 单服务器应用，自动创建VPC和子网，无需用户去选择与理解
`CT_007` | `CT_007_cfs` | CFS 文件系统 | CFS单文件系统部署
`CT_008` | `CT_008_ckafka` | Ckafka 消息队列 | Ckafka 消息队列 预付费及后付费实例


每个项目介绍了具体功能及使用方法，详情参考项目中的 `README.md`

更多项目支持中...

## 快速获取模板项目

```bash

# 指定模板初始化项目
cloudapp init 自定义项目名称 -t 模板编号/模板名称

# 示例1：通过模板编号初始化
cloudapp init my-project -t CT_001

# 示例2：通过模板名称初始化
cloudapp init my-project -t CT_001_cvm-ip

```

