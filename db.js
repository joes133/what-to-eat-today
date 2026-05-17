const mysql = require('mysql2/promise');

// 优先使用 Railway 提供的完整连接字符串
// 内网地址优先，公网地址作为备选
const mysqlUrl = process.env.MYSQL_URL || process.env.DATABASE_URL || process.env.MYSQL_PUBLIC_URL;

let pool;
if (mysqlUrl) {
  // 使用完整连接字符串
  pool = mysql.createPool(mysqlUrl);
} else {
  // 使用单独的环境变量（本地开发）
  pool = mysql.createPool({
    host: process.env.MYSQL_HOST || process.env.DB_HOST || 'mysql.railway.internal',
    port: process.env.MYSQL_PORT || process.env.DB_PORT || 3306,
    user: process.env.MYSQL_USER || process.env.DB_USER || 'root',
    password: process.env.MYSQL_PASSWORD || process.env.DB_PASSWORD || 'IbSQYTDiFwBUcJDlIFLEiLDZOEOEWILH',
    database: process.env.MYSQL_DATABASE || process.env.DB_NAME || 'railway',
    charset: 'utf8mb4',
    waitForConnections: true,
    connectionLimit: 10,
  });
}

module.exports = pool;
