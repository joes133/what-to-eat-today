-- ============================================================
-- 校园食堂窗口评价系统 - 数据库建表脚本
-- MySQL 8.0+
-- 生成时间：2026-05-09
-- ============================================================

-- 如果数据库已存在则删除（首次建库时使用，后续慎用）
DROP DATABASE IF EXISTS canteen_review;
CREATE DATABASE canteen_review DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE canteen_review;

-- ============================================================
-- 1. users 表 - 普通用户
-- ============================================================
DROP TABLE IF EXISTS users;
CREATE TABLE users (
    user_id       INT          NOT NULL AUTO_INCREMENT COMMENT '用户ID（系统自动生成）',
    username      VARCHAR(50)  NOT NULL COMMENT '用户名（登录用，全局唯一）',
    password_hash VARCHAR(255) NOT NULL COMMENT '密码哈希（bcrypt加密）',
    created_at    DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '注册时间',
    PRIMARY KEY (user_id),
    UNIQUE KEY uk_username (username)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='普通用户表';

-- ============================================================
-- 2. admins 表 - 管理员
-- 说明：admins 与 users 用户名全局唯一，在应用层校验
-- ============================================================
DROP TABLE IF EXISTS admins;
CREATE TABLE admins (
    admin_id      INT          NOT NULL AUTO_INCREMENT COMMENT '管理员ID',
    username      VARCHAR(50)  NOT NULL COMMENT '管理员用户名（全局唯一）',
    password_hash VARCHAR(255) NOT NULL COMMENT '密码哈希（bcrypt加密）',
    created_at    DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    PRIMARY KEY (admin_id),
    UNIQUE KEY uk_admin_username (username)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='管理员表';

-- ============================================================
-- 3. windows 表 - 食堂窗口（每个档口）
-- color 字段使用预设值：red / green / yellow / blue / orange / purple
-- ============================================================
DROP TABLE IF EXISTS windows;
CREATE TABLE windows (
    window_id   INT          NOT NULL AUTO_INCREMENT COMMENT '窗口ID',
    name        VARCHAR(100) NOT NULL COMMENT '窗口名称（如：川菜窗口）',
    color       VARCHAR(20)  NOT NULL DEFAULT 'blue' COMMENT '颜色标识（red/green/yellow/blue/orange/purple）',
    description TEXT                  COMMENT '窗口描述',
    created_at  DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    PRIMARY KEY (window_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='食堂窗口表';

-- ============================================================
-- 4. dishes 表 - 菜品（挂在窗口下）
-- is_active：1=上架（用户可见），0=下架（用户不可见，数据保留）
-- ============================================================
DROP TABLE IF EXISTS dishes;
CREATE TABLE dishes (
    dish_id    INT          NOT NULL AUTO_INCREMENT COMMENT '菜品ID',
    window_id  INT          NOT NULL COMMENT '所属窗口ID（外键）',
    name       VARCHAR(100) NOT NULL COMMENT '菜品名称',
    price      DECIMAL(8,2) NOT NULL COMMENT '价格（元）',
    is_active  TINYINT(1)  NOT NULL DEFAULT 1 COMMENT '上架状态：1=上架，0=下架',
    created_at DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    PRIMARY KEY (dish_id),
    FOREIGN KEY (window_id) REFERENCES windows(window_id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='菜品表';

-- ============================================================
-- 5. reviews 表 - 用户评价（对菜品）
-- 同一用户对同一菜品只能有一条评价（由应用层+数据库唯一约束保证）
-- rating：1~5 整数
-- ============================================================
DROP TABLE IF EXISTS reviews;
CREATE TABLE reviews (
    review_id  INT          NOT NULL AUTO_INCREMENT COMMENT '评价ID',
    user_id    INT          NOT NULL COMMENT '评价者ID（外键→users）',
    dish_id    INT          NOT NULL COMMENT '被评价菜品ID（外键→dishes）',
    rating     TINYINT(1)  NOT NULL COMMENT '评分（1-5分，整数）',
    content    TEXT                  COMMENT '评价内容（最多500字）',
    created_at DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '评价时间',
    PRIMARY KEY (review_id),
    UNIQUE KEY uk_user_dish (user_id, dish_id) COMMENT '同一用户对同一菜品只能评价一次',
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE,
    FOREIGN KEY (dish_id) REFERENCES dishes(dish_id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='评价表';

-- ============================================================
-- 6. replies 表 - 管理员回复评价
-- ============================================================
DROP TABLE IF EXISTS replies;
CREATE TABLE replies (
    reply_id   INT          NOT NULL AUTO_INCREMENT COMMENT '回复ID',
    review_id  INT          NOT NULL COMMENT '被回复的评价ID（外键→reviews）',
    admin_id   INT          NOT NULL COMMENT '回复的管理员ID（外键→admins）',
    content    TEXT         NOT NULL COMMENT '回复内容',
    created_at DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '回复时间',
    PRIMARY KEY (reply_id),
    FOREIGN KEY (review_id) REFERENCES reviews(review_id) ON DELETE CASCADE,
    FOREIGN KEY (admin_id)  REFERENCES admins(admin_id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='管理员回复表';

-- ============================================================
-- 索引优化（提升查询性能）
-- ============================================================

-- 评价表：按菜品查评价（用户端"查看菜品评价"常用）
CREATE INDEX idx_reviews_dish ON reviews(dish_id);

-- 评价表：按用户查评价（用户端"我的评价"常用）
CREATE INDEX idx_reviews_user ON reviews(user_id);

-- 回复表：按评价查回复
CREATE INDEX idx_replies_review ON replies(review_id);

-- 菜品表：按窗口查菜品（用户端"查看窗口菜品"常用）
CREATE INDEX idx_dishes_window ON dishes(window_id);

-- ============================================================
-- 初始数据
-- ============================================================

-- 管理员初始账号：admin / caramel133
-- 密码哈希由应用层注册时生成，此处用占位符，首次运行后用后端接口创建
-- 直接在 MySQL 中生成：SELECT SHA2('caramel133', 256) 仅作演示，实际应用用 bcrypt
-- 此处插入时密码字段留空，首次部署后通过后端接口设置密码

-- 为方便演示，这里用 bcrypt 对 'caramel133' 的已知哈希值（实际应用由后端生成）
-- 占位：部署后请通过管理员注册接口或后端脚本重置密码
-- 此处先插入一个已知 bcrypt 哈希（cost=10，密码 caramel133）
-- 如使用以下哈希，请确认是通过 node 的 bcrypt.hash('caramel133', 10) 生成
INSERT INTO admins (username, password_hash) VALUES
('admin', '$2b$10$placeholder_hash_replace_in_production');

-- ============================================================
-- 窗口示例数据（6个窗口，对应6种颜色）
-- ============================================================
INSERT INTO windows (name, color, description) VALUES
('川菜窗口', 'red',    '正宗川味，麻辣鲜香，每日新鲜食材直达窗口。'),
('粤菜窗口', 'green',  '广东风味，清淡精致，煲汤与烧味是招牌。'),
('面食窗口', 'yellow', '手工拉面、刀削面、牛肉面，面条现拉现煮。'),
('清真窗口', 'blue',   '清真美食，羊肉料理和西北面食为主。'),
('西式简餐', 'orange', '汉堡、意面、沙拉，快捷西式风味。'),
('甜品饮品', 'purple', '饭后甜点、奶茶、果汁，各种饮品和小食。');

-- ============================================================
-- 菜品示例数据（每个窗口4道菜）
-- ============================================================
INSERT INTO dishes (window_id, name, price, is_active) VALUES
-- 川菜窗口 (window_id=1)
(1, '麻辣香锅', 18.00, 1),
(1, '鱼香肉丝', 16.00, 1),
(1, '麻婆豆腐', 12.00, 1),
(1, '水煮鱼', 22.00, 1),
-- 粤菜窗口 (window_id=2)
(2, '广式烧鸭饭', 20.00, 1),
(2, '虾饺', 15.00, 1),
(2, '煲仔饭', 18.00, 1),
(2, '肠粉', 10.00, 1),
-- 面食窗口 (window_id=3)
(3, '牛肉拉面', 15.00, 1),
(3, '刀削面', 14.00, 1),
(3, '炸酱面', 12.00, 1),
(3, '羊肉泡馍', 18.00, 1),
-- 清真窗口 (window_id=4)
(4, '羊肉抓饭', 18.00, 1),
(4, '拉条子', 14.00, 1),
(4, '烤包子', 5.00,  1),
(4, '大盘鸡', 25.00, 1),
-- 西式简餐 (window_id=5)
(5, '黑椒牛排饭', 28.00, 1),
(5, '意大利肉酱面', 22.00, 1),
(5, '鸡肉凯撒沙拉', 18.00, 1),
(5, '汉堡套餐', 25.00, 1),
-- 甜品饮品 (window_id=6)
(6, '杨枝甘露', 12.00, 1),
(6, '双皮奶', 8.00,  1),
(6, '珍珠奶茶', 10.00, 1),
(6, '芒果班戟', 10.00, 1);

-- ============================================================
-- 评分计算视图（可选，方便查询）
-- 菜品平均评分视图
-- ============================================================
DROP VIEW IF EXISTS v_dish_avg_rating;
CREATE VIEW v_dish_avg_rating AS
SELECT
    d.dish_id,
    d.window_id,
    d.name            AS dish_name,
    d.is_active,
    COALESCE(AVG(r.rating), 0) AS avg_rating,
    COUNT(r.review_id)        AS review_count
FROM dishes d
LEFT JOIN reviews r ON d.dish_id = r.dish_id
GROUP BY d.dish_id, d.window_id, d.name, d.is_active;

-- ============================================================
-- 窗口综合评分视图
-- ============================================================
DROP VIEW IF EXISTS v_window_avg_rating;
CREATE VIEW v_window_avg_rating AS
SELECT
    w.window_id,
    w.name             AS window_name,
    w.color,
    COALESCE(AVG(v.avg_rating), 0) AS window_avg_rating,
    SUM(v.review_count)           AS total_reviews
FROM windows w
LEFT JOIN v_dish_avg_rating v ON w.window_id = v.window_id
GROUP BY w.window_id, w.name, w.color;

-- ============================================================
-- 建表完成提示
-- ============================================================
SELECT 'canteen_review 数据库建表完成！' AS result;
SELECT COUNT(*) AS window_count FROM windows;
SELECT COUNT(*) AS dish_count   FROM dishes;
