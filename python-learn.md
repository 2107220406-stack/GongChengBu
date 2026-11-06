
### 🐍 第一步：下载与安装 Python（安装到 D 盘）

#### 📥 下载官方安装包
务必从 Python 官方网站下载，以保证安全性和兼容性。访问 [python.org/downloads](https://www.python.org/downloads/)，下载最新的稳定版本（如 Python 3.13.x 或 3.14.x）。根据你的系统位数选择 **Windows installer (64-bit)**。如果不确定系统类型，可以在“设置 → 系统 → 关于”中查看“系统类型”，显示“64位操作系统”则选择 64-bit 安装包。

#### ⚙️ 安装时的关键勾选与设置
双击下载的 `.exe` 文件启动安装向导。**不要直接点击“Install Now”**，请按以下步骤操作，以确保安装到 D 盘并正确配置环境变量：

1.  **勾选底部关键选项**：在安装首页底部，**务必勾选 “Add python.exe to PATH”**（或将 Python 添加到环境变量）。这是最重要的一步，它允许你在任意目录的命令行中直接使用 `python` 命令。建议同时勾选 “Use admin privileges when installing py.exe”。
2.  **选择自定义安装**：点击 **“Customize installation”**，进入可选功能页面。在这里保持默认，确保 **pip**、**tcl/tk and IDLE**、**py launcher** 等选项被勾选，然后点击 Next。
3.  **修改安装路径到 D 盘**：在 “Advanced Options” 页面，找到 “Customize install location” 一栏，将默认的 C 盘路径（如 `C:\Users\用户名\AppData\Local\Programs\Python\Python312`）**修改为 D 盘下的一个简单路径，例如 `D:\Python312`**。路径中**不要包含中文或空格**，以避免兼容性问题。
4.  **完成安装**：点击 “Install” 开始安装。安装完成后，如果弹出 “Setup was successful” 窗口，**务必点击 “Disable path length limit”**，以解除 Windows 对文件路径长度的限制，然后点击 Close。

#### ✅ 验证安装与环境变量
安装程序在勾选 “Add python.exe to PATH” 后通常会自动配置好环境变量，但最好手动验证一下：
1.  按 `Win + R`，输入 `cmd` 并回车，打开命令提示符。
2.  输入 `python --version`，如果正确显示版本号（如 `Python 3.12.5`），说明 Python 已可用。
3.  输入 `pip --version`，应显示 pip 的版本及其在 D 盘的安装路径（如 `... from D:\Python312\Lib\site-packages\pip...`）。
如果任一命令提示“不是内部或外部命令”，则说明环境变量未生效。你需要**手动将 `D:\Python312` 和 `D:\Python312\Scripts` 这两个目录添加到系统的 PATH 环境变量中**。

> **提示**：如果希望 pip 安装包时速度更快，可以将其默认源更换为国内镜像。在命令行中执行以下命令即可全局设置清华源：
> ```powershell
> pip config set global.index-url https://pypi.tuna.tsinghua.edu.cn/simple
> pip config set global.trusted-host pypi.tuna.tsinghua.edu.cn
> ```

---

### 🛠️ 第二步：在 VS Code 与 PyCharm 中配置 Python

Python 本身安装好后，你的 VS Code 和 PyCharm 还需要“知道”它的存在。

#### 💻 在 VS Code 中配置
1.  **安装 Python 扩展**：打开 VS Code，进入扩展面板（`Ctrl+Shift+X`），搜索并安装 **“Python”** 扩展（由 Microsoft 提供）。这个扩展包含了语法高亮、调试、代码导航等核心功能。
2.  **选择 Python 解释器**：打开任意一个 `.py` 文件（或新建一个），VS Code 右下角会显示当前选择的解释器。点击它（或使用命令面板 `Ctrl+Shift+P` 并输入 `Python: Select Interpreter`），在弹出的列表中选择你安装在 D 盘的 Python 路径（例如 `D:\Python312\python.exe`）。VS Code 通常能自动检测到它。

#### 🐘 在 PyCharm 中配置
PyCharm 社区版（免费）对于初学者和日常脚本开发已经完全足够。安装时同样建议装到 D 盘。
1.  **打开设置**：在 PyCharm 中，按下 `Ctrl+Alt+S` 打开设置。
2.  **添加解释器**：导航到 **“Project: <你的项目名>” → “Python Interpreter”**。点击右侧的齿轮图标或“Add Interpreter”链接，选择 **“Add Local Interpreter”**。
3.  **指定路径**：在弹出的窗口中，选择“System Interpreter”，然后点击 `...` 按钮，浏览并选择你 D 盘的 Python 可执行文件（如 `D:\Python312\python.exe`），点击 OK 确认即可。

---

### ✍️ 第三步：第一个 Python 程序与基础实践

环境配好后，就可以开始写代码了。你可以在 VS Code 或 PyCharm 中新建一个文件 `hello.py`，输入以下代码并运行（VS Code 中点击右上角的运行按钮，PyCharm 中右键点击文件并选择 Run）：
```python
print("Hello, Python!")
```
在终端看到输出，就代表你的开发环境完全就绪了。

为了帮你初步感受 Python 的核心概念，可以再尝试运行下面这段涵盖变量、条件和循环的小代码：
```python
# 变量与基本类型
name = "小明"
age = 18
score = 85
print(f"{name} 今年 {age} 岁")

# 条件判断
if score >= 60:
    print("恭喜，及格了！")
else:
    print("继续加油！")

# 循环
for i in range(1, 4):
    print(f"第 {i} 次练习")

# 函数
def greet(person_name):
    return f"你好，{person_name}！"

print(greet("同学"))
```

---

### 💡 几个让起步更顺利的小建议

- **关于虚拟环境**：即使 Python 主程序装在 D 盘，更推荐的做法是**为每个项目创建独立的虚拟环境**（在项目文件夹下执行 `python -m venv venv`）。这样不同项目依赖的库版本可以互不干扰，避免冲突，也能让你的 D 盘 Python 主目录保持整洁。
- **善用 PowerShell**：你习惯使用 PowerShell，它完全可以作为运行 Python 命令、管理 pip 包的终端。只要 Python 的 PATH 配置正确，在 PowerShell 中的操作与 `cmd` 完全一致。