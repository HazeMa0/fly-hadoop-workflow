# fly-hadoop2-workflow：让编写 hadoop 2.7 应用的效率飞起来

## 背景

某校计算机科学与技术专业的《大数据处理综合实验》课程对开发环境做了如下要求：
 - GNU/Linux (以 RHELS 7.0 为例)
 - JDK 1.7
 - Hadoop 2.7.1

如果你也是重度强迫症患者，对将如此陈旧的环境安装到自己的 GNU/Linux 发行版造成的麻烦感到不值，同时又对虚拟机的工作效率感到不满，那选择本项目作为工作环境一定会让您身心愉悦。

*Just for fun.*

## Get Started

首先，你需要在 Windows 或 GNU/Linux 发行版安装以下应用：
 - 版本较新的 [Docker](https://docs.docker.com/get-started/get-docker/)，如果是 Windows 请使用 [WSL2](https://learn.microsoft.com/zh-cn/windows/wsl/install) 后端
 - [IntelliJ IDEA](https://www.jetbrains.com/zh-cn/idea/download/) 2023.2 及以上版本，在启动页面有 [Dev Container](https://intellijidea.com.cn/connect-to-devcontainer.html) 选项
 ![](readme_pic/1.png)

> 注意！
> 本项目并未在旧版 IDEA 和 Docker 上进行验证，所以最好还是用新版吧。

接下来很容易进入开发环境：
1. 打开 IntelliJ IDEA（如果打开了您已有的项目，请点击左上角的 `文件` > `关闭项目`）， 选择 `远程开发` > `Dev Container`，在右侧页面点击 `新建 Dev Container`；
![](readme_pic/2.png)
2. 在页面上方点击 `从本地项目`，找到您 clone 好的本项目代码文件夹的 `.devcontainer/devcontainer.json` 文件，点击右下角的 `构建容器并继续`；
![](readme_pic/3.png)
3. 稍等片刻，Dev Container 环境就自动创建好了。请确认 IDEA 弹出的若干窗口，进行确认即可。
> 我遇到了问题？
> 请先确认一下您可以连接国际互联网，而且 Docker 的守护进程是打开的。如果还有问题，请在 Issues 反馈，作者可能会进行修复，也许吧。

4. 在 IDEA 的终端输入 `jps`，可以发现 hadoop 环境已经准备好了。我们默认开放了 8088、9000、50070、50075、50090 五个端口，您可以通过在本机浏览器打开 `localhost:端口号` 来直接访问这些页面。
![](readme_pic/4.png)

## 进行开发

我们已经在项目文件夹准备好了一个 MapReduce 应用作为测试，其会计数 [test-in/](test-in/) 文件夹内文本中每个单词的数量，与官方提供的 `wordCount` 应用功能类似。我们使用 Maven 管理项目。
 - **在一切开始之前**：点击 IDEA 右侧菜单栏的 `maven` 按钮，在打开的面板中找到左上角的 `刷新` 按钮，点击 `重新加载所有 Maven 项目` 以在线加载该项目需要的依赖。
![](readme_pic/5.png)
 - **本地模式**：您可以直接点击 IDEA 里 [Main.java](src\main\java\org\bigdata\Main.java) 的运行和调试按钮进行本地运行和调试，十分方便。（然而这是实验讲义和官方安装引导未写明的。）
 - **伪分布模式**
 您需要先注释掉 [Main.java](src\main\java\org\bigdata\Main.java) 里 `Main.main(String[] args)` 的三行代码，这些代码只用于本地模式的运行和测试：

```java
// For local debug
// You should delete this when you want to submit .jar for hadoop
conf.set("mapred.job.tracker", "local");
conf.set("fs.default.name", "local");
FileUtils.deleteDirectoryIfExists(new File(args[1]));
```
 然后，在 Maven 菜单点击 `生存期` 选项里的 `clean` 和 `package` 生成 jar 文件包。
 最后，只需要在终端运行本目录的 [test-pseudo.sh](test-pseudo.sh) ，即可自动完成文件拷贝和测试运行。

## Q&A

1.项目文件解释

答：
 - [Dockerfile](Dockerfile) 完成必要组件的安装；
 - 其会将 [DockerConfig/entrypoint.sh](DockerConfig/entrypoint.sh) 作为容器的 1 号进程，该脚本主要负责初始化 Hadoop 环境和文件系统。
 - [.devcontainer/devcontainer.sh](.devcontainer/devcontainer.sh) 作为 Dev Container 的配置文件，负责基于该镜像生成环境的容器。
 - [src](src/) 目录里就是 java 代码。
 - [test-in](test-in/) 和 [test-out](test-out/) 目录就是 hadoop 的输入和输出。（测试文本的版权归原作者所有）
 - [test-pseudo.sh](test-pseudo.sh) 脚本负责将两个文件夹传入 hadoop 的文件系统和我们程序的 jar 包进行伪分布式部署的测试。

2.放虚拟机里面不就行了？

答：高情商：*Just for fun.*；低情商：闲的没事干。

3.开源协议？

答：[爱咋用咋用](https://opensource.org/license/mit)，不然基于本项目的作业代码不是也得 [开源](https://integrity.mit.edu/) 了吗？

----
test-in folder has Super Cow Powers.
