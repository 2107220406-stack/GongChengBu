# Windows 11 Python 环境与 uv 极速管理完全指南

> **本文档基于以下实际环境生成：**
> - 操作系统：Windows 11
> - 已有 Python：3.13.2（位于 `D:\python3.13.2\`）
> - 终端：PowerShell
> - uv 安装位置：`E:\uv\bin`
> - uv 数据/缓存位置：`E:\uv\` 下

---

## 目录
1. [基础篇：确认 Python 环境](#1-基础篇确认-python-环境)
2. [传统篇：使用 venv 与 pip 管理项目](#2-传统篇使用-venv-与-pip-管理项目)
3. [避坑篇：Python 安装目录迁移的风险](#3-避坑篇python-安装目录迁移的风险)
4. [进阶篇：安装并配置 uv 到 E 盘](#4-进阶篇安装并配置-uv-到-e-盘)
5. [实战篇：uv 的日常使用与验证](#5-实战篇uv-的日常使用与验证)

---

## 1. 基础篇：确认 Python 环境

在 PowerShell 中使用以下命令查看当前 Python 的状态。

### 1.1 查看默认版本与位置
```powershell
# 查看版本号
python --version
py --version

# 查看当前使用的 Python 绝对路径（推荐）
Get-Command python

# 查看系统 PATH 中所有名为 python.exe 的路径
where.exe python
```

### 1.2 查看电脑上所有已安装的 Python 版本
Windows 官方的 `py` 启动器是最方便的工具：
```powershell
# 列出所有版本
py -0

# 列出所有版本及其完整路径，带 * 号的是当前默认版本（推荐）
py -0p
```

---

## 2. 传统篇：使用 venv 与 pip 管理项目

> **注意**：`pip` 只能管理包，**不能**创建虚拟环境。虚拟环境用自带的 `venv` 模块创建。

### 2.1 创建并激活虚拟环境
```powershell
# 进入项目目录
cd C:\你的路径\project

# 创建名为 .venv 的虚拟环境（使用系统当前的 Python）
python -m venv .venv

# 激活虚拟环境 (PowerShell)
.\.venv\Scripts\Activate.ps1
```
> **⚠️ 常见报错**：如果提示“禁止运行脚本”，执行以下命令放开当前用户的权限：
> `Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy RemoteSigned`

### 2.2 使用 pip 管理依赖
```powershell
# 升级 pip 自身
python -m pip install --upgrade pip

# 安装包
python -m pip install requests

# 将当前环境的所有包导出到 requirements.txt
python -m pip freeze > requirements.txt

# 根据 requirements.txt 安装依赖
python -m pip install -r requirements.txt
```

---

## 4. 进阶篇：安装并配置 uv 到 E 盘

`uv` 是一个用 Rust 编写的极速 Python 包管理器。**注意：不要使用 `pip install uv`**，应使用官方安装脚本。

### 4.0 将 uv 本体安装到 C 盘
```powershell
# 1. 执行官方脚本下载并安装
powershell -ExecutionPolicy ByPass -c "irm https://astral.sh/uv/install.ps1 | iex"
```
### 4.1 将 uv 本体安装到 E 盘
在 PowerShell 中依次执行（**注意：不要套 `powershell -c`**）：
```powershell
# 1. 临时设置 uv 程序本体的安装路径
$env:UV_INSTALL_DIR = "E:\uv\bin"

# 2. 执行官方脚本下载并安装
irm https://astral.sh/uv/install.ps1 | iex
```
安装后，**务必重新打开** PowerShell，输入 `uv --version` 验证。路径应指向 `E:\uv\bin\uv.exe`。

### 4.2 将 uv 的数据目录迁移到 E 盘
为了让 uv 的 Python 解释器和缓存不占用 C 盘，永久设置以下环境变量：
```powershell
# 设置 uv 下载的 Python 解释器存放路径
setx UV_PYTHON_INSTALL_DIR "E:\uv\python"

# 设置 uv 的包全局缓存路径
setx UV_CACHE_DIR "E:\uv\cache"

# 设置 uv 安装的全局工具路径
setx UV_TOOL_DIR "E:\uv\tools"
```
> **注意**：`setx` 设置后需要**关闭并重新打开 PowerShell** 才会生效。你可以用 `echo $env:UV_PYTHON_INSTALL_DIR` 检查。

### 4.3 配置国内清华镜像源（针对 uv 0.13.7+）
uv 没有 `uv config set` 命令，需要手动创建配置文件。
1. 按下 `Win + R`，输入 `%APPDATA%\uv` 并回车，进入该目录。
2. 新建一个文本文件，重命名为 **`uv.toml`**（去掉 `.txt` 后缀）。
3. 用记事本打开，写入以下内容并保存：
```toml
[[index]]
url = "https://pypi.tuna.tsinghua.edu.cn/simple"
default = true
```
*(可选环境变量方式)*：也可以运行 `setx UV_DEFAULT_INDEX "https://pypi.tuna.tsinghua.edu.cn/simple"`。

---

## 5. 实战篇：uv 的日常使用与验证

### 5.1 检查是否安装了 uv 及环境排查
```powershell
# 系统上是否安装了 uv
uv --version
Get-Command uv

# 当前虚拟环境是否安装了 uv 包（正常不应安装）
python -m pip show uv
```

### 5.2 推荐的 uv 项目工作流（现代方式）
摒弃手动激活和 pip 安装，直接使用项目模式：
```powershell
# 1. 在空目录初始化项目（生成 pyproject.toml）
uv init

# 2. 添加依赖（自动创建 .venv 环境，自动走清华源，并写入依赖）
uv add requests

# 3. 运行代码（无需手动激活环境，uv 会自动寻找当前目录的 .venv）
uv run main.py
```

### 5.3 兼容 pip 工作流（传统方式）
如果你有现成的项目或习惯手动激活：
```powershell
# 创建虚拟环境
uv venv

# 激活环境
.\.venv\Scripts\Activate.ps1

# 安装包（极速下载）
uv pip install requests

# 导出依赖
uv pip freeze > requirements.txt
```

### 5.4 终极验证：确认镜像源是否生效
使用 `-v` 参数（Verbose）查看详细日志，检查下载链接是否指向清华源：
```powershell
uv pip install requests -v
```
在输出日志中寻找类似以下内容：
`DEBUG Sending fresh GET request for: https://pypi.tuna.tsinghua.edu.cn/...`
如果出现 `Resolved... in 6ms` 和 `Installed... in 15ms` 这种毫秒级时间，则说明 uv 并发下载引擎和清华源均工作完美。