# MySQL + Python 本地学习自包含合并笔记

> **重要安全说明**：文中 `root / 123456`、`dev_user / DevPass@2026`、`devuser / Dev@2026` 仅用于本地学习示例。实际项目请使用强密码，不要把密码硬编码进代码或提交到 Git；不要把公网 3306 端口无差别开放给 `0.0.0.0/0`。

---

## 目录

- [1. 适用环境与学习目标](#1-适用环境与学习目标)
- [2. 下载与安装 MySQL 到 D 盘](#2-下载与安装-mysql-到-d-盘)
- [3. 确认 MySQL 的位置和版本](#3-确认-mysql-的位置和版本)
- [5. 配置环境变量与服务](#5-配置环境变量与服务)
- [6. 使用 root 登录并修改密码](#6-使用-root-登录并修改密码)
- [7. 创建数据库、普通开发用户并授权](#7-创建数据库普通开发用户并授权)
- [8. 查询数据库用户、数据库、数据表和权限](#8-查询数据库用户数据库数据表和权限)
- [9. 创建数据库与数据表](#9-创建数据库与数据表)
- [10. 基础实践：增删改查 CRUD](#10-基础实践增删改查-crud)
- [11. 在 VS Code / PyCharm 中使用 MySQL](#11-在-vs-code--pycharm-中使用-mysql)
- [12. 在 Python 中连接 MySQL](#12-在-python-中连接-mysql)
- [16. 参考 URL 汇总](#16-参考-url-汇总)
- [18. 学习检查清单](#18-学习检查清单)

---

## 1. 适用环境与学习目标

- 操作系统：Windows 11
- 终端：PowerShell
- 编辑器：VS Code、PyCharm
- 数据库：MySQL 8.x Community
- 语言：Python
- 目标：
  1. 下载并安装 MySQL 到 D 盘，或确认已有 MySQL 安装位置、版本和服务名
  2. 检查电脑上是否还有其他数据库
  3. 配置环境变量，启动 MySQL 服务
  4. 用 root 登录，修改 root 密码
  5. 查询数据库用户、数据库和数据表
  6. 创建学习数据库、普通开发用户并授权
  7. 建表并完成增删改查 CRUD
  8. 在 VS Code / PyCharm 中管理 MySQL
  9. 在 Python 中连接 MySQL（PyMySQL 与 mysql-connector-python 两种方式）
  10. 用普通用户查询自己的数据库访问权限
  11. 理解远程连接 MySQL 的网络、防火墙/安全组、`user@host` 权限三关
  12. 掌握常见问题排查与安全实践清单

---

## 2. 下载与安装 MySQL 到 D 盘

### 2.1 下载

官方下载页：

- MySQL Installer：https://dev.mysql.com/downloads/installer/
- MySQL 官方文档：https://dev.mysql.com/doc/

下载 **MySQL Installer for Windows** 中的 Community 版本，例如 `mysql-installer-community-8.0.xx.msi`。

### 2.2 安装时选择 Custom 并改到 D 盘

1. 双击运行安装包。
2. 在 “Choosing a Setup Type” 界面不要选默认的 Developer Default，选择 **Custom**，点击 Next。
3. 展开 `MySQL Servers` → `MySQL Server` → `MySQL Server 8.0`。
4. 选中 `MySQL Server 8.0.xx - X64`，点击向右箭头加入右侧待安装列表。
5. 选中右侧的 MySQL Server，点击 **Advanced Options**。
6. 把安装路径中的 `C` 改成 `D`，例如：
   ```text
   D:\Program Files\MySQL\MySQL Server 8.0
   ```
7. 点击 OK，再点击 Next。
8. 点击 **Execute** 等待安装完成，然后一路 Next。
9. 在 **Accounts and Roles** 界面为 `root` 设置强密码：至少 8 位，包含大小写字母、数字和特殊字符。
10. 服务配置保持默认即可，继续 Next → Execute → Finish。

> 说明：安装路径以你实际选择的为准。后文出现 `D:\Program Files\MySQL\MySQL Server 8.0\bin` 时，请替换成你的真实 `bin` 路径。

---

## 3. 确认 MySQL 的位置和版本

### 3.1 查看 MySQL 版本

```powershell
# 如果 PATH 配置正确，会显示 MySQL 版本
mysql --version
```

如果提示“无法将 mysql 项识别为 cmdlet”，说明 MySQL 的 `bin` 目录可能没有加入系统 `PATH`，但不代表没有安装。

### 3.2 查找 mysql 可执行文件路径

```powershell
# 如果 mysql 命令可用，直接返回可执行文件完整路径
(Get-Command mysql).Path

# 某些环境下需要带 .exe
(Get-Command mysql.exe).Path
```

### 3.3 通过 Windows 服务查找 MySQL 安装路径

```powershell
# 查看 MySQL 相关服务名，通常包含版本号，例如 MySQL80
Get-Service | Where-Object Name -Like "MySQL*"

# 通过服务信息查找 mysqld.exe 路径
Get-WmiObject win32_service |
  Where-Object {$_.Name -like '*mysql*'} |
  Select-Object -ExpandProperty PathName
```

PowerShell 7 或较新环境也可以使用：

```powershell
Get-CimInstance Win32_Service |
  Where-Object {$_.Name -like '*mysql*'} |
  Select-Object -ExpandProperty PathName
```

返回路径示例：

```text
"C:\Program Files\MySQL\MySQL Server 8.0\bin\mysqld.exe"
```

从路径中即可看出 MySQL 安装目录。

### 3.4 全盘搜索 mysql.exe

```powershell
# 较慢，建议忽略权限错误
Get-ChildItem -Path C:\ -Filter mysql.exe -Recurse -ErrorAction SilentlyContinue
```

---

## 5. 配置环境变量与服务

### 5.1 配置环境变量

目的：让 PowerShell 能直接识别 `mysql` 命令。

1. 按 `Win` 键，搜索 **环境变量**，打开 **编辑系统环境变量**。
2. 点击 **环境变量**。
3. 在 **系统变量** 区域选中 `Path`，点击 **编辑**。
4. 点击 **新建**，填入 MySQL 的 `bin` 目录，例如：
   ```text
   D:\Program Files\MySQL\MySQL Server 8.0\bin
   ```
5. 一路点击“确定”保存。
6. **重新打开一个新的 PowerShell 窗口**，旧窗口不会自动加载新环境变量。

验证：

```powershell
# 查看 MySQL 客户端版本，能显示版本号即环境变量成功
mysql --version
```

### 5.2 找到并启动 MySQL 服务

MySQL 在 Windows 上通常作为后台服务运行。启动服务需要**以管理员身份运行 PowerShell**。

```powershell
# 查看名称中包含 mysql 的服务，常见服务名是 MySQL80 或 MySQL
Get-Service -Name *mysql*

# 查看显示名包含 MySQL 的服务
Get-Service -DisplayName "MySQL*"
```

在返回结果的 `Name` 列中查看服务名，例如 `MySQL80`。后续命令中的 `MySQL80` 要替换成你的实际服务名。

启动服务：

```powershell
Start-Service -Name MySQL80
```

备选方式：

```powershell
net start MySQL80
```

> 如果服务状态已经是 `Running`，可跳过启动步骤。

如果修改配置后需要重启服务，请在**管理员 PowerShell** 中执行：

```powershell
# 先通过 Get-Service -Name *mysql* 找到实际服务名，再替换下面的 MySQL80
Restart-Service -Name MySQL80
```

---

## 6. 使用 root 登录并修改密码

### 6.1 登录 MySQL

在普通权限 PowerShell 中执行：

```powershell
# -u 指定用户，-p 表示交互式输入密码；输入密码时屏幕不回显
mysql -u root -p
```

按回车后输入密码。本地学习示例可能是：

```text
123456
```

输入密码时屏幕不显示字符，这是正常安全机制。登录成功后提示符会变为：

```text
mysql>
```

退出 MySQL：

```sql
EXIT;
-- 或
QUIT;
```

### 6.2 修改 root 密码（需要时）

在 `mysql>` 下执行：

```sql
-- 将“你的新密码”替换为强密码
ALTER USER 'root'@'localhost' IDENTIFIED BY '你的新密码';
FLUSH PRIVILEGES;
```

---

## 7. 创建数据库、普通开发用户并授权

> 推荐日常开发不使用 root。先用 root 创建权限受限的新用户，再把工具连接配置中的用户名和密码替换掉。

### 7.1 创建学习数据库

```sql
-- 创建学习数据库；推荐显式指定 utf8mb4
CREATE DATABASE IF NOT EXISTS learn_python
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_0900_ai_ci;
```

### 7.2 创建普通用户

以 root 登录 MySQL 后执行：

```sql
-- 创建本地开发用户；请把密码替换成你自己的强密码
CREATE USER 'dev_user'@'localhost' IDENTIFIED BY 'DevPass@2026';
```

`@'localhost'` 表示该用户只能从本机连接，比 `@'%'` 更安全。

> 第二份笔记的等价示例是：`CREATE USER 'devuser'@'localhost' IDENTIFIED BY 'Dev@2026';`

### 7.3 授予权限

方案 A：只授予某个数据库的完整权限，推荐日常开发：

```sql
GRANT ALL PRIVILEGES ON learn_python.* TO 'dev_user'@'localhost';
FLUSH PRIVILEGES;
```

方案 B：授予所有数据库权限，仅限本地学习环境：

```sql
GRANT ALL PRIVILEGES ON *.* TO 'dev_user'@'localhost';
FLUSH PRIVILEGES;
```

> 方案 B 权限较大，不建议生产环境或多人共用电脑使用。授权遵循最小权限原则，优先只授权具体数据库。

### 7.4 验证新用户登录

```powershell
mysql -u dev_user -p
```

输入密码：

```text
DevPass@2026
```

能进入 `mysql>` 提示符即创建成功。也可以直接选择数据库：

```powershell
# 使用 dev_user 登录并直接选择 learn_python 库
mysql -u dev_user -p learn_python
```

> 第二份笔记等价命令为：`mysql -u devuser -p learn_python`。

### 7.5 修改用户密码

```sql
ALTER USER 'dev_user'@'localhost' IDENTIFIED BY '新密码';
```

### 7.6 认证插件兼容性处理

极少数旧工具可能不支持 MySQL 8 默认的 `caching_sha2_password`。如果连接时报 `ER_NOT_SUPPORTED_AUTH_MODE`，仅限本地学习环境可临时改为：

```sql
ALTER USER 'dev_user'@'localhost'
IDENTIFIED WITH mysql_native_password BY 'DevPass@2026';
FLUSH PRIVILEGES;
```

---

## 8. 查询数据库用户、数据库、数据表和权限

> 重要概念：数据库并不是“属于”某个用户。root 用户拥有访问所有数据库的权限。准确说法是：查看 root 有权访问的所有数据库，以及每个库中的数据表。普通用户执行 `SHOW DATABASES;` 时，本身就只会列出“自己有权限访问的库”。

### 8.1 统计业务用户数量

MySQL 中有一些内部系统账号，例如 `mysql.sys`、`mysql.session`、`mysql.infoschema`。统计业务账号时建议排除它们。

```sql
SELECT COUNT(*) AS total_accounts
FROM mysql.user
WHERE user NOT IN ('mysql.sys', 'mysql.session', 'mysql.infoschema');
```

### 8.2 查看完整用户列表

```sql
SELECT user, host
FROM mysql.user
ORDER BY user, host;
```

说明：

- `user`：用户名
- `host`：允许从哪些主机连接，例如 `localhost` 表示仅本机

### 8.3 查看所有数据库

```sql
SHOW DATABASES;
```

MySQL 安装后常见系统库：

```text
information_schema
mysql
performance_schema
sys
```

不要随意修改这些系统库。你自己创建的数据库也会出现在列表中。

### 8.4 切换到某个数据库并查看表

```sql
USE 数据库名;
SHOW TABLES;
```

示例：

```sql
USE mysql;
SHOW TABLES;
```

### 8.5 不切换数据库，直接查看某个库的表

```sql
SHOW TABLES FROM 数据库名;
```

示例：

```sql
SHOW TABLES FROM mysql;
```

### 8.6 一次性查看所有库和表

```sql
SELECT table_schema AS '数据库', table_name AS '表名'
FROM information_schema.tables
WHERE table_schema NOT IN ('information_schema', 'performance_schema', 'sys')
ORDER BY table_schema, table_name;
```

这条语句会跳过部分纯系统库，只显示 `mysql` 和你自己创建的库中的表。

### 8.7 查看表结构、建表语句和表数量

```sql
-- 查看表结构
DESCRIBE 表名;

-- 或
SHOW COLUMNS FROM 表名;

-- 查看建表语句
SHOW CREATE TABLE 表名;

-- 查看每个库的表数量
SELECT table_schema, COUNT(*) AS 表数量
FROM information_schema.tables
GROUP BY table_schema;
```

### 8.8 dev_user 如何查询可访问的数据库和权限

#### 8.8.1 查看自己能访问的数据库

```sql
SHOW DATABASES;
```

通常还会看到 `information_schema`，所有用户都能看到它用于查元数据。

#### 8.8.2 确认当前登录身份

```sql
SELECT CURRENT_USER();
```

返回示例：

```text
dev_user@localhost
```

#### 8.8.3 查看自己的权限

```sql
SHOW GRANTS;
```

或：

```sql
SHOW GRANTS FOR CURRENT_USER();
```

输出示例：

```sql
GRANT ALL PRIVILEGES ON `learn_python`.* TO `dev_user`@`localhost`
```

或：

```sql
GRANT ALL PRIVILEGES ON *.* TO `dev_user`@`localhost`
```

#### 8.8.4 用 information_schema 查权限明细

注意 `GRANTEE` 格式是 `'用户名'@'主机'`，外层要用双引号包起来。

```sql
-- 库级权限：对哪些库有什么权限
SELECT *
FROM information_schema.SCHEMA_PRIVILEGES
WHERE GRANTEE = "'dev_user'@'localhost'";

-- 全局权限：是否有 *.* 级别的权限
SELECT *
FROM information_schema.USER_PRIVILEGES
WHERE GRANTEE = "'dev_user'@'localhost'";

-- 表级权限：是否被单独授权了某张表
SELECT *
FROM information_schema.TABLE_PRIVILEGES
WHERE GRANTEE = "'dev_user'@'localhost'";
```

#### 8.8.5 普通用户能否看到服务器上所有库？

不能。`information_schema.SCHEMATA` 同样受权限过滤，没有权限的库不会出现。只有拥有全局 `SHOW DATABASES` 权限的用户，例如 root，才能看到全部库列表。

---

## 9. 创建数据库与数据表

用 `dev_user` 或 root 登录后执行。注意每条 SQL 末尾加分号 `;`。

```sql
-- 如果还没创建数据库，先创建并选中
CREATE DATABASE IF NOT EXISTS learn_python
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_0900_ai_ci;
USE learn_python;

-- 创建 users 表
CREATE TABLE users (
    id INT PRIMARY KEY AUTO_INCREMENT,          -- 自增主键
    username VARCHAR(50) NOT NULL,              -- 用户名，不能为空
    age INT,                                    -- 年龄
    email VARCHAR(100),                         -- 邮箱
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP -- 默认当前时间
);

-- 查看表结构
DESC users;

-- 查看当前库中的表
SHOW TABLES;
```

---

## 10. 基础实践：增删改查 CRUD

### 10.1 插入数据 Create

```sql
INSERT INTO users (username, age, email) VALUES
('Alice', 25, 'alice@example.com'),
('Bob', 30, 'bob@example.com'),
('Charlie', 22, 'charlie@example.com');
```

### 10.2 查询数据 Retrieve

```sql
-- 查所有
SELECT * FROM users;

-- 只查姓名和年龄
SELECT username, age FROM users;

-- 条件查询：年龄大于 24
SELECT * FROM users WHERE age > 24;

-- 排序：按年龄从大到小
SELECT * FROM users ORDER BY age DESC;

-- 限制返回条数
SELECT * FROM users LIMIT 10;
```

### 10.3 更新数据 Update

```sql
-- 把 Alice 的年龄改成 26；UPDATE 必须带 WHERE
UPDATE users SET age = 26 WHERE username = 'Alice';
```

### 10.4 删除数据 Delete

```sql
-- 删除 Charlie；DELETE 必须带 WHERE
DELETE FROM users WHERE username = 'Charlie';
```

> 安全习惯：执行 `UPDATE` 或 `DELETE` 前，先跑一条同样条件的 `SELECT`，确认影响范围，再执行修改。

---

## 11. 在 VS Code / PyCharm 中使用 MySQL

VS Code 本身不支持直连数据库，需要安装扩展。常见两种方式：

### 11.1 安装扩展

在 VS Code 扩展面板 `Ctrl+Shift+X` 中搜索并安装：

- **Database Client / MySQL**，作者 `cweijan`
  - 推荐首选
  - 开箱即用
  - 对 MySQL 8 默认的 `caching_sha2_password` 认证支持较好
  - 扩展市场：https://marketplace.visualstudio.com/items?itemName=cweijan.vscode-mysql-client2
- **SQLTools + SQLTools MySQL/MariaDB**
  - 先安装主扩展 `SQLTools`
    - https://marketplace.visualstudio.com/items?itemName=mtxr.sqltools
  - 再安装 MySQL/MariaDB 驱动
    - https://marketplace.visualstudio.com/items?itemName=mtxr.sqltools-driver-mysql
  - 安装驱动后建议重启 VS Code

安装后 VS Code 左侧活动栏会出现数据库圆柱图标。

### 11.2 新建本地连接

连接参数示例：

```text
Host: localhost 或 127.0.0.1
Port: 3306
User: dev_user
Password: DevPass@2026
Database: learn_python
```

本地连接建议 Host 用 `127.0.0.1`，强制走 TCP，避免 `localhost` 在某些环境下走 socket 导致混淆。

| 字段 | 本地连接示例 |
|---|---|
| Host | `127.0.0.1` |
| Port | `3306` |
| User | `dev_user` |
| Password | 你的 dev_user 密码 |
| Database | `learn_python` |

使用 Database Client / cweijan 扩展：

1. 点击侧边栏数据库图标
2. 点击 `+` 添加连接
3. 选择 MySQL
4. 填入上述信息
5. 点击 `Test Connection`
6. 成功后保存

使用 SQLTools：

1. 按 `Ctrl+Shift+P`
2. 运行 `SQLTools: New Connection`
3. 选择 MySQL/MariaDB
4. 填入上述连接信息
5. 点击 Test Connection，成功后保存

建议给连接起清晰名称，例如 `local-dev`，与 root 连接区分。

### 11.3 编写并执行 SQL

1. 新建 `.sql` 文件，例如 `practice.sql`。
2. 输入：
   ```sql
   SELECT * FROM users;
   ```
3. 执行方式任选：
   - 光标放在语句上，按 `Ctrl + Enter`；
   - 点击编辑器右上角运行按钮；
   - 选中语句后右键，选择 `Run Query` / `Run MySQL Query` / `Execute Query`。
4. 查询结果会显示在下方结果面板。

如果报 `No database selected`，可以：

```sql
USE learn_python;
```

或在连接配置中明确填写 `database` 字段。

### 11.4 图形化操作

- 展开表可查看表结构、浏览数据、查看建表语句。
- 在表名上右键可使用 Design Table、Generate SQL 等功能。
- 在数据库连接上右键可 New Query，快速写 SQL。

### 11.5 PyCharm 说明

PyCharm 可使用内置 Database 工具或通过 Python 代码连接 MySQL。连接参数与 VS Code 相同：

```text
Host: localhost 或 127.0.0.1
Port: 3306
User: dev_user
Password: DevPass@2026
Database: learn_python
```

> 第二份笔记的等价连接参数为 `User: devuser`、`Password: Dev@2026`。

---

## 12. 在 Python 中连接 MySQL

两种常见驱动都保留：PyMySQL 和 mysql-connector-python。任选一种即可；学习时可以都跑一遍。

### 12.1 安装 PyMySQL

在 VS Code 或 PyCharm 终端中执行：

```powershell
python -m pip install pymysql
```

> 使用 `python -m pip` 可以尽量避免把包装到错误的 Python 解释器环境。

### 12.2 PyMySQL 基础连接与查询示例

```python
import pymysql

# 建立连接
# 注意：以下密码仅用于本地学习
conn = pymysql.connect(
    host='localhost',
    user='dev_user',
    password='DevPass@2026',
    database='learn_python',
    charset='utf8mb4'
)

try:
    with conn.cursor() as cursor:
        cursor.execute("SHOW TABLES;")
        results = cursor.fetchall()
        for row in results:
            print(row)
finally:
    conn.close()
```

> 注意：PyMySQL 默认不是自动提交模式。执行 `INSERT`、`UPDATE`、`DELETE` 后需要 `conn.commit()`，或在连接时设置 `autocommit=True`。

### 12.3 PyMySQL 写入示例

```python
import pymysql

conn = pymysql.connect(
    host='localhost',
    user='dev_user',
    password='DevPass@2026',
    database='learn_python',
    charset='utf8mb4'
)

try:
    with conn.cursor() as cursor:
        cursor.execute(
            "INSERT INTO users (username, age, email) VALUES (%s, %s, %s);",
            ('David', 28, 'david@example.com')
        )
    conn.commit()  # 写入后提交
finally:
    conn.close()
```

### 12.4 使用 .env 管理密码

安装：

```powershell
python -m pip install python-dotenv
```

创建 `.env` 文件：

```dotenv
DB_HOST=localhost
DB_PORT=3306
DB_USER=dev_user
DB_PASSWORD=DevPass@2026
DB_NAME=learn_python
```

Python 读取：

```python
import os
import pymysql
from dotenv import load_dotenv

load_dotenv()

conn = pymysql.connect(
    host=os.getenv('DB_HOST'),
    port=int(os.getenv('DB_PORT', '3306')),
    user=os.getenv('DB_USER'),
    password=os.getenv('DB_PASSWORD'),
    database=os.getenv('DB_NAME'),
    charset='utf8mb4'
)

try:
    with conn.cursor() as cursor:
        cursor.execute("SHOW TABLES;")
        print(cursor.fetchall())
finally:
    conn.close()
```

将 `.env` 加入 `.gitignore`：

```gitignore
.env
```

### 12.5 使用 mysql-connector-python

在 VS Code 或 PyCharm 的终端中安装驱动：

```powershell
# 安装 MySQL 官方 Python 驱动
pip install mysql-connector-python
```

官方文档：https://dev.mysql.com/doc/connector-python/en/

简单连接与查询示例：

```python
# 文件名示例：db_demo.py
# 注意：不要把真实密码提交到 Git；学习时可用环境变量或本地配置文件
import mysql.connector
from mysql.connector import Error

def main():
    connection = None
    try:
        # 本地连接示例；远程连接时把 host 改成远程 IP 或域名
        connection = mysql.connector.connect(
            host="127.0.0.1",
            port=3306,
            user="dev_user",
            password="DevPass@2026",   # 替换成你的密码
            database="learn_python"
        )

        if connection.is_connected():
            print("连接成功")

            cursor = connection.cursor()
            cursor.execute("SELECT id, username, age, email FROM users ORDER BY id")
            rows = cursor.fetchall()

            for row in rows:
                print(row)

            cursor.close()

    except Error as e:
        print(f"数据库操作出错：{e}")
    finally:
        if connection is not None and connection.is_connected():
            connection.close()
            print("连接已关闭")

if __name__ == "__main__":
    main()
```

远程连接时只需改 `host`、`port`、`user`、`password`、`database`，并确保第 14 节的网络和权限已配置好。

### 12.6 把各工具切换到 dev_user

#### Python 代码

把 `pymysql.connect()` 或 `mysql.connector.connect()` 中的 `user` 和 `password` 替换：

```python
conn = pymysql.connect(
    host='localhost',
    user='dev_user',
    password='DevPass@2026',
    database='learn_python',
    charset='utf8mb4'
)
```

#### MySQL 命令行

以后登录直接用：

```powershell
mysql -u dev_user -p
```

如果已经在 `mysql>` 会话中想切换用户，最稳妥的方式是退出后重新登录：

```sql
EXIT;
```

---

## 15. 常见问题排查

| 现象 | 大概率原因 | 解决方向 |
|---|---|---|
| PowerShell 提示找不到 `mysql` 命令 | 环境变量未生效 | 确认 Path 中有 MySQL 的 `bin` 目录，并重新打开 PowerShell |
| 连接报 `Access denied` | 密码错或用户权限不足 | 用 PowerShell 以该用户登录验证；检查 `'user'@'host'` 是否正确 |
| 报 `No database selected` | 连接时 Database 留空 | 连接配置补上 `learn_python`，或先执行 `USE learn_python;` |
| 报 `Connection refused` | MySQL 服务没启动或端口未监听 | 运行 `Get-Service -Name *mysql*` 查看服务；检查端口是否为 3306 |
| 本地能连，远程连不上 | `bind-address` 仍是 127.0.0.1 | 改为 `0.0.0.0` 并重启 MySQL |
| 远程仍连不上 | 防火墙或云安全组未放行 | 放行 TCP 3306，源地址尽量白名单 |
| 远程用户登录失败 | 用户是 `'user'@'localhost'` | 创建 `'user'@'%'` 或指定 IP 的用户并授权 |
| 提示认证插件问题 | MySQL 8.0 默认 `caching_sha2_password`，旧工具不兼容 | 优先使用较新的 MySQL 扩展；必要时仅在兼容旧工具时改用 `mysql_native_password` |
| `UPDATE`/`DELETE` 影响全表 | 漏写 `WHERE` | 执行前先用同样条件 `SELECT` 确认范围 |

认证插件兼容示例（仅在旧工具确实不兼容时使用）：

```sql
-- 将用户和密码替换为实际值；这会改变该用户的认证插件
ALTER USER 'dev_user'@'localhost'
  IDENTIFIED WITH mysql_native_password BY 'DevPass@2026';
FLUSH PRIVILEGES;
```

连接失败时依次检查：MySQL 服务是否启动、端口是否为 3306、用户名密码是否正确、认证插件是否兼容、`bind-address` 和防火墙/安全组是否放行、`user@host` 是否允许当前来源。

---

## 16. 参考 URL 汇总

| 用途 | URL |
|---|---|
| MySQL Installer 下载 | https://dev.mysql.com/downloads/installer/ |
| MySQL 官方文档 | https://dev.mysql.com/doc/ |
| MySQL 官方文档：Windows 启动服务 | https://dev.mysql.com/doc/refman/8.0/en/windows-start-service.html |
| MySQL 官方文档：SHOW GRANTS | https://dev.mysql.com/doc/refman/8.0/en/show-grants.html |
| MySQL 官方文档：CREATE USER | https://dev.mysql.com/doc/refman/8.0/en/create-user.html |
| MySQL 官方文档：GRANT | https://dev.mysql.com/doc/refman/8.0/en/grant.html |
| VS Code 扩展市场 | https://marketplace.visualstudio.com/ |
| VS Code MySQL 扩展（cweijan，Database Client / MySQL） | https://marketplace.visualstudio.com/items?itemName=cweijan.vscode-mysql-client2 |
| VS Code SQLTools | https://marketplace.visualstudio.com/items?itemName=mtxr.sqltools |
| SQLTools MySQL/MariaDB 驱动 | https://marketplace.visualstudio.com/items?itemName=mtxr.sqltools-driver-mysql |
| PyMySQL 文档 | https://pymysql.readthedocs.io/en/latest/ |
| python-dotenv | https://pypi.org/project/python-dotenv/ |
| MySQL Connector/Python 文档 | https://dev.mysql.com/doc/connector-python/en/ |

> 扩展名称和链接可能随版本变化，以 VS Code 扩展市场搜索为准。

---

## 18. 学习检查清单

- [ ] 已把 MySQL Server 安装到 D 盘，并记住真实安装路径；或已确认现有安装位置。
- [ ] 已把 MySQL 的 `bin` 目录加入系统 `Path`。
- [ ] 新开 PowerShell 后 `mysql --version` 能显示版本。
- [ ] 已检查电脑上是否还有其他数据库。
- [ ] 已找到 MySQL 服务名并能启动/重启服务。
- [ ] 已用 root 登录并设置强密码。
- [ ] 已查询过 MySQL 用户列表、数据库列表和表列表。
- [ ] 已创建 `learn_python` 数据库。
- [ ] 已创建 `dev_user@localhost` 并只授予 `learn_python.*` 权限。
- [ ] 已创建 `users` 表并执行过 `DESC users;`。
- [ ] 已完成一次 `INSERT`、`SELECT`、`UPDATE`、`DELETE`。
- [ ] VS Code 已安装 MySQL 扩展并用 `127.0.0.1` 连接本地库。
- [ ] 已安装 `pymysql` 并跑通 Python 查询示例。
- [ ] 已安装 `mysql-connector-python` 并跑通 Python 查询示例。
- [ ] 已知道不要把真实密码提交到 Git，不随意公网开放 3306。

**文件结束。**