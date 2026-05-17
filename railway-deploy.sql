-- ============================================================
-- Railway 部署专用建表脚本
-- 先在 Railway MySQL 创建 canteen_review 数据库，再执行此脚本
-- ============================================================

USE canteen_review;

-- 1. users 表
CREATE TABLE IF NOT EXISTS users (
    user_id       INT          NOT NULL AUTO_INCREMENT,
    username      VARCHAR(50)  NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    created_at    DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (user_id),
    UNIQUE KEY uk_username (username)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 2. admins 表
CREATE TABLE IF NOT EXISTS admins (
    admin_id      INT          NOT NULL AUTO_INCREMENT,
    username      VARCHAR(50)  NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    created_at    DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (admin_id),
    UNIQUE KEY uk_admin_username (username)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 3. windows 表
CREATE TABLE IF NOT EXISTS windows (
    window_id   INT          NOT NULL AUTO_INCREMENT,
    name        VARCHAR(100) NOT NULL,
    color       VARCHAR(20)  NOT NULL DEFAULT 'blue',
    description TEXT,
    created_at  DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (window_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 4. dishes 表
CREATE TABLE IF NOT EXISTS dishes (
    dish_id    INT          NOT NULL AUTO_INCREMENT,
    window_id  INT          NOT NULL,
    name       VARCHAR(100) NOT NULL,
    price      DECIMAL(8,2) NOT NULL,
    is_active  TINYINT(1)  NOT NULL DEFAULT 1,
    created_at DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (dish_id),
    FOREIGN KEY (window_id) REFERENCES windows(window_id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 5. reviews 表
CREATE TABLE IF NOT EXISTS reviews (
    review_id  INT          NOT NULL AUTO_INCREMENT,
    user_id    INT          NOT NULL,
    dish_id    INT          NOT NULL,
    rating     TINYINT(1)  NOT NULL,
    content    TEXT,
    created_at DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (review_id),
    UNIQUE KEY uk_user_dish (user_id, dish_id),
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE,
    FOREIGN KEY (dish_id) REFERENCES dishes(dish_id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 6. replies 表
CREATE TABLE IF NOT EXISTS replies (
    reply_id   INT          NOT NULL AUTO_INCREMENT,
    review_id  INT          NOT NULL,
    admin_id   INT          NOT NULL,
    content    TEXT         NOT NULL,
    created_at DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (reply_id),
    FOREIGN KEY (review_id) REFERENCES reviews(review_id) ON DELETE CASCADE,
    FOREIGN KEY (admin_id)  REFERENCES admins(admin_id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 索引
CREATE INDEX idx_reviews_dish ON reviews(dish_id);
CREATE INDEX idx_reviews_user ON reviews(user_id);
CREATE INDEX idx_replies_review ON replies(review_id);
CREATE INDEX idx_dishes_window ON dishes(window_id);

-- 视图
CREATE OR REPLACE VIEW v_dish_avg_rating AS
SELECT
    d.dish_id,
    d.window_id,
    d.name AS dish_name,
    d.is_active,
    COALESCE(AVG(r.rating), 0) AS avg_rating,
    COUNT(r.review_id) AS review_count
FROM dishes d
LEFT JOIN reviews r ON d.dish_id = r.dish_id
GROUP BY d.dish_id, d.window_id, d.name, d.is_active;

CREATE OR REPLACE VIEW v_window_avg_rating AS
SELECT
    w.window_id,
    w.name AS window_name,
    w.color,
    COALESCE(AVG(v.avg_rating), 0) AS window_avg_rating,
    SUM(v.review_count) AS total_reviews
FROM windows w
LEFT JOIN v_dish_avg_rating v ON w.window_id = v.window_id
GROUP BY w.window_id, w.name, w.color;

-- 初始管理员账号 (密码: caramel133)
INSERT INTO admins (username, password_hash) VALUES
('admin', '$2b$10$EixZaYVK1fsbw1ZfbX3OXePaWxn96p36WQoeG6Lruj3vrj3ZqgBGu');

-- 窗口示例数据
INSERT INTO windows (name, color, description) VALUES
('川菜窗口', 'red', '正宗川味，麻辣鲜香'),
('粤菜窗口', 'green', '广东风味，清淡精致'),
('面食窗口', 'yellow', '手工拉面、刀削面'),
('清真窗口', 'blue', '清真美食，羊肉料理'),
('西式简餐', 'orange', '汉堡、意面、沙拉'),
('甜品饮品', 'purple', '奶茶、果汁、甜点');

-- 菜品示例数据
INSERT INTO dishes (window_id, name, price) VALUES
(1, '麻辣香锅', 18.00),
(1, '鱼香肉丝', 16.00),
(1, '麻婆豆腐', 12.00),
(2, '广式烧鸭饭', 20.00),
(2, '虾饺', 15.00),
(3, '牛肉拉面', 15.00),
(3, '刀削面', 14.00),
(4, '羊肉抓饭', 18.00),
(4, '大盘鸡', 25.00),
(5, '意式肉酱面', 22.00),
(5, '汉堡套餐', 25.00),
(6, '杨枝甘露', 12.00),
(6, '珍珠奶茶', 10.00);

SELECT '建表完成！' AS result;
