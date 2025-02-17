# 使用Ubuntu 18.04作为基础镜像
FROM ubuntu:18.04

# 设置环境变量
ENV HADOOP_VERSION 2.7.1
ENV JAVA_HOME /usr/lib/jvm/java-8-openjdk-amd64
ENV HADOOP_HOME /usr/local/hadoop
ENV PATH $PATH:$HADOOP_HOME/bin:$HADOOP_HOME/sbin

# 安装必要工具和依赖
RUN apt-get update && apt-get install -y \
    openssh-server \
    openjdk-8-jdk \
    wget \
    vim \
    tar \
    net-tools \
    && rm -rf /var/lib/apt/lists/*

# 配置SSH无密码登录

RUN mkdir /var/run/sshd && \
    ssh-keygen -t rsa -P '' -f ~/.ssh/id_rsa && \
    cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys && \
    chmod 0600 ~/.ssh/authorized_keys && \
    ssh-keyscan localhost 0.0.0.0 2>/dev/null >> ~/.ssh/known_hosts && \
    ssh-keyscan -H localhost 0.0.0.0 >> ~/.ssh/known_hosts 2>/dev/null

# 下载并安装Hadoop
RUN wget https://archive.apache.org/dist/hadoop/core/hadoop-$HADOOP_VERSION/hadoop-$HADOOP_VERSION.tar.gz \
    && tar xzf hadoop-$HADOOP_VERSION.tar.gz -C /usr/local/ \
    && mv /usr/local/hadoop-$HADOOP_VERSION $HADOOP_HOME \
    && rm hadoop-$HADOOP_VERSION.tar.gz

# 复制配置文件
COPY DockerConfig/HadoopConfig/* $HADOOP_HOME/etc/hadoop/

# 配置Hadoop环境变量
RUN echo "export JAVA_HOME=$JAVA_HOME" >> $HADOOP_HOME/etc/hadoop/hadoop-env.sh \
    && echo "export HADOOP_PREFIX=$HADOOP_HOME" >> $HADOOP_HOME/etc/hadoop/hadoop-env.sh

# 创建Hadoop数据目录
RUN mkdir -p /hadoop/data/{namenode,datanode}

# 开放Hadoop相关端口
EXPOSE 8088 50070 50075 50090 9000 50010 50020 50030

# 启动脚本
COPY DockerConfig/entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
