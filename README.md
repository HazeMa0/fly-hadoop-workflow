## fly-hadoop-workflow：让编写 hadoop 3.2.1 应用的效率飞起来

### 一、背景

某校的《大数据处理综合实验》课程对开发环境做了如下要求：
 - JDK 1.8
 - Hadoop 3.2.1
 - HBase 2.4.0
 - Hive 3.1.2

如果您觉得安装这些环境的繁琐流程浪费了很多宝贵的精力，那选择本项目作为工作环境一定会让您身心愉悦。

### 二、开始安装

1. **在安装之前**，请确认您身处的网络环境。务必确保您 *全程* 可以以较快的网速访问 [google.com](https://www.google.com) 和 [ChatGPT](https://chat.openai.com)，以减少可能的网络问题，同时在遇到问题时使用它们以更快解决。

2. 在 Windows 或 GNU/Linux 发行版安装以下应用：
    - 版本较新的 [Docker](https://docs.docker.com/get-started/get-docker/)，如果是 Windows 请使用 [WSL2](https://learn.microsoft.com/zh-cn/windows/wsl/install) 后端
    - [IntelliJ IDEA](https://www.jetbrains.com/zh-cn/idea/download/) 商业版 2023.2 及以上版本，在启动页面有 [Dev Container](https://intellijidea.com.cn/connect-to-devcontainer.html) 选项
    ![](readme_pic/1.png)
    > **注意！**
    > - 建议 Windows 用户将 Docker 的镜像位置修改到 C 盘外。
    > - IntelliJ IDEA 社区版 **不支持** Dev Containers。

3. 打开 IntelliJ IDEA（如果打开了已有的项目，请点击左上角的 `文件` > `关闭项目`）， 选择 `远程开发` > `Dev Container`，在右侧页面点击 `新建 Dev Container`；
![](readme_pic/2.png)

4. 在页面上方点击 `从本地项目`，找到您 clone 好的本项目代码文件夹的 `.devcontainer/devcontainer.json` 文件，点击右下角的 `构建容器并继续`；
![](readme_pic/3.png)

4. 正常网络情况下，安装需要**15-20分钟**的时间。无需额外操作，Dev Container 环境就自动创建好了。

5. 接下来 IDEA 会**自动**打开容器。请注意 IDEA 弹出的若干窗口，点击确认即可。由于容器的启动脚本耗时较长（这也是为了简化您的操作），您需要对打开 IDE 界面的过程 **保持耐心**。
> **遇到问题？**
>
> - 请先确认网络环境，而且 Docker 的守护进程是打开的。
> - 通过代理访问 Docker 仓库很可能会出现五花八门的报错信息，作者很难给出统一的解决方案。逐个尝试以下方法：
>   1. 打开您的代理软件，更新代理配置；
>   2. 重启计算机以解决偶发的网络问题；
>   3. 尝试运行 `docker pull ubuntu:18.04` 后重试；
>   4. 从 Docker Desktop 应用的 Builds 中找到最近一次的错误构建，获得 Error logs，通过搜索引擎获得问题的解决方案。（Error logs 可能很长，而搜索引擎会限制搜索词的长度，请尽可能截取后半段）

### 三、确认各组件工作正常（强烈建议）

1. Hadoop：通过 `jps` 命令确认组件数量如下图所示 (9 个)。我们默认开放了 9870 (HDFS)、8088 (YARN)、 60010 (HBase) 端口，通过在本机浏览器输入网址 `localhost:端口号` 来访问。
![](readme_pic/4.png)

2. HBase：在终端键入 `hbase shell`。

3. Hive：**先 `cd ~`**（因为 derby 数据库会在当前目录打印 log），再键入 `hive`。可能有一些警告信息，但只要进入 `hive>` 的命令行界面即可视作成功。

4. **强烈建议您在关闭容器前手动输入以下命令以保持容器的正常工作：**
    ```sh
    $ stop-hbase.sh
    $ stop-all.sh
    ```
    如果不这样做，下次打开容器很可能出现 DataNode 或 HMaster 不正常工作的情况，那时唯一的办法就是**删掉容器再新开一个了**。

### 四、开发 MapReduce 应用

我们已经准备好了一个 MapReduce 应用，其会计数 [test-in/](./test-in/) 文件夹内文本中出现的单词及其数量，与官方提供的 `wordCount` 应用功能类似。
 1. **开始之前**：点击 IDEA 右侧菜单栏的 `maven` 按钮，在打开的面板中找到左上角的 `刷新` 按钮，点击 `重新加载所有 Maven 项目` 以在线加载该项目需要的依赖。
![](readme_pic/5.png)

 2. **本地模式**：您可以直接点击 IDEA 里 [Main.java](./src/main/java/org/bigdata/Main.java) 的运行和调试按钮进行本地运行和调试。**运行时可能打印一些警告信息，但只要返回值为 0，那程序就是正常运行结束的。**
 3. **伪分布模式**：
    - **重要：** 注释掉 [Main.java](./src/main/java/org/bigdata/Main.java) 里 `Main.main()` 的三行代码，这些代码只用于本地模式的运行和测试：
    ```java
    // Code For **LOCAL** debug
    // You should delete this when you want to submit .jar for **hadoop jar**
    conf.set("mapred.job.tracker", "local");
    conf.set("fs.default.name", "local");
    FileUtils.deleteDirectoryIfExists(new File(args[1]));
    ```
    - 然后，在 Maven 菜单点击 `生存期` 选项里的 `clean` 和 `package` 生成 jar 文件包到 target 文件夹。
    - 最后，只需要在终端运行本目录的 [test-pseudo.sh](test-pseudo.sh) ，即可自动完成文件拷贝和测试运行。

## Q&A

1. **提交代码时的善意提醒**：
    - **只提交 Java 代码、./target/ 文件夹的 JAR 包和 pom.xml；**
    
    - **删除 Main.java 里辅助调试的 `FileUtils` 类和 main 方法的三行调试代码；**
    - **建议修改 src/main/java 里的目录结构。**

2. 本项目不能代替您学习 MapReduce 应用开发，仅供简化 Hadoop 等软件的安装流程。我们推荐您阅读官方文档和可靠的教程/课程，这样您才能上手本项目进行开发。

    *精力是最宝贵的资源。我们希望这个项目能减少一些本不该有的受挫感，让您把精力投入到正确的事情上。*

3. 为什么不自动化关闭容器时的额外命令？/ 为什么这个项目还不够优雅？

    答：简而言之，是因为 Docker 的设计缺陷。当 Docker 容器终止时，内核会向 1 号进程发送 SIGTERM，默认情况下 10s 后就会被杀死，这不足以我们完成所有的 stop 工作。没有找到确保关机时一定执行完所有脚本的方法，所以最好由你来亲自做这件事情。**我们强烈欢迎彻底解决这个问题的贡献，和其他让本项目工作流程更加丝滑的核心贡献。**
