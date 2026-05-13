-- 校园食堂评价系统 - 简化建表脚本
-- 复制以下内容到 Railway MySQL 查询框执行

-- 创建 users 表
CREATE TABLE IF NOT EXISTS users (
    user_id INT NOT NULL AUTO_INCREMENT,
    username VARCHAR(50) NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (user_id),
    UNIQUE KEY uk_username (username)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 创建 admins 表
CREATE TABLE IF NOT EXISTS admins (
    admin_id INT NOT NULL AUTO_INCREMENT,
    username VARCHAR(50) NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (admin_id),
    UNIQUE KEY uk_admin_username (username)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 创建 windows 表
CREATE TABLE IF NOT EXISTS windows (
    window_id INT NOT NULL AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL,
    color VARCHAR(20) NOT NULL DEFAULT 'blue',
    description TEXT,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (window_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 创建 dishes 表
CREATE TABLE IF NOT EXISTS dishes (
    dish_id INT NOT NULL AUTO_INCREMENT,
    window_id INT NOT NULL,
    name VARCHAR(100) NOT NULL,
    price DECIMAL(8,2) NOT NULL,
    is_active TINYINT(1) NOT NULL DEFAULT 1,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (dish_id),
    FOREIGN KEY (window_id) REFERENCES windows(window_id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 创建 reviews 表
CREATE TABLE IF NOT EXISTS reviews (
    review_id INT NOT NULL AUTO_INCREMENT,
    user_id INT NOT NULL,
    dish_id INT NOT NULL,
    rating TINYINT(1) NOT NULL,
    content TEXT,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (review_id),
    UNIQUE KEY uk_user_dish (user_id, dish_id),
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE,
    FOREIGN KEY (dish_id) REFERENCES dishes(dish_id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 创建 replies 表
CREATE TABLE IF NOT EXISTS replies (
    reply_id INT NOT NULL AUTO_INCREMENT,
    review_id INT NOT NULL,
    admin_id INT NOT NULL,
    content TEXT NOT NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (reply_id),
    FOREIGN KEY (review_id) REFERENCES reviews(review_id) ON DELETE CASCADE,
    FOREIGN KEY (admin_id) REFERENCES admins(admin_id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 插入示例数据
INSERT INTO windows (name, color, description) VALUES
('川菜窗口', 'red', '正宗川味，麻辣鲜香'),
('粤菜窗口', 'green', '广东风味，清淡精致'),
('面食窗口', 'yellow', '手工拉面、刀削面'),
('清真窗口', 'blue', '清真美食，羊肉料理'),
('西式简餐', 'orange', '汉堡、意面、沙拉'),
('甜品饮品', 'purple', '甜点、奶茶、果汁');

INSERT INTO dishes (window_id, name, price, is_active) VALUES
(1, '麻辣香锅', 18.00, 1),
(1, '鱼香肉丝', 16.00, 1),
(2, '广式烧鸭饭', 20.00, 1),
(2, '虾饺', 15.00, 1),
(3, '牛肉拉面', 15.00, 1),
(3, '刀削面', 14.00, 1),
(4, '羊肉抓饭', 18.00, 1),
(4, '大盘鸡', 25.00, 1),
(5, '黑椒牛排饭', 28.00, 1),
(5, '意大利肉酱面', 22.00, 1),
(6, '杨枝甘露', 12.00, 1),
(6, '珍珠奶茶', 10.00, 1);

-- 插入管理员账号（密码: admin123）
INSERT INTO admins (username, password_hash) VALUES
('admin', '$2b$10$YourHashHere');

SELECT '数据库初始化完成！' AS result;
