# What To Eat Today - 校园食堂窗口评价系统

基于 Node.js + Express + MySQL 的校园食堂窗口评价与推荐系统。学生可浏览窗口菜品、查看评分、提交评价，管理员可管理窗口/菜品/用户/评价，并提供"今天吃什么"随机推荐功能。

## 功能特性

### 学生端
- 用户注册 / 登录
- 浏览所有食堂窗口及菜品
- 查看菜品评分与评价详情（含管理员回复）
- 提交评价（1-5 星 + 文字评论，每道菜限评一次）
- 删除自己的评价
- **今天吃什么** - 随机推荐菜品

### 管理员端
- 管理员登录（密码通过环境变量 `ADMIN_PASSWORD` 自动同步）
- 数据总览：用户数、窗口数、菜品数、评价数
- 窗口 CRUD（创建/编辑/删除，支持颜色标识和描述）
- 菜品管理（创建/编辑/上下架/删除）
- 用户管理（查看/删除）
- 评价管理（查看全部/删除/回复学生评价）

## 技术架构

### 技术栈

| 层级 | 技术 | 版本 | 说明 |
|------|------|------|------|
| 运行时 | Node.js | 18+ | 服务端 JavaScript 运行环境 |
| Web 框架 | Express | 5.x | 路由/中间件/HTTP 服务 |
| 数据库 | MySQL | 8.0 | 关系型数据库，InnoDB 引擎 |
| 数据库驱动 | mysql2 | 3.x | Promise API，连接池管理 |
| 鉴权 | jsonwebtoken | 9.x | JWT Token 签发与验证 |
| 密码加密 | bcryptjs | 3.x | bcrypt 哈希加密（10 rounds） |
| 跨域 | cors | 2.8.x | CORS 中间件 |
| 前端 | HTML/CSS/JS | - | 原生实现，无框架依赖 |

### 系统架构图

```
┌─────────────────────────────────────────────────┐
│                   前端 (public/)                 │
│   login.html  |  index.html  |  admin.html      │
│         原生 HTML + CSS + JavaScript            │
└──────────────────────┬──────────────────────────┘
                       │ HTTP / REST API
                       ▼
┌─────────────────────────────────────────────────┐
│              后端 (Express 5)                    │
│                                                  │
│   index.js ─── 主入口，端口 3000                  │
│   ├── middleware/auth.js ── JWT 鉴权中间件       │
│   ├── routes/auth.js ─── 认证路由                │
│   ├── routes/windows.js ─ 窗口/菜品/推荐         │
│   ├── routes/reviews.js ─ 评价读写               │
│   └── routes/admin.js ── 管理员 CRUD             │
│                                                  │
│   db.js ── mysql2 连接池                         │
└──────────────────────┬──────────────────────────┘
                       │ TCP (mysql2/promise)
                       ▼
┌─────────────────────────────────────────────────┐
│                  MySQL 8.0                       │
│   canteen_review 数据库                          │
│   users | admins | windows | dishes | reviews    │
│   replies | v_dish_avg_rating | v_window_avg...  │
└─────────────────────────────────────────────────┘
```

## 项目结构

```
server/
├── index.js                  # Express 入口，启动服务 & 管理员密码同步
├── db.js                     # MySQL 连接池配置（支持多种连接方式）
├── package.json              # 项目依赖
├── railway-deploy.sql        # 完整建表脚本（表/索引/视图/示例数据）
├── middleware/
│   └── auth.js               # JWT 鉴权中间件（用户/管理员双角色）
├── routes/
│   ├── auth.js               # 注册 / 用户登录 / 管理员登录
│   ├── windows.js            # 窗口列表 / 菜品查询 / 随机推荐
│   ├── reviews.js            # 评价提交 / 查询 / 删除
│   └── admin.js              # 管理员：统计/用户/窗口/菜品/评价 CRUD
└── public/
    ├── login.html            # 登录 + 注册 + 今天吃什么
    ├── index.html            # 学生主页
    └── admin.html            # 管理后台
```

## 数据库设计

### ER 关系

```
users  1──N  reviews  N──1  dishes  N──1  windows
admins 1──N  replies N──1  reviews
```

### 表结构详情

#### users - 用户表

| 字段 | 类型 | 约束 | 说明 |
|------|------|------|------|
| user_id | INT | PK, AUTO_INCREMENT | 用户 ID |
| username | VARCHAR(50) | UNIQUE, NOT NULL | 用户名 |
| password_hash | VARCHAR(255) | NOT NULL | bcrypt 密码哈希 |
| created_at | DATETIME | NOT NULL, DEFAULT NOW | 注册时间 |

#### admins - 管理员表

| 字段 | 类型 | 约束 | 说明 |
|------|------|------|------|
| admin_id | INT | PK, AUTO_INCREMENT | 管理员 ID |
| username | VARCHAR(50) | UNIQUE, NOT NULL | 管理员用户名 |
| password_hash | VARCHAR(255) | NOT NULL | bcrypt 密码哈希（启动时从环境变量同步） |
| created_at | DATETIME | NOT NULL, DEFAULT NOW | 创建时间 |

#### windows - 食堂窗口表

| 字段 | 类型 | 约束 | 说明 |
|------|------|------|------|
| window_id | INT | PK, AUTO_INCREMENT | 窗口 ID |
| name | VARCHAR(100) | NOT NULL | 窗口名称 |
| color | VARCHAR(20) | DEFAULT 'blue' | 颜色标识 |
| description | TEXT | - | 窗口描述 |
| created_at | DATETIME | NOT NULL, DEFAULT NOW | 创建时间 |

#### dishes - 菜品表

| 字段 | 类型 | 约束 | 说明 |
|------|------|------|------|
| dish_id | INT | PK, AUTO_INCREMENT | 菜品 ID |
| window_id | INT | FK → windows | 所属窗口 |
| name | VARCHAR(100) | NOT NULL | 菜品名称 |
| price | DECIMAL(8,2) | NOT NULL | 价格 |
| is_active | TINYINT(1) | DEFAULT 1 | 是否上架 |
| created_at | DATETIME | NOT NULL, DEFAULT NOW | 创建时间 |

#### reviews - 评价表

| 字段 | 类型 | 约束 | 说明 |
|------|------|------|------|
| review_id | INT | PK, AUTO_INCREMENT | 评价 ID |
| user_id | INT | FK → users | 评价用户 |
| dish_id | INT | FK → dishes | 被评菜品 |
| rating | TINYINT(1) | NOT NULL | 评分 1-5 |
| content | TEXT | - | 评论文本 |
| created_at | DATETIME | NOT NULL, DEFAULT NOW | 评价时间 |

> 联合唯一约束 `(user_id, dish_id)` 保证每用户每菜只能评一次。

#### replies - 管理员回复表

| 字段 | 类型 | 约束 | 说明 |
|------|------|------|------|
| reply_id | INT | PK, AUTO_INCREMENT | 回复 ID |
| review_id | INT | FK → reviews | 所属评价 |
| admin_id | INT | FK → admins | 回复的管理员 |
| content | TEXT | NOT NULL | 回复内容 |
| created_at | DATETIME | NOT NULL, DEFAULT NOW | 回复时间 |

### 数据库视图

| 视图名 | 说明 |
|--------|------|
| `v_dish_avg_rating` | 菜品平均评分 & 评价数 |
| `v_window_avg_rating` | 窗口平均评分 & 总评价数 |

## 核心机制说明

### 鉴权流程

系统采用 **JWT (JSON Web Token)** 进行无状态鉴权：

1. 用户/管理员登录 → 服务端验证密码 → 签发 JWT（含 user_id / admin_id、username、role，有效期 7 天）
2. 客户端将 Token 存储在 localStorage，后续请求通过 `Authorization: Bearer <token>` 请求头携带
3. 服务端中间件 `authUser` / `authAdmin` 验证 Token 并提取用户信息注入 `req.user` / `req.admin`

```
登录请求 → bcrypt.compare(密码, 哈希) → jwt.sign(payload, SECRET, {expiresIn: '7d'}) → 返回 token
API请求 → Authorization: Bearer xxx → jwt.verify(token, SECRET) → 鉴权通过 / 拒绝
```

### 密码安全

- 所有用户密码使用 **bcryptjs** 加密存储（cost factor = 10）
- 管理员密码支持环境变量 `ADMIN_PASSWORD` 自动同步，启动时对比并更新
- 管理员登录同时兼容 bcrypt 哈希验证和明文验证（兼容历史数据）

### 数据库连接

`db.js` 使用 **mysql2 连接池**，支持多种连接配置方式，优先级如下：

```
MYSQL_URL (完整连接字符串) > DATABASE_URL > MYSQL_PUBLIC_URL > 单独变量 (DB_HOST/DB_PORT/DB_USER/DB_PASSWORD/DB_NAME)
```

- 本地开发：配置 `DB_HOST=localhost` 等单独变量
- Railway 部署：自动注入 `MYSQL_URL` / `MYSQL_PUBLIC_URL` 等环境变量

### 管理员密码自动同步

服务启动时自动执行 `syncAdminPassword()`：

1. 检查环境变量 `ADMIN_PASSWORD` 是否设置，未设置则跳过
2. 查询 `admins` 表中 `username='admin'` 的记录
3. **不存在** → 自动创建管理员账号（密码 bcrypt 加密后写入）
4. **已存在但密码不匹配** → 自动更新密码哈希
5. **已存在且密码匹配** → 跳过，输出日志

修改管理员密码只需更新 Railway 环境变量 `ADMIN_PASSWORD` 并重新部署即可。

## API 接口文档

### 认证接口

| 方法 | 路径 | 说明 | 请求体 | 响应 |
|------|------|------|--------|------|
| POST | `/api/auth/register` | 用户注册 | `{username, password}` | `{message, user_id, username}` |
| POST | `/api/auth/login` | 用户登录 | `{username, password}` | `{token, user_id, username}` |
| POST | `/api/auth/admin/login` | 管理员登录 | `{username, password}` | `{token, admin_id, username}` |

### 窗口与菜品（公开）

| 方法 | 路径 | 说明 | 响应 |
|------|------|------|------|
| GET | `/api/windows` | 所有窗口列表（含平均评分） | `[{window_id, name, color, description, avg_rating, review_count}]` |
| GET | `/api/windows/random` | 随机推荐一道在售菜品 | `{dish_id, name, price, window_name, color, avg_rating}` 或 `null` |
| GET | `/api/windows/:id/dishes` | 某窗口的所有在售菜品 | `[{dish_id, name, price, avg_rating, review_count}]` |

### 评价接口

| 方法 | 路径 | 说明 | 鉴权 | 请求体 | 响应 |
|------|------|------|------|--------|------|
| GET | `/api/reviews/dish/:dish_id` | 菜品评价列表（含回复） | - | - | `[{review_id, rating, content, username, reply_content}]` |
| POST | `/api/reviews` | 发表评价 | 用户 | `{dish_id, rating, content}` | `{message, review_id}` |
| DELETE | `/api/reviews/:id` | 删除自己的评价 | 用户 | - | `{message}` |

### 管理员接口（需 admin Token）

| 方法 | 路径 | 说明 |
|------|------|------|
| GET | `/api/admin/stats` | 统计总览（用户/窗口/菜品/评价数量） |
| GET | `/api/admin/users` | 用户列表 |
| DELETE | `/api/admin/users/:id` | 删除用户 |
| GET | `/api/admin/windows` | 窗口列表 |
| POST | `/api/admin/windows` | 创建窗口 `{name, color, description}` |
| PUT | `/api/admin/windows/:id` | 编辑窗口 `{name, color, description}` |
| DELETE | `/api/admin/windows/:id` | 删除窗口 |
| GET | `/api/admin/dishes` | 菜品列表（含所属窗口名） |
| POST | `/api/admin/dishes` | 创建菜品 `{window_id, name, price}` |
| PUT | `/api/admin/dishes/:id` | 编辑菜品 `{name, price, is_active}` |
| DELETE | `/api/admin/dishes/:id` | 删除菜品 |
| GET | `/api/admin/reviews` | 全部评价列表 |
| DELETE | `/api/admin/reviews/:id` | 删除评价 |
| POST | `/api/admin/reviews/:id/reply` | 回复评价 `{content}` |

## 环境变量说明

| 变量名 | 说明 | 默认值 |
|--------|------|--------|
| `ADMIN_PASSWORD` | 管理员密码（启动时自动同步到数据库） | - |
| `MYSQL_URL` | 完整 MySQL 连接字符串（优先级最高） | - |
| `DATABASE_URL` | 备选连接字符串 | - |
| `MYSQL_PUBLIC_URL` | 公网连接地址（Railway 注入） | - |
| `DB_HOST` | 数据库主机 | `mysql.railway.internal` |
| `DB_PORT` | 数据库端口 | `3306` |
| `DB_USER` | 数据库用户 | `root` |
| `DB_PASSWORD` | 数据库密码 | - |
| `DB_NAME` | 数据库名称 | `railway` |

连接优先级：`MYSQL_URL` > `DATABASE_URL` > `MYSQL_PUBLIC_URL` > 单独变量

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

```bash
# 创建数据库
mysql -u root -p -e "CREATE DATABASE canteen_review CHARACTER SET utf8mb4"

# 导入建表脚本（含表结构、索引、视图、示例数据）
mysql -u root -p canteen_review < railway-deploy.sql
```

### 4. 配置环境变量

```bash
# 本地开发
export DB_HOST=localhost
export DB_PORT=3306
export DB_USER=root
export DB_PASSWORD=your_password
export DB_NAME=canteen_review
export ADMIN_PASSWORD=your_admin_password
```

### 5. 启动服务

```bash
npm start
```

服务启动后访问：`http://localhost:3000`

## Railway 部署

本项目通过 **GitHub → Railway 自动部署**，推送至 `master` 分支即触发构建。

### 部署步骤

1. 在 Railway 创建项目，添加 **MySQL** 服务和 **Web Service**
2. Web Service 关联 GitHub 仓库 `joes133/what-to-eat-today`，分支选 `master`
3. 在 Railway MySQL Query 控制台执行 `railway-deploy.sql` 初始化数据库
4. 在项目 Settings → Variables 中添加 `ADMIN_PASSWORD` 环境变量
5. 部署自动完成，服务启动时会自动同步管理员密码

### 注意事项

- Railway MySQL Query 控制台不支持 `$` 字符，无法直接写入 bcrypt 哈希，请使用 `ADMIN_PASSWORD` 环境变量方式管理管理员密码
- 数据库内网地址由 Railway 自动注入 `MYSQL_URL`，无需手动配置
- 修改环境变量后需等待自动重新部署或手动 Redeploy

## License

MIT
