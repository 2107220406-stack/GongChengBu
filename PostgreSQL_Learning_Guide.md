# PostgreSQL + Python 从零开始学习指南 (Windows 11)

> **学习环境**：Windows 11, PowerShell, VS Code, PyCharm, Python
> **学习目标**：从零搭建 PostgreSQL 数据库，掌握基础 SQL 操作，并能使用 VS Code 和 Python 连接数据库。

---

## 📋 目录
1. [下载与安装](#1-下载与安装)
2. [配置环境变量](#2-配置环境变量)
3. [用户管理与密码配置](#3-用户管理与密码配置)
4. [数据库与数据表初步实践 (SQL)](#4-数据库与数据表初步实践-sql)
5. [VS Code 连接数据库](#5-vs-code-连接数据库)
6. [使用 Python 连接 PostgreSQL](#6-使用-python-连接-postgresql)
7. [核心避坑指南](#7-核心避坑指南)

---

## 1. 下载与安装

*   **下载地址**：[EnterpriseDB 官方下载页](https://www.enterprisedb.com/downloads/postgres-postgresql-downloads)
*   **版本选择**：点击 **`17.11`** 版本对应的 **`Windows x86-64`** 蓝色下载图标。（建议使用 17 版本，18版本在 Windows 上存在命令行历史记录缺失等小问题，17版本更稳定成熟）。
*   **安装注意事项**：
    1.  **右键**以管理员身份运行下载的 `.exe` 文件。
    2.  **Installation Directory (安装目录)**：修改为 D 盘，例如 `D:\PostgreSQL`。**（注意：路径中绝不能有中文或空格）**。
    3.  **Data Directory (数据目录)**：修改为 `D:\PostgreSQL\data`。
    4.  **Password (超级用户密码)**：为默认超级用户 `postgres` 设置密码。**（必须牢记此密码！）**
    5.  **Port (端口)**：保持默认 `5432`。
    6.  **Locale (区域)**：务必选择 `Default (C)` 或 `English (United States)`，避免中文编码导致乱码。

---

## 2. 配置环境变量

为了在 PowerShell 任何目录下都能直接使用 `psql` 命令，需配置系统环境变量。

**操作步骤**：
1. 以**管理员身份**打开 PowerShell。
2. 复制并运行以下代码（确保路径与你实际的安装路径一致）：

```powershell
# 将路径替换为你的实际安装路径 (指向 bin 目录)
$addPath = 'D:\PostgreSQL\bin'
$target = 'Machine' # 'Machine'表示系统变量
$path = [Environment]::GetEnvironmentVariable('Path', $target)

# 防止重复添加
if ($path -match ";$") {
    $newPath = $path + $addPath
} else {
    $newPath = $path + ';' + $addPath
}
[Environment]::SetEnvironmentVariable('Path', $newPath, $target)

```

---

## 3. 用户管理与密码配置

为了安全，不要一直使用超级用户 `postgres`。我们需要创建一个日常开发用的普通用户。

**1. 首次连接数据库**
重新打开 PowerShell，输入以下命令，按回车后输入你安装时设置的 `postgres` 密码：
```bash
psql -U postgres
```
*(此时命令提示符会变成 `postgres=#`)*

**2. 创建专属用户**
执行以下 SQL 语句（将 `myuser` 和密码替换为你自己的）：
```sql
-- 创建用户并设置密码
CREATE USER myuser WITH PASSWORD 'YourStrongPassword123!';

-- （可选）赋予该用户创建数据库的权限
ALTER ROLE myuser WITH CREATEDB;
```

**3. 退出超级用户**
```sql
\q
```

---

## 4. 数据库与数据表初步实践 (SQL)

以下操作将使用你刚才创建的 `myuser` 用户进行。

**1. 登录并创建数据库**
在 PowerShell 中登录（输入 `myuser` 的密码）：
```bash
psql -U myuser -d postgres
```

在 `psql` 环境中创建数据库并进入：
```sql
CREATE DATABASE learning_db;
\c learning_db  -- 切换到新创建的数据库
```
*(提示：在 psql 中，以反斜杠 `\` 开头的不是 SQL 语句，而是 psql 的元命令。例如 `\l` 查看所有库，`\dt` 查看所有表)*

**2. 创建数据表**
```sql
CREATE TABLE students (
    id SERIAL PRIMARY KEY,        -- 自增主键
    name VARCHAR(50) NOT NULL,    -- 姓名，不能为空
    age INT,                      -- 年龄
    enrollment_date DATE          -- 入学日期
);
```

**3. 增删改查 (CRUD) 初步实践**
```sql
-- 插入数据 (INSERT)
INSERT INTO students (name, age, enrollment_date) VALUES ('张三', 20, '2024-09-01');
INSERT INTO students (name, age, enrollment_date) VALUES ('李四', 22, '2023-09-01');

-- 查询数据 (SELECT)
SELECT * FROM students;
SELECT name, age FROM students WHERE age > 20;

-- 更新数据 (UPDATE)
UPDATE students SET age = 21 WHERE name = '张三';

-- 删除数据 (DELETE)
DELETE FROM students WHERE name = '李四';
```
> 注意：在 `psql` 中，SQL 语句必须严格以**分号 `;`** 结尾才会执行。

---

## 5. VS Code 连接数据库

推荐使用微软官方的 PostgreSQL 扩展，图形化界面友好，支持智能提示。

**1. 安装扩展**
*   在 VS Code 扩展商店 (`Ctrl+Shift+X`) 搜索 **`PostgreSQL`**，认准 **Microsoft** 官方发布的扩展，点击安装。

**2. 配置连接**
*   点击左侧活动栏的 **PostgreSQL 图标**（大象图标）。
*   在 "Connections" 旁点击 **`+`** 号：
    *   **Server name**: `localhost`
    *   **Authentication Type**: `Password`
    *   **User name**: `myuser`
    *   **Password**: 你的密码（建议勾选 Save Password）
    *   **Database name**: `learning_db`
*   点击 **"Save and Connect"**。

**3. 执行 SQL**
*   在左侧连接树中，右键点击 `learning_db`，选择 **"New Query"**。
*   在新建的 `.sql` 文件中编写代码。
*   **执行快捷键**：`Ctrl+Shift+E` (或 `Shift+Enter`)。选中某行则只执行该行，不选中则执行全部。

---

## 6. 使用 Python 连接 PostgreSQL

使用 `psycopg2` 库进行连接。

**1. 安装依赖**
在 VS Code 或 PyCharm 的终端中运行：
```powershell
pip install psycopg2-binary
```
*(注：`psycopg2-binary` 包含了预编译的二进制文件，适合新手学习安装，避免 C++ 编译报错)*

**2. Python 连接代码 (`db_test.py`)**
将以下代码复制到你的 Python 文件中并运行：

```python
import psycopg2

try:
    # 建立连接
    conn = psycopg2.connect(
        database="learning_db",
        user="myuser",
        password="YourStrongPassword123!", # 替换为你的真实密码
        host="localhost",
        port="5432"
    )
    print("✅ 数据库连接成功！")

    # 创建游标对象
    cur = conn.cursor()
    
    # 执行查询语句
    cur.execute("SELECT name, age FROM students;")
    rows = cur.fetchall()
    
    print("\n📊 students 表的数据：")
    for row in rows:
        print(f"姓名：{row[0]}, 年龄：{row[1]}")

    # 关闭游标
    cur.close()

except (Exception, psycopg2.DatabaseError) as error:
    print(f"❌ 发生错误：{error}")
finally:
    # 确保连接被关闭
    if 'conn' in locals() and conn is not None:
        conn.close()
        print("\n🔒 数据库连接已关闭。")
```

---

## 7. 核心避坑指南

1.  **密码问题**：安装时设置的 `postgres` 密码，以及后来创建的 `myuser` 密码，千万不要忘记。如果忘记，重置过程非常繁琐。
2.  **路径问题**：安装路径千万别带中文字符。
3.  **分号问题**：在终端使用 `psql` 时，任何 SQL 语句结尾必须有 `;`。
4.  **重启终端**：配置完环境变量后，如果不重启 PowerShell 窗口，输入 `psql` 会提示“找不到命令”。
5.  **编码问题**：安装时如果 Locale 选了中文，后续 Python 连接或控制台输出可能会出现乱码，切记选英文或默认 (C)。
