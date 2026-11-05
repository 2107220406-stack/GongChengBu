<a id="top"></a>

# 从请求到后端：API 全链路入门讲义

> 适用环境：Windows 11 + PowerShell + Python（已用 uv 管理虚拟环境）+ MySQL 8（root 账号，服务已启动）  
> 全程使用公开测试接口和本地数据库，不需要注册、不需要 API Key。  
> 本文件包含课堂所有代码、URL、注释与讲解，可直接复制跟做，也可课后自学。

---

<a id="toc"></a>

## 目录

- [开始之前](#pre)
  - [环境与约定](#pre-env)
  - [贯穿全程的测试地址](#pre-url)
  - [项目文件夹与终端](#pre-folder)
  - [uv 的用法约定](#pre-uv)
  - [⚠️ Windows 上的第一个坑：curl 不是 curl](#pre-curl)
- [第一章 用 PowerShell + curl 感受网络请求](#ch1)
  - [1.1 只看响应结果](#ch1-1)
  - [1.2 用 `-v` 看清全过程](#ch1-2)
- [第二章 用浏览器看请求与响应](#ch2)
  - [2.1 地址栏直接访问](#ch2-1)
  - [2.2 按 F12 看过程](#ch2-2)
  - [2.3 找出唯一明显不同：`User-Agent`](#ch2-3)
- [第三章 用 Python 代码发请求](#ch3)
  - [3.1 初始化项目](#ch3-1)
  - [3.2 脚本一：打印响应](#ch3-2)
  - [3.3 脚本二：让 Python 报出自己的名字](#ch3-3)
  - [3.4 进阶请求：参数、路径、请求体、状态码](#ch3-4)
    - [3.4.1 查询参数：URL 里 `?` 后面的部分](#ch3-4-1)
    - [3.4.2 嵌套路径：用 URL 层级表达父子关系](#ch3-4-2)
    - [3.4.3 请求体：第一次让“信”里装上内容](#ch3-4-3)
    - [3.4.4 其他方法：PUT、PATCH、DELETE](#ch3-4-4)
    - [3.4.5 状态码不只是 200：亲手触发错误](#ch3-4-5)
    - [3.4.6 httpbin 回显：服务器到底收到了什么](#ch3-4-6)
    - [3.4.7 ⚠️ 必须提醒学生：jsonplaceholder 是“假”的写入](#ch3-4-7)
    - [3.4.8 小结：三种复杂度对照](#ch3-4-8)
- [第四章 用 FastAPI 写一个自己的后端](#ch4)
  - [4.1 安装依赖](#ch4-1)
  - [4.2 编写后端](#ch4-2)
  - [4.3 启动服务器](#ch4-3)
  - [4.4 用前面三个工具请求自己的后端](#ch4-4)
  - [4.5 课堂彩蛋：FastAPI 自动文档](#ch4-5)
  - [4.6 再看 `/whoami`：我们自己的“httpbin”](#ch4-6)
- [第五章 用三种方式操作 MySQL 数据库](#ch5)
  - [5.0 课前确认：MySQL 服务状态](#ch5-0)
  - [5.1 第一阶段：PowerShell 直连 MySQL](#ch5-1)
  - [5.2 第二阶段：VSCode + MySQL 扩展](#ch5-2)
  - [5.3 第三阶段：Python + PyMySQL](#ch5-3)
- [附录 A 三工具对照速查表](#appendix-a)
  - [A.1 HTTP 请求与响应（前三章）](#a1)
  - [A.2 客户端 vs 服务端（第四章）](#a2)
  - [A.3 操作数据库三阶段（第五章）](#a3)
  - [A.4 本项目文件清单](#a4)
- [附录 B 常见问题排查](#appendix-b)
- [结语](#conclusion)

---

<a id="pre"></a>

## 开始之前

<a id="pre-env"></a>

### 环境与约定

- 操作系统：Windows 11
- 终端：PowerShell（VSCode 终端或 Windows 终端均可）
- Python 已安装，使用 **uv** 管理虚拟环境
- MySQL 8 已安装，root 账号密码已设置，服务已启动
- 课堂可联网

<a id="pre-url"></a>

### 贯穿全程的测试地址

```
https://jsonplaceholder.typicode.com/posts/1
```

这是一个免费的假数据接口，结构十几年没变过，返回一条固定格式的 JSON。**本讲义凡出现“那个地址”，都指它。**

<a id="pre-folder"></a>

### 项目文件夹与终端

在桌面新建文件夹，例如 `api-demo`，用 VSCode 的 **“文件 → 打开文件夹”** 打开它。

VSCode 中打开终端：菜单 **终端 → 新建终端**，快捷键 <kbd>Ctrl</kbd> + <kbd>`</kbd>。确认终端类型是 **PowerShell**。

<a id="pre-uv"></a>

### uv 的用法约定

本讲义统一用：

```powershell
uv run 文件名.py
```

启动脚本，**不需要手动激活虚拟环境**。需要第三方库时用：

```powershell
uv add 包名
```

本项目会依次添加：

```powershell
uv add requests
uv add fastapi uvicorn
uv add pymysql
```

<a id="pre-curl"></a>

### ⚠️ Windows 上的第一个坑：curl 不是 curl

在 Windows 11 自带的 **PowerShell 5.1** 中，`curl` 是一个内置别名，指向 `Invoke-WebRequest`，**不是真正的 curl 程序**。学生直接敲 `curl https://...` 得到的输出会和网上教程对不上。

**解决办法：全程写 `curl.exe`，带 `.exe` 后缀。**

> PowerShell 7 中该别名已移除，但为了课堂统一，本讲义一律用 `curl.exe`。

---

<a id="ch1"></a>

## 第一章 用 PowerShell + curl 感受网络请求

**本章目标**：建立“我发出一个请求，服务器回给我一段数据”的直觉，然后亲眼看到请求与响应的内部结构。

<a id="ch1-1"></a>

### 1.1 只看响应结果

在 PowerShell 中输入：

```powershell
curl.exe https://jsonplaceholder.typicode.com/posts/1
```

会直接看到：

```json
{
  "userId": 1,
  "id": 1,
  "title": "sunt aut facere repellat provident occaecati excepturi optio reprehenderit",
  "body": "quia et suscipit\nsuscipit recusandae consequuntur expedita et cum\n..."
}
```

**讲解要点**

- 你刚才做的事和浏览器打开网页本质一样：**向一个地址发出请求，服务器把数据塞回来**。
- `{ ... }` 这种格式叫 **JSON**，是 API 和前后端之间最常用的数据格式。
- 这一步只看到了**结果**，没看到**过程**。

<a id="ch1-2"></a>

### 1.2 用 `-v` 看清全过程

```powershell
curl.exe -v https://jsonplaceholder.typicode.com/posts/1
```

输出较长，**按行首符号分类看**即可：

| 行首符号 | 含义 | 比喻 |
|---|---|---|
| `*` | 连接/传输层信息（拨号、TLS 握手） | 电话拨通的过程 |
| `>` | **你发出的请求**（请求行 + 请求头） | 你寄出去的信 |
| `<` | **服务器的响应**（状态行 + 响应头） | 对方回的信 |
| 无符号 | **响应体**（就是 1.1 那段 JSON） | 信封里的内容 |

典型输出中重点看这几行：

```text
> GET /posts/1 HTTP/1.1
> Host: jsonplaceholder.typicode.com
> User-Agent: curl/8.x.x
> Accept: */*

< HTTP/1.1 200 OK
< Content-Type: application/json; charset=utf-8
```

**逐行讲解**

- `> GET /posts/1 HTTP/1.1`：**请求行**。`GET` 是“我要拿东西”的方法，`/posts/1` 是要的资源，`HTTP/1.1` 是协议版本。
- `> Host:`、`> User-Agent:` 等：**请求头**。`Host` 说“我找哪个网站”，`User-Agent` 说“我是用 curl 来的”。
- `< HTTP/1.1 200 OK`：**状态行**。`200` 表示“请求成功，东西给你了”。
- `< Content-Type: application/json`：**响应头**，告诉客户端“内容是 JSON”。
- 最后那段 `{ ... }`：**响应体**，与 1.1 完全一致。`-v` 只是把信封和邮戳也翻给你看。

---

<a id="ch2"></a>

## 第二章 用浏览器看请求与响应

**本章目标**：证明浏览器和 curl 发出的东西**本质相同**，只是工具不同。

<a id="ch2-1"></a>

### 2.1 地址栏直接访问

浏览器（Edge 或 Chrome）地址栏输入同一地址并回车：

```
https://jsonplaceholder.typicode.com/posts/1
```

页面会显示与 `curl.exe` 输出**一模一样**的 JSON。浏览器只是把文字画到页面上。

<a id="ch2-2"></a>

### 2.2 按 F12 看过程

1. 按 <kbd>F12</kbd> 打开开发者工具。
2. 切到 **“网络”（Network）** 标签。
3. **按 <kbd>Ctrl</kbd> + <kbd>R</kbd> 刷新页面**（这一步不能省，否则列表可能是空的）。
4. 列表里点击名为 `1` 或 `posts/1` 的请求。

右侧看两个标签页就够：

**① “标头”（Headers）** —— 对应 `curl.exe -v` 的输出：

| 浏览器区块 | 对应 curl | 例子 |
|---|---|---|
| 常规 → 请求 URL | `> GET /posts/1 HTTP/1.1` | 方法 `GET`，路径 `/posts/1` |
| 请求标头 | `>` 开头的行 | `User-Agent`、`Accept`、`Host` |
| 响应标头 | `<` 开头的行 | `200 OK`、`Content-Type: application/json` |

**② “响应”（Response）** —— 对应响应体，和 1.1 的 JSON 相同。

<a id="ch2-3"></a>

### 2.3 找出唯一明显不同：`User-Agent`

- 浏览器请求标头里：`User-Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) ... Edg/xxx`
- `curl.exe -v` 的 `>` 区里：`> User-Agent: curl/8.x.x`

> **关键结论**：同一地址、同一方法、同一响应体，唯一区别是 **`User-Agent` 自报家门不同**。服务器不关心你用什么工具来，只关心**请求格式对不对**。浏览器和 PowerShell 没有本质区别，都只是“客户端”。

---

<a id="ch3"></a>

## 第三章 用 Python 代码发请求

**本章目标**：让 Python 代替手工工具去拼请求、拆响应。学生将看到代码与前面手工操作一一对应。

<a id="ch3-1"></a>

### 3.1 初始化项目

在 `api-demo` 文件夹的终端中：

```powershell
uv init
uv add requests
```

- `uv init` 生成 `pyproject.toml` 等基础文件。
- `requests` 是 Python 中最常用的 HTTP 客户端库。

<a id="ch3-2"></a>

### 3.2 脚本一：打印响应

新建 `request_demo.py`：

```python
import requests

# 和前面 curl / 浏览器用的是同一个地址
url = "https://jsonplaceholder.typicode.com/posts/1"

# 发请求：请求发出去，服务器回来后，结果存进 response
response = requests.get(url)

# 先看“信封”：状态码
print("状态码:", response.status_code)

# 再看响应头里的 Content-Type
print("Content-Type:", response.headers["Content-Type"])

print()

# 最后看“信纸内容”：响应体
print("响应体:")
print(response.text)
```

运行：

```powershell
uv run request_demo.py
```

输出：

```text
状态码: 200
Content-Type: application/json; charset=utf-8

响应体:
{
  "userId": 1,
  "id": 1,
  ...
}
```

**代码与 curl 的对应关系**

| Python | curl -v 中的位置 |
|---|---|
| `requests.get(url)` | 整条 `curl.exe -v URL` 命令 |
| `response.status_code` | `< HTTP/1.1 200 OK` 里的 `200` |
| `response.headers` | `<` 开头的所有行 |
| `response.text` | 终端最后那段 JSON |

<a id="ch3-3"></a>

### 3.3 脚本二：让 Python 报出自己的名字

用 `https://httpbin.org/headers`，它会把收到的请求头原样返回，当镜子用。

新建 `headers_demo.py`：

```python
import requests

url = "https://httpbin.org/headers"

# 自定义请求头，告诉服务器“我是谁”
headers = {
    "User-Agent": "我的Python脚本/1.0"
}

response = requests.get(url, headers=headers)

print("状态码:", response.status_code)
print("服务器看到的我的请求头:")
print(response.text)
```

运行：

```powershell
uv run headers_demo.py
```

输出类似：

```json
{
  "headers": {
    "Accept": "*/*",
    "Accept-Encoding": "gzip, deflate",
    "Host": "httpbin.org",
    "User-Agent": "我的Python脚本/1.0"
  }
}
```

**讲解要点**

- `User-Agent` 变成了我们设置的值。对比：浏览器报 `Mozilla/...`，curl 报 `curl/...`，Python 报 `我的Python脚本`。**工具不同，名字不同，请求格式完全一样。**
- `headers={...}` 参数让我们能**在发请求时附加请求头**，这是 curl 命令行不容易做到的，代码可以随意控制。

> **备用方案**：如果课堂上 `httpbin.org` 打不开，换回 `https://jsonplaceholder.typicode.com/posts/1`，只是看不到回显请求头，状态码和响应体照样能演示。

<a id="ch3-4"></a>

### 3.4 进阶请求：参数、路径、请求体、状态码

前面 3.1～3.3 都是 `GET` 一个固定地址。真实世界的 API 更丰富：可以带**查询参数**、可以走**多层路径**、可以**带请求体**，返回的**状态码**也不都是 `200`。这一节逐个补上。

> **本节读法**：每条命令先用 `curl.exe` 跑一遍看到结果，再用 Python 跑一遍。两边对照，你会发现只是“换了个工具发同一个请求”。

<a id="ch3-4-1"></a>

#### 3.4.1 查询参数：URL 里 `?` 后面的部分

```powershell
curl.exe "https://jsonplaceholder.typicode.com/posts?userId=1"
```

返回的是一个**数组**（`[ ... ]`），里面每一条的 `userId` 都是 1。对比 `/posts/1` 返回单条对象——`?userId=1` 是“按条件筛选一批”。

**讲解要点**

- `?` 后面是查询参数，格式是 `键=值`；多个参数用 `&` 连接，比如 `?userId=1&id=2`。
- **PowerShell 里 URL 含 `&` 时必须加引号**，否则 `&` 会被 PowerShell 当成命令连接符。养成习惯：带参数的 URL 一律用双引号包起来。
- 查询参数不是路径的一部分，它不改变“你要哪个资源”，而是“你要这个资源的哪种筛选结果”。

**Python 写法（推荐用 `params` 参数，不要手拼 URL）**

新建 `params_demo.py`：

```python
import requests

url = "https://jsonplaceholder.typicode.com/posts"

# 把参数写成字典，requests 自动拼成 ?userId=1 并做 URL 编码
response = requests.get(url, params={"userId": 1})

print("状态码:", response.status_code)
print("实际请求的地址:", response.url)

# response.json() 把响应体那串 JSON 文本解析成 Python 的列表/字典
data = response.json()
print("返回条数:", len(data))
print("第一条:", data[0])
```

运行：

```powershell
uv run params_demo.py
```

会看到 `response.url` 自动变成了 `...posts?userId=1`。

> **新方法说明**：`response.json()` 把响应体文本**解析**成 Python 的列表或字典。前面用的 `response.text` 是原始字符串，`response.json()` 是解析后的结构，方便直接用 `data[0]["title"]` 取值。

<a id="ch3-4-2"></a>

#### 3.4.2 嵌套路径：用 URL 层级表达父子关系

```powershell
curl.exe "https://jsonplaceholder.typicode.com/posts/1/comments"
```

返回“第 1 篇文章下面的所有评论”。URL 路径的层级直接表达了数据之间的**父子关系**：`/posts` → 某一篇 `/posts/1` → 它的评论 `/posts/1/comments`。这是 REST 风格 API 的典型设计。

**讲解要点**

- 路径的每一段都是一层“缩小范围”。
- 浏览器里直接打开这个地址也能看到同样的数组——**浏览器和 curl 再次证明是一回事**。

<a id="ch3-4-3"></a>

#### 3.4.3 请求体：第一次让“信”里装上内容

前面所有请求都只有“信封”（请求行 + 请求头），没有“信纸内容”（请求体）。发请求体最典型的方法是 `POST`。

**⚠️ PowerShell 里发 JSON 请求体的引号坑**

在 PowerShell 5.1 里，**直接把 JSON 写在命令行参数里，双引号很容易被吞掉或变形**，导致服务器收到非法 JSON。小白排查这种问题非常痛苦。**最稳妥的做法：把请求体写进文件，用 `@文件名` 让 curl 去读。**

**第一步**：在 `api-demo` 文件夹里新建 `body.json`，内容就一行（**JSON 里必须用双引号**）：

```json
{"title": "课堂测试", "body": "你好，这是请求体", "userId": 1}
```

**第二步**：在 PowerShell 中执行：

```powershell
curl.exe -X POST "https://jsonplaceholder.typicode.com/posts" -H "Content-Type: application/json" -d "@body.json"
```

**会看到**：服务器把收到的数据再加上一个 `id: 101` 原样返回，`-v` 模式下还能看到状态行变成了：

```text
< HTTP/1.1 201 Created
```

**三个新参数逐个讲**

| 参数 | 作用 | 类比 |
|---|---|---|
| `-X POST` | 指定**请求方法**为 POST（默认是 GET） | 信封上写“这是新投稿” |
| `-H "Content-Type: application/json"` | 告诉服务器“**请求体是 JSON 格式**” | 信封上注明“内附 JSON” |
| `-d "@body.json"` | **携带请求体**，从文件读取 | 把信纸装进信封 |

**讲解要点**

- `Content-Type` 这个请求头，正是前面在**响应**里见过的那个 `Content-Type` 的“请求版”——它告诉服务器“我发给你的是什么格式”。
- `@文件名` 是 curl 的语法：`@` 表示“从这个文件读取内容作为请求体”。用文件还有个好处：请求体能写多行、能保存、能复用。
- **状态码 `201 Created`** 表示“新建成功”。这和 `200 OK` 不一样，是 HTTP 语义的一部分，不是错误。

**Python 写法**

新建 `post_demo.py`：

```python
import requests

url = "https://jsonplaceholder.typicode.com/posts"

# 请求体写成 Python 字典
payload = {"title": "课堂测试", "body": "你好，这是请求体", "userId": 1}

# json=payload 会自动做两件事：转成 JSON 字符串 + 加上 Content-Type: application/json
response = requests.post(url, json=payload)

print("状态码:", response.status_code)   # 预期 201
print("响应体:", response.text)
```

运行：

```powershell
uv run post_demo.py
```

> `requests.post(url, json=payload)` 里的 `json=` 参数，等价于 curl 的 `-H "Content-Type: application/json"` + `-d "@body.json"` **两件事一起做**。Python 里不用操心引号转义，这也是用代码发请求比命令行省心的地方。

<a id="ch3-4-4"></a>

#### 3.4.4 其他方法：PUT、PATCH、DELETE

`POST` 之外，还有三个常用的“修改类”方法。都用同一个 `body.json`：

```powershell
# PUT：整体替换。把第 1 篇文章的内容整个换掉
curl.exe -X PUT "https://jsonplaceholder.typicode.com/posts/1" -H "Content-Type: application/json" -d "@body.json"

# PATCH：局部更新。只改其中一部分字段
curl.exe -X PATCH "https://jsonplaceholder.typicode.com/posts/1" -H "Content-Type: application/json" -d "@body.json"

# DELETE：删除。返回 204 No Content，响应体是空的
curl.exe -X DELETE "https://jsonplaceholder.typicode.com/posts/1"
```

**讲解要点**

- **PUT 与 PATCH 的区别**：PUT 是“整份替换”，你没传的字段可能被清空；PATCH 是“打补丁”，只改你传的字段。这是面试常问、也是真实后端设计里要慎重选择的点。
- **DELETE 返回 `204 No Content`**：状态码表示“删成功了，但没有内容要给你”，所以响应体是空的。这又是一个“状态码不一定是 200”的例子。

<a id="ch3-4-5"></a>

#### 3.4.5 状态码不只是 200：亲手触发错误

用 `httpbin.org/status/{code}` 可以让服务器**故意**返回任意状态码：

```powershell
curl.exe "https://httpbin.org/status/404"
curl.exe "https://httpbin.org/status/500"
```

屏幕上会直接显示对应状态码。**这是让学生亲手看到非 2xx 响应最可靠的方式**，比等一个真实 API 出故障靠谱得多。

**状态码分类（板书写这三行就够）**

| 范围 | 含义 | 常见例子 |
|---|---|---|
| **2xx** | 成功 | `200 OK`、`201 Created`、`204 No Content` |
| **4xx** | **你**（客户端）的问题 | `404 Not Found`、`400 Bad Request`、`401 Unauthorized` |
| **5xx** | **服务器**的问题 | `500 Internal Server Error` |

**Python 里怎么判断**

```python
import requests

response = requests.get("https://httpbin.org/status/404")
print("状态码:", response.status_code)

if response.status_code == 200:
    print("成功，可以放心用响应体")
else:
    print("出错了，状态码是", response.status_code)
```

> **重要**：`requests` 默认**不会**因为 4xx / 5xx 抛异常，`response.status_code` 照常能拿到。所以真实项目里**必须自己检查状态码**，不能拿到响应就假设成功。

<a id="ch3-4-6"></a>

#### 3.4.6 httpbin 回显：服务器到底收到了什么

httpbin.org 是个“**请求回声服务**”：你发什么，它把收到的**查询参数、请求头、请求体**原样整理成 JSON 返回。它特别适合回答“服务器实际收到了什么”这个小白最困惑的问题。

**① 回显查询参数**

```powershell
curl.exe "https://httpbin.org/get?tool=curl&lesson=api"
```

返回的 JSON 里有一个 `args` 字段，原样列出你传的参数：

```json
{
  "args": {
    "lesson": "api",
    "tool": "curl"
  },
  ...
}
```

能**亲眼看到** `?` 后面的东西被服务器解析成了键值对。

**② 回显请求体**

```powershell
curl.exe -X POST "https://httpbin.org/post" -H "Content-Type: application/json" -d "@body.json"
```

返回的 JSON 里包含一个 `json` 字段，就是你发过去的请求体内容。

> **价值**：`POST /posts` 看到“客户端发出了请求体，服务器返回 201”；`POST httpbin.org/post` 看到“**服务器收到的请求体具体长什么样**”。两个合在一起，“请求体从发出到被接收”的闭环就走完了。

<a id="ch3-4-7"></a>

#### 3.4.7 ⚠️ 提醒：jsonplaceholder 是“假”的写入

**jsonplaceholder 的所有写入操作（POST / PUT / PATCH / DELETE）都会返回看起来很真实的响应，但数据不会真正保存。**

验证方法：执行完 POST 之后，重新访问 `https://jsonplaceholder.typicode.com/posts/1`，第 1 篇文章**还是原来的内容**。

> **课堂说法**：jsonplaceholder 模拟的是服务器的“**行为**”，不模拟服务器的“**记忆**”。它只会配合你演一遍，不会真的存东西。想体验真的存下来，就得用第五章的 MySQL 自己搭一个后端。

<a id="ch3-4-8"></a>

#### 3.4.8 小结：三种复杂度对照

| 复杂度 | 请求形态 | 例子 | 新出现的概念 |
|---|---|---|---|
| 简单 | `GET /posts/1` | 3.1～3.3 | 方法、路径、头、状态码、响应体 |
| 中等 | `GET /posts?userId=1`<br>`GET /posts/1/comments` | 3.4.1、3.4.2 | **查询参数**、**嵌套路径** |
| 复杂 | `POST /posts` + 请求体 | 3.4.3～3.4.6 | **请求体**、`Content-Type`、`201/204` 状态码、`PUT/PATCH/DELETE` |

**本节新增文件清单**

| 文件 | 作用 |
|---|---|
| `body.json` | 请求体文件，curl 用 `@body.json` 读取 |
| `params_demo.py` | 演示查询参数（`params=`）和 `response.json()` |
| `post_demo.py` | 演示 POST 请求体（`json=`）和 201 状态码 |

**本节收束**

> 到这里，HTTP 请求的四个组成部分你全部见过了：**方法、路径（含查询参数）、请求头、请求体**；响应也见过全部三部分：**状态码、响应头、响应体**。真实 API 无论多复杂，都是这七样东西的组合。下一章我们站到服务器那一侧，亲手接住这些请求。

---

<a id="ch4"></a>

## 第四章 用 FastAPI 写一个自己的后端

**本章目标**：站到服务器那一侧，第一次“接住”别人发来的请求。这是前面所有内容的反面，形成闭环。

> **概念**：FastAPI 不是用来“发起”请求的，它是用来“接住”请求并“返回”响应的**后端框架**。前面你在打电话，这一章你第一次接电话。

<a id="ch4-1"></a>

### 4.1 安装依赖

在 `api-demo` 文件夹终端中：

```powershell
uv add fastapi uvicorn
```

- `fastapi`：后端框架本身。
- `uvicorn`：启动服务器用的“发动机”。

<a id="ch4-2"></a>

### 4.2 编写后端

新建 `main.py`：

```python
from fastapi import FastAPI, Request

app = FastAPI()


# 根路径：访问 http://127.0.0.1:8000 时触发
@app.get("/")
def read_root():
    return {"message": "你好，我是你写的第一个后端！"}


# 故意模仿 jsonplaceholder 的返回结构，方便对照
@app.get("/posts/1")
def read_post():
    return {
        "userId": 1,
        "id": 1,
        "title": "这条数据是我自己的服务器返回的",
        "body": "前面那些请求都发给了别人的服务器，这次是发给我自己"
    }


# 当镜子用：把客户端发来的请求头原样返回
@app.get("/whoami")
def whoami(request: Request):
    return {
        "你用的方法": request.method,
        "你访问的路径": request.url.path,
        "你带来的请求头": dict(request.headers)
    }
```

<a id="ch4-3"></a>

### 4.3 启动服务器

```powershell
uv run uvicorn main:app --reload
```

看到：

```text
INFO:     Uvicorn running on http://127.0.0.1:8000 (Press CTRL+C to quit)
```

### ⚠️ 课堂最容易卡住的三个点

1. **终端“卡住”不动是正常的**——服务器正在运行，日志会持续滚动。
2. **不要关掉这个终端**，关了服务器就死了。
3. **发请求要另开一个终端**（或用浏览器）。想停服务器：在此终端按 <kbd>Ctrl</kbd> + <kbd>C</kbd>。

<a id="ch4-4"></a>

### 4.4 用前面三个工具请求自己的后端

**① 浏览器**

```
http://127.0.0.1:8000/posts/1
```

显示：

```json
{"userId":1,"id":1,"title":"这条数据是我自己的服务器返回的","body":"..."}
```

**② PowerShell `curl.exe -v`（另开终端）**

```powershell
curl.exe -v http://127.0.0.1:8000/posts/1
```

输出里依然有熟悉的 `> GET /posts/1 HTTP/1.1`、`< HTTP/1.1 200 OK`、`< Content-Type: application/json`。**结构和请求 jsonplaceholder 时完全一样，只是服务器换成了自己的。**

**③ Python requests**

新建 `client.py`（注意：不要覆盖 `main.py`，服务器还在用）：

```python
import requests

response = requests.get("http://127.0.0.1:8000/posts/1")
print("状态码:", response.status_code)
print("Content-Type:", response.headers["Content-Type"])
print("响应体:", response.text)
```

运行：

```powershell
uv run client.py
```

**讲解要点**

- 前面 `requests.get` 请求的是公网地址，现在请求的是 `http://127.0.0.1:8000`。
- `127.0.0.1` 是“本机”，`8000` 是启动服务器时用的端口。
- **请求格式、响应格式一个字都没变。** 你从“消费者”变成了“生产者”。

<a id="ch4-5"></a>

### 4.5 课堂彩蛋：FastAPI 自动文档

浏览器访问：

```
http://127.0.0.1:8000/docs
```

会看到自动生成的交互式 API 文档，列出三个接口，点 **“Try it out” → “Execute”** 即可在页面里直接发请求、看响应。

> FastAPI 根据你写的 Python 函数，**自动生成了文档和测试工具**。你管业务逻辑，格式和文档它替你干——这就是后端框架的价值之一。

<a id="ch4-6"></a>

### 4.6 再看 `/whoami`：我们自己的“httpbin”

访问：

```
http://127.0.0.1:8000/whoami
```

分别用 `curl.exe` 和浏览器访问，对比返回里的 `user-agent`：

- curl 访问 → `"user-agent": "curl/8.x.x"`
- 浏览器访问 → `"user-agent": "Mozilla/5.0 ... Edg/xxx"`

> 前面请求 `httpbin.org/headers` 时是别人在回显我们的请求头；现在 `/whoami` 是**我们自己写的代码**在回显。一边是“用”，一边是“造”。

---

<a id="ch5"></a>

## 第五章 用三种方式操作 MySQL 数据库

**本章目标**：同一个数据库、同一张表、同一批数据，依次用 PowerShell、VSCode、Python 去操作，体会三种工具的差别与联系。

<a id="ch5-0"></a>

### 5.0 课前确认：MySQL 服务状态

PowerShell 中查服务（不需要管理员权限）：

```powershell
Get-Service -DisplayName "MySQL*"
```

输出里 `Name` 列就是服务名（通常是 `MySQL80`）。确认 `Status` 是 `Running`。

> 课堂不需要启动服务。若将来需要手动启停，**需管理员 PowerShell**：
>
> ```powershell
> Start-Service -Name MySQL80
> Stop-Service  -Name MySQL80
> ```

<a id="ch5-1"></a>

### 5.1 第一阶段：PowerShell 直连 MySQL

**目标**：最原始的方式——手敲 SQL，立刻看到表格结果。

**① 登录**

```powershell
mysql -u root -p
```

回车后输入 root 密码。**输入时屏幕不显示字符，这是正常的，不是卡住。**

成功出现：

```text
mysql>
```

**② 建库、选库、建表**（逐句输入）

```sql
CREATE DATABASE school;
USE school;
```

```sql
CREATE TABLE students (
    id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(50),
    age INT
);
```

**③ 插入与查询**

```sql
INSERT INTO students (name, age) VALUES ('小明', 18);
INSERT INTO students (name, age) VALUES ('小红', 19);
```

```sql
SELECT * FROM students;
```

看到：

```text
+----+--------+------+
| id | name   | age  |
+----+--------+------+
|  1 | 小明   |   18 |
|  2 | 小红   |   19 |
+----+--------+------+
```

**④ 退出**

```sql
exit;
```

**讲解要点**

- SQL 语句结尾的**分号 `;` 不能丢**，表示“这句话说完了”。
- `id` 没给值，因为建表时写了 `AUTO_INCREMENT`，MySQL 自动编号。
- `SELECT *` 里的 `*` 表示“所有列”。
- 这一阶段和第一章用 `curl.exe` 发请求本质一样：**你发出请求（一句 SQL），服务器回给你响应（一张结果表）**。

<a id="ch5-2"></a>

### 5.2 第二阶段：VSCode + MySQL 扩展

**目标**：把 SQL 写成文件保存下来、反复执行，并用图形界面看结果。

**① 安装扩展**

VSCode 左侧 **扩展**（<kbd>Ctrl</kbd>+<kbd>Shift</kbd>+<kbd>X</kbd>）→ 搜索 **MySQL** → 安装 **MySQL Shell for VS Code**（Oracle 官方）。安装后左侧出现 MySQL 图标。

**② 建立连接**

点击 MySQL 图标 → **`+ New Connection`**，填写：

| 字段 | 值 |
|---|---|
| Caption | `本地school`（随意） |
| Host Name | `localhost` 或 `127.0.0.1` |
| Port | `3306` |
| Username | `root` |
| Password | root 密码 |

点 OK 保存，再点击该连接连上。

**③ 浏览数据**

展开连接 → `school` 数据库 → `students` 表，点击表名预览数据。

**④ 写 SQL 文件并执行**

新建 `demo.sql`：

```sql
USE school;

INSERT INTO students (name, age) VALUES ('小刚', 20);

SELECT * FROM students;
```

选中要执行的语句，右键运行（或在 MySQL 面板中执行）。结果以表格显示在下方。

**讲解要点**

- 和第一阶段敲的是**一模一样的 SQL**，区别在于现在是**文件里的文字**，可以保存、修改、反复运行。
- 真实项目里，建表和初始化数据通常放在 `.sql` 文件里，而不是每次手敲。
- 执行后应该看到小明、小红、小刚三行——**第一阶段的数据还在**，三个阶段操作的是同一个库。

<a id="ch5-3"></a>

### 5.3 第三阶段：Python + PyMySQL

**目标**：让代码替你去执行 SQL，为将来“后端读数据库”打基础。

**① 安装库**

```powershell
uv add pymysql
```

> `PyMySQL` 是纯 Python 写的 MySQL 客户端，轻量、安装简单。

**② 脚本一：查询数据**

新建 `db_query.py`：

```python
import pymysql

# 建立连接：告诉 Python 数据库在哪里、用什么身份进
connection = pymysql.connect(
    host="localhost",
    user="root",
    password="你的root密码",   # ← 改成自己设置的密码
    database="school",
    port=3306,
    charset="utf8mb4"
)

# 游标：用来执行 SQL 和取结果的对象
cursor = connection.cursor()

# 执行 SQL
cursor.execute("SELECT * FROM students")

# 取回所有行
rows = cursor.fetchall()
print("查询结果：")
for row in rows:
    print(row)

cursor.close()
connection.close()
```

运行：

```powershell
uv run db_query.py
```

输出类似：

```text
查询结果：
(1, '小明', 18)
(2, '小红', 19)
(3, '小刚', 20)
```

**代码与前面阶段的对应关系**

| Python | 对应的手工操作 |
|---|---|
| `pymysql.connect(...)` | `mysql -u root -p` + 输密码 |
| `connection.cursor()` | 出现 `mysql>` 提示符，准备输入 |
| `cursor.execute("SELECT ...")` | 在 `mysql>` 里敲 SQL |
| `cursor.fetchall()` | 终端里显示的结果表格 |

**③ 脚本二：插入数据（重点理解 `commit`）**

新建 `db_modify.py`：

```python
import pymysql

connection = pymysql.connect(
    host="localhost", user="root", password="你的root密码",
    database="school", port=3306, charset="utf8mb4"
)
cursor = connection.cursor()

# 插入一行（用占位符传值，不要字符串拼接）
cursor.execute(
    "INSERT INTO students (name, age) VALUES (%s, %s)",
    ("小丽", 21)
)

# 关键一步：提交
connection.commit()
print("插入完成，提交成功")

cursor.close()
connection.close()
```

运行后去 VSCode 的 MySQL 扩展里重新执行 `SELECT * FROM students;`，能看到 `小丽`。

> **⚠️ 必须理解 `commit`**：PyMySQL **默认不自动提交**。执行 `INSERT` / `UPDATE` / `DELETE` 后必须调用 `connection.commit()`，数据才真正写进数据库；不写，程序关掉后改动就丢了。  
> 比喻：你在草稿纸上写了，但没按“提交”按钮，数据库不认。

**④ 脚本三：更新和删除**

```python
# 更新：把“小丽”的年龄改成 22
cursor.execute(
    "UPDATE students SET age = %s WHERE name = %s",
    (22, "小丽")
)
connection.commit()

# 删除：删掉“小刚”
cursor.execute("DELETE FROM students WHERE name = %s", ("小刚",))
connection.commit()
```

**讲解要点**

- `%s` 是**占位符**，真正的值作为第二个参数传进去。**不要用字符串拼接**，否则有 SQL 注入风险——从现在开始养成这个安全习惯。
- 所有**修改数据**的语句后面都要 `connection.commit()`。
- `WHERE` 是筛选条件；**没有 `WHERE` 的 `DELETE` 会删掉整张表**。

**⑤ 和第四章的连接**

> 真实的后端不会把数据写死在代码里。你们现在会 `SELECT` 了，下一步就可以在 FastAPI 的接口里查 `students` 表，把结果返回给客户端。  
> **请求 → 后端 → 数据库 → 响应**，这条链路的每一段你们都已经碰过了。

---

<a id="appendix-a"></a>

## 附录 A 三工具对照速查表

<a id="a1"></a>

### A.1 HTTP 请求与响应（前三章）

| 环节 | curl.exe -v | 浏览器 F12 | Python requests |
|---|---|---|---|
| 发请求 | `curl.exe -v URL` | 地址栏回车 | `requests.get(url)` |
| 方法 | `> GET` | 常规 → 请求方法 | 由 `get`/`post` 等方法决定 |
| 状态码 | `< HTTP/1.1 200 OK` | 标头 → 状态码 | `response.status_code` |
| 响应头 | `<` 开头的行 | 标头 → 响应标头 | `response.headers` |
| 响应体 | 终端最后的 JSON | 响应标签 | `response.text` |
| 自定义请求头 | `-H "User-Agent: ..."` | 浏览器自动带 | `headers={...}` |
| 查询参数 | URL 里直接写 `?k=v` | 标头 → 请求 URL | `requests.get(url, params={...})` |
| 请求体 | `-d "@body.json"` | 标头 → 请求负载 | `requests.post(url, json={...})` |

<a id="a2"></a>

### A.2 客户端 vs 服务端（第四章）

| 角色 | 工具 | 代码/操作 | 说明 |
|---|---|---|---|
| 客户端 | PowerShell | `curl.exe -v URL` | 手动发 |
| 客户端 | 浏览器 | 地址栏 / F12 | 自动发 |
| 客户端 | Python | `requests.get(url)` | 代码发 |
| **服务端** | **FastAPI** | `@app.get("/posts/1")` | **代码收** |

<a id="a3"></a>

### A.3 操作数据库三阶段（第五章）

| 阶段 | 工具 | 怎么发指令 | 怎么看结果 | 核心感受 |
|---|---|---|---|---|
| 一 | PowerShell `mysql>` | 手敲 SQL | 终端表格 | 直接、原始 |
| 二 | VSCode + MySQL 扩展 | 写在 `.sql` 文件 | 图形化表格 | 可保存、可重复 |
| 三 | Python + PyMySQL | 写在 `.py` 里 | `print` / 变量 | 可编程、可集成 |

<a id="a4"></a>

### A.4 本项目文件清单

| 文件 | 所属章节 | 作用 |
|---|---|---|
| `request_demo.py` | 3.2 | 打印响应（状态码/头/体） |
| `headers_demo.py` | 3.3 | 自定义请求头并回显 |
| `body.json` | 3.4.3 | 请求体文件，curl 用 `@body.json` 读取 |
| `params_demo.py` | 3.4.1 | 演示查询参数与 `response.json()` |
| `post_demo.py` | 3.4.3 | 演示 POST 请求体与 201 状态码 |
| `main.py` | 4.2 | FastAPI 后端（服务端） |
| `client.py` | 4.4 | 用 requests 请求自己的后端 |
| `demo.sql` | 5.2 | VSCode 里执行的 SQL 文件 |
| `db_query.py` | 5.3 | Python 查询数据库 |
| `db_modify.py` | 5.3 | Python 增删改数据库（含 commit） |

---

<a id="appendix-b"></a>

## 附录 B 常见问题排查

| 现象 | 原因 | 解决 |
|---|---|---|
| `curl` 输出格式不对 | PowerShell 5.1 里 `curl` 是别名 | 改用 `curl.exe` |
| F12 网络面板是空的 | 打开面板后没刷新 | 按 <kbd>Ctrl</kbd>+<kbd>R</kbd> 刷新 |
| `uvicorn` 终端“卡住” | 正常，服务器在运行 | 别关它；停服务按 <kbd>Ctrl</kbd>+<kbd>C</kbd> |
| `127.0.0.1:8000` 打不开 | 服务器终端被关了 | 重新 `uv run uvicorn main:app --reload` |
| `httpbin.org` 超时 | 网络波动 | 换用 jsonplaceholder 地址 |
| `mysql` 不是内部或外部命令 | MySQL `bin` 目录未加入 PATH | 用完整路径，或把 `C:\Program Files\MySQL\MySQL Server 8.0\bin` 加入 PATH |
| `Access denied for user 'root'` | 密码错误，或 `-p` 后多打了字符 | `-p` 后**不要**直接跟密码，回车后再输 |
| PyMySQL 报 `Can't connect to MySQL server` | MySQL 服务没运行 | `Get-Service -DisplayName "MySQL*"` 检查；需时用管理员 PowerShell `Start-Service -Name MySQL80` |
| Python 插入后查不到 | 忘了 `connection.commit()` | 修改类语句后必须 commit |
| 中文乱码 | 字符集不一致 | 连接时加 `charset="utf8mb4"`，建库建表统一用该字符集 |
| curl 发 POST 报 JSON 解析错误 | PowerShell 5.1 吞掉了命令行里的双引号 | 把请求体写进 `body.json`，用 `-d "@body.json"` |
| POST 之后查不到新数据 | jsonplaceholder 是假写入，不保存 | 属正常现象，真实存储见第五章 |
| `response.json()` 报错 | 响应体不是 JSON（可能是错误页） | 先打印 `response.status_code` 和 `response.text` 判断 |

---

<a id="conclusion"></a>

## 结语

五章下来，同一条链路你从两头都走过了：

> **请求（方法 + 路径 + 头 + 体） → 服务器处理 → 响应（状态码 + 头 + 体）**

- 第一到三章，你是**发请求的人**：curl 手动拼、浏览器替你拼、Python 代码拼。
- 第四章，你第一次成为**接请求的人**：FastAPI 把函数挂到路径上，谁来访问就调用谁。
- 第五章，你接触了**后端背后的数据源**：MySQL。三种工具只是入口不同，SQL 是共同语言。

后面的学习，无非是在这条链路上加细节：加参数、加鉴权、查更多表、写更复杂的业务逻辑。但骨架永远是这套骨架。

---

<a href="#top">回到顶部</a>