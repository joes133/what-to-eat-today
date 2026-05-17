const mysql = require('mysql2/promise');

// 优先使用 Railway 自动提供的 MYSQL_* 变量，其次使用 DB_* 变量
const pool = mysql.createPool({
  host: process.env.MYSQL_HOST || process.env.DB_HOST || 'mysql.railway.internal',
  port: process.env.MYSQL_PORT || process.env.DB_PORT || 3306,
  user: process.env.MYSQL_USER || process.env.DB_USER || 'root',
  password: process.env.MYSQL_PASSWORD || process.env.DB_PASSWORD || 'IbSQYTDiFwBUcJDlIFLEiLDZOEOEWILH',
  database: process.env.MYSQL_DATABASE || process.env.DB_NAME || 'railway',
  charset: 'utf8mb4',
  waitForConnections: true,
  connectionLimit: 10,
});

module.exports = pool;
