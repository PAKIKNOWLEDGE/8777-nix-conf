## 关于hermes agent的安装：

* `curl -fsSL https://res1.hermesagent.org.cn/install.sh | bash` 依旧是可用的
* 这个脚本强依赖的点有：python3.11 uv
* 而 nixpkg的'python3'断言指向python3.13 这个脚本一开始爬不到 会用uv去拉一个做venv
* 但是uv默认源比较慢 那么：
---
 1. 手动用环境变量注入去用uv装python311 然后让脚本跳过检测（`export UV_PYTHON_INSTALL_MIRROR="https://mirror.nju.edu.cn/github-release/astral-sh/python-build-standalone"\nuv python install 3.11` )
 2. 提前配置好uv的全局镜像 **(recommended)**
此外
*  https://res1.hermesagent.org.cn/install.sh 是国内的人公益维护 不一定可靠

20260817 
