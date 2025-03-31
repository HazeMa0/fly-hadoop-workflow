#!/bin/bash

# 定义一个清理函数，优雅关闭 HBase、YARN 和 HDFS
function cleanup() {
    echo "Stopping HBase, YARN, and HDFS..."
    stop-hbase.sh
    stop-yarn.sh
    stop-dfs.sh
    echo "All services stopped. Exiting..."
}


# 启动SSH服务
sudo service ssh start

# 监听 SIGTERM 信号，执行 cleanup 函数
trap cleanup SIGTERM

# 启动Hadoop服务
start-dfs.sh
start-yarn.sh 
start-hbase.sh

if [ ! -f ~/.initialized ]; then
    hadoop fs -mkdir /tmp
    hadoop fs -mkdir /user
    hadoop fs -mkdir /user/hive
    hadoop fs -mkdir /user/hive/warehouse
    hadoop fs -chmod g+w /tmp
    hadoop fs -chmod g+w /user/hive/warehouse
    schematool -dbType derby -initSchema
    touch ~/.initialized
fi
echo "INFO: Initialization work has finished."
while true
do
   tail -f /dev/null & wait ${!}
done
