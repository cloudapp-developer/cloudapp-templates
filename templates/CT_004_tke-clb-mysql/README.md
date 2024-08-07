# 云应用模板-TKE、CLB、MySQL



## 云资源清单

- `TKE 容器服务`
- `CLB 负载均衡`
- `MySQL 数据库`

### 部署架构

![](./assets/deployment.svg)

### 容器架构
![](./assets/k8s.png)

## 目录说明
- .cloudapp：云应用根目录
  - infrastructure：资源及变量定义目录
    - variable.tf：变量定义
    - deployment.tf：资源定义
    - provider.tf：全局公共参数（固定不变）
  - software: 容器应用源码，使用 helm chart 编排
  - package.yaml： 云应用配置文件
- frontend：前端源码，示例用，非强制当前目录
- server: 后台源码，示例用，非强制当前目录

## 云资源清单
* MySQL
* TKE（自动创建 CLB）

## 如何开始

### 1、初始化 helm chart 的 values.yaml

根据需要，可以在 `.cloudapp/software/chart/values.yaml` 中定义需要的变量，在模板中可以引用定义的变量

云资源相关的变量可以在 `.cloudapp/infrastructure/deployment.tf` 文件的 `cloudapp_helm_app.app` 中声明，应用安装的时候会透传到 `values.yaml`

[了解更多 helm chart values 的内容 >>](https://helm.sh/docs/chart_template_guide/values_files/)

### 2、修改启动容器的 docker 镜像

将文件 `.cloudapp/software/chart/templates/job.yaml` 中 `spec.containers.image` 修改成实际的镜像，用于初始化应用，包括初始化数据库等

同时根据实际情况修改其他配置，包括环境变量等

### 3、修改容器镜像

将文件 `.cloudapp/software/chart/templates/statefulset.yaml` 中的 `spec.containers.image` 修改为实际的镜像地址，这是应用的镜像，运行你的应用

同时根据实际情况修改其他配置，包括环境变量等

### 4、确认云产品配置是否符合需要

检查 `.cloudapp/infrastructure/deployment.tf` 文件中定义的云资源，修改不符合实际情况的属性

[查看云应用资源类型手册 >>](https://cloud.tencent.com/document/product/1689/90938)

## 参考文档
- [资源类型手册](https://cloud.tencent.com/document/product/1689/90938)
- [腾讯云云应用简介](https://cloud.tencent.com/document/product/1689/87047)