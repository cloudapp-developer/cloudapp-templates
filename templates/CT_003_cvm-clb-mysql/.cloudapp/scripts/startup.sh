#!/bin/bash

# ============================================
# 提示：当前脚本上传到 /usr/local/cloudapp/ 目录下
# ============================================

# 读取 .config 文件中的环境变量
export $(grep -v '^#' /usr/local/cloudapp/.config | xargs)


# 可通过环境变量（例：$变量名）读取想要的信息，并进行自定义操作
# 支持的“变量名”可通过 deployment.tf 文件的 cvm 初始化脚本 user_data_raw 查看

# 例：写配置文件
# json="{\"cloudappId\":\"$cloudappId\",\"cloudappName\":\"$cloudappName\"}"
# echo "$json" >/usr/local/cloudapp/config.json
