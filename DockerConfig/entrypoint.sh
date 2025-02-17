#!/bin/bash

mkdir -p ~/.ssh
touch ~/.ssh/config
printf "Host *\n\tStrictHostKeyChecking no\n\tUserKnownHostsFile /dev/null\n" > ~/.ssh/config

# 启动SSH服务
service ssh start

# 格式化HDFS（仅在第一次运行时执行）
if [ ! -f /hadoop/data/namenode/formatted ]; then
    hdfs namenode -format -force
    touch /hadoop/data/namenode/formatted
fi

# 启动Hadoop服务
start-dfs.sh
start-yarn.sh

# 保持容器运行
tail -f /dev/null
