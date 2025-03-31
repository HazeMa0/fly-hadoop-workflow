# 使用Ubuntu 18.04作为基础镜像
FROM ubuntu:18.04

# 设置环境变量
ENV HADOOP_VERSION=3.2.1
ENV HBASE_VERSION=2.4.0
ENV HIVE_VERSION=3.1.2
ENV JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64
ENV HADOOP_HOME=/opt/hadoop
ENV HBASE_HOME=/opt/hbase
ENV HIVE_HOME=/opt/hive
ENV PATH=$PATH:$HADOOP_HOME/bin:$HADOOP_HOME/sbin:$HBASE_HOME/bin:$HIVE_HOME/bin

# 设置 Ubuntu 清华源
RUN sed -i 's/http:\/\/archive.ubuntu.com/http:\/\/mirrors.nju.edu.cn/g' /etc/apt/sources.list && \
    sed -i 's/http:\/\/security.ubuntu.com/http:\/\/mirrors.nju.edu.cn/g' /etc/apt/sources.list

# 安装必要工具和依赖
RUN apt-get update && apt-get install -y --no-install-recommends \
    openssh-server \
    openjdk-8-jdk \
    wget net-tools aria2 \
    vim tar sudo locales \
    && rm -rf /var/lib/apt/lists/*

# 安装中文环境
RUN locale-gen zh_CN.UTF-8 en_US.UTF-8
ENV LANG=zh_CN.UTF-8
ENV LC_ALL=zh_CN.UTF-8

# 开放Hadoop相关端口
EXPOSE 8088 9870 60010

# 创建 Hadoop 用户，并调整权限
RUN groupadd hadoopG && \
    useradd -g hadoopG -m -s /bin/bash hadoop && \
    echo "hadoop:hadoop" | chpasswd  && \
    usermod -aG sudo hadoop  && \
    echo "hadoop ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers  && \
    mkdir /var/run/sshd

RUN chown hadoop:hadoopG /opt

# 切换到 hadoop 用户
USER hadoop
WORKDIR /home/hadoop

# 下载并安装Hadoop
RUN aria2c -x 8 https://archive.apache.org/dist/hadoop/core/hadoop-${HADOOP_VERSION}/hadoop-${HADOOP_VERSION}.tar.gz \
    && tar xzf hadoop-${HADOOP_VERSION}.tar.gz -C ./ \
    && mv ./hadoop-${HADOOP_VERSION} ${HADOOP_HOME} \
    && rm hadoop-${HADOOP_VERSION}.tar.gz

RUN aria2c -x 8 https://archive.apache.org/dist/hbase/${HBASE_VERSION}/hbase-${HBASE_VERSION}-bin.tar.gz \
    && tar xzf hbase-${HBASE_VERSION}-bin.tar.gz -C ./ \
    && mv ./hbase-${HBASE_VERSION} ${HBASE_HOME} \
    && rm hbase-${HBASE_VERSION}-bin.tar.gz

RUN aria2c -x 8 https://archive.apache.org/dist/hive/hive-${HIVE_VERSION}/apache-hive-${HIVE_VERSION}-bin.tar.gz \
    && tar xzf apache-hive-${HIVE_VERSION}-bin.tar.gz -C ./ \
    && mv ./apache-hive-${HIVE_VERSION}-bin ${HIVE_HOME} \
    && rm apache-hive-${HIVE_VERSION}-bin.tar.gz

USER root
RUN chown root:root /opt
USER hadoop

RUN rm ${HIVE_HOME}/lib/guava-19.0.jar \
    && cp ${HADOOP_HOME}/share/hadoop/common/lib/guava-27.0-jre.jar ${HIVE_HOME}/lib

# 配置Hadoop环境变量
RUN ls ${HADOOP_HOME}
RUN echo "export JAVA_HOME=$JAVA_HOME" >> $HADOOP_HOME/etc/hadoop/hadoop-env.sh \
    && echo "export HADOOP_HOME=$HADOOP_HOME" >> $HADOOP_HOME/etc/hadoop/hadoop-env.sh \
    && echo "export JAVA_HOME=$JAVA_HOME" >> $HBASE_HOME/conf/hbase-env.sh \
    && echo "export HBASE_DISABLE_HADOOP_CLASSPATH_LOOKUP=\"true\"" >> $HBASE_HOME/conf/hbase-env.sh \
    && cp $HIVE_HOME/conf/hive-env.sh.template $HIVE_HOME/conf/hive-env.sh \
    && echo "export JAVA_HOME=$JAVA_HOME" >> $HIVE_HOME/conf/hive-env.sh \
    && echo "export HADOOP_HOME=$HADOOP_HOME" >> $HIVE_HOME/conf/hive-env.sh \
    && echo "export HIVE_HOME=$HIVE_HOME" >> $HIVE_HOME/conf/hive-env.sh


# 配置SSH无密码登录
RUN ssh-keygen -t rsa -P '' -f ~/.ssh/id_rsa && \
    cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys && \
    chmod 0600 ~/.ssh/authorized_keys && \
    ssh-keyscan localhost 0.0.0.0 2>/dev/null >> ~/.ssh/known_hosts && \
    ssh-keyscan -H localhost 0.0.0.0 >> ~/.ssh/known_hosts 2>/dev/null && \
    mkdir -p ~/.ssh && \
    touch ~/.ssh/config && \
    printf "Host *\n\tStrictHostKeyChecking no\n\tUserKnownHostsFile /dev/null\n" > ~/.ssh/config

COPY DockerConfig/entrypoint.sh /entrypoint.sh
RUN sudo chmod a+x /entrypoint.sh

# 复制配置文件
COPY DockerConfig/HadoopConfig/* ${HADOOP_HOME}/etc/hadoop/
COPY DockerConfig/HBaseConfig/* ${HBASE_HOME}/conf/
COPY DockerConfig/HiveConfig/* ${HIVE_HOME}/conf/

RUN hdfs namenode -format -force

ENTRYPOINT ["/entrypoint.sh"]
