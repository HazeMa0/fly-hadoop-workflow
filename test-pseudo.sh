#!/bin/bash

echo "本脚本用于伪分布式运行，本地测试请直接通过 IDEA 进行运行/测试"
echo "IDEA 内置的 Maven 路径并不固定，需要你通过图形界面先执行 mvn clean package 后再执行该脚本"

hdfs dfs -rm -r /test-in
hdfs dfs -rm -r /test-out

hdfs dfs -copyFromLocal ./test-in /test-in
hadoop jar ./target/Main-1.0.jar org.bigdata.Main /test-in /test-out
hdfs dfs -cat /test-out/part-r-00000
