# What To Eat Today - 校园食堂窗口评价系统

一个基于 Node.js 的校园食堂窗口评价系统，支持学生浏览窗口菜品、查看评价、随机推荐，管理员可管理窗口、菜品、用户和评价。

## 功能特性

### 学生端
- 用户注册 / 登录
- 浏览所有食堂窗口及菜品
- 查看菜品评分与评价
- 提交评价（1-5 星）与文字评论
- 删除自己的评价
- **今天吃什么** - 随机推荐菜品

### 管理员端
- 管理员登录
- 窗口 CRUD（增删改查）
- 菜品管理（上架/下架）
- 用户管理
- 评价管理（查看/删除）
- 回复学生评价

## 技术栈

| 层级 | 技术 |
|------|------|
| 后端 | Node.js + Express 5 |
| 数据库 | MySQL 8.0 |
| 鉴权 | JWT + bcryptjs |
| 前端 | 原生 HTML / CSS / JavaScript |

## 项目结构

```
server/
├── index.js              # Express 入口，端口 3000
├── db.js                 # MySQL 连接池配置
├── middleware/
│   └── auth.js           # JWT 鉴权中间件
├── routes/
│   ├── auth.js           # 注册 / 登录 / 管理员登录
│   ├── windows.js        # 窗口列表 / 菜品 / 随机推荐
│   ├── reviews.js        # 评价读 / 写 / 删
│   └── admin.js          # 管理员 CRUD
└── public/
    ├── login.html        # 登录 + 注册 + 今天吃什么
    ├── index.html        # 学生主页
    └── admin.html        # 管理后台
```

## 数据库表结构

| 表名 | 说明 |
|------|------|
| users | 普通用户 |
| admins | 管理员 |
| windows | 食堂窗口（名称/颜色/描述） |
| dishes | 菜品（挂载窗口，支持上下架） |
| reviews | 评价（1-5 星，每人每菜一条） |
| replies | 管理员回复评价 |

## 快速开始

### 1. 克隆项目

```bash
git clone https://github.com/joes133/what-to-eat-today.git
cd what-to-eat-today
```

### 2. 安装依赖

```bash
npm install
```

### 3. 配置数据库

导入建表脚本并初始化数据：

```bash
mysql -u root -p your_database < railway-deploy.sql
```

### 4. 配置环境变量

复制并编辑环境变量（本地开发可选）：

```bash
DB_HOST=localhost
DB_PORT=3306
DB_USER=root
DB_PASSWORD=your_password
DB_NAME=your_database
```

### 5. 启动服务

```bash
npm start
```

服务启动后访问：`http://localhost:3000`

## 环境变量说明

| 变量名 | 说明 | 默认值 |
|--------|------|--------|
| `MYSQL_URL` | 完整 MySQL 连接字符串 | - |
| `DATABASE_URL` | 备选连接字符串 | - |
| `MYSQL_PUBLIC_URL` | 公网连接地址（Railway） | - |
| `DB_HOST` | 数据库主机 | `mysql.railway.internal` |
| `DB_PORT` | 数据库端口 | `3306` |
| `DB_USER` | 数据库用户 | `root` |
| `DB_PASSWORD` | 数据库密码 | - |
| `DB_NAME` | 数据库名称 | `railway` |

优先级：`MYSQL_URL` > `DATABASE_URL` > `MYSQL_PUBLIC_URL` > 单独变量

## API 接口

| 方法 | 路径 | 说明 | 鉴权 |
|------|------|------|------|
| POST | `/api/auth/register` | 用户注册 | - |
| POST | `/api/auth/login` | 用户登录 | - |
| POST | `/api/auth/admin/login` | 管理员登录 | - |
| GET | `/api/windows` | 获取所有窗口 | - |
| GET | `/api/windows/random` | 随机推荐菜品 | - |
| GET | `/api/windows/:id/dishes` | 获取窗口菜品 | - |
| GET | `/api/windows/:id/reviews` | 获取菜品评价 | - |
| POST | `/api/windows/:id/reviews` | 提交评价 | 用户 |
| DELETE | `/api/reviews/:id` | 删除评价 | 用户 |
| GET | `/api/admin/stats` | 管理统计 | 管理员 |
| * | `/api/admin/*` | 管理员 CRUD 操作 | 管理员 |

## 部署

本项目已部署到 [Railway](https://railway.app/) 平台。

如需自行部署，确保：
1. `package.json` 中包含 `"start": "node index.js"` 脚本
2. 正确配置数据库连接环境变量
3. 执行 `railway-deploy.sql` 初始化数据库表结构和示例数据

## License

MIT
