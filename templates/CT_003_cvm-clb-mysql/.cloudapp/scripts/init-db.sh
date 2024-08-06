#!bin/bash

# ============================================
# 提示：当前脚本上传到 /usr/local/cloudapp/ 目录下
# ============================================

# 读取 .config 文件中的环境变量
export $(grep -v '^#' /usr/local/cloudapp/.config | xargs)

# 可通过环境变量（例：$变量名）读取想要的信息，并进行自定义操作
# 支持的“变量名”可通过 deployment.tf 文件的 cvm 初始化脚本 user_data_raw 查看

# 初始化数据库
DB_DATABASE=cloudappdemo
mysql -h $DB_HOST -P $DB_PORT -u $DB_USER -p$DB_PASS -e "CREATE DATABASE $DB_DATABASE CHARACTER SET utf8 COLLATE utf8_general_ci"
mysql -h $DB_HOST -P $DB_PORT -u $DB_USER -p$DB_PASS $DB_DATABASE </usr/local/cloudapp/db.sql
