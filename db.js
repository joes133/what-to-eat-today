const mysql = require('mysql2/promise');

// 使用环境变量，提供默认值（用于本地开发）
const pool = mysql.createPool({
  host: process.env.DB_HOST || 'mysql.railway.internal',
  port: process.env.DB_PORT || 3306,
  user: process.env.DB_USER || 'root',
  password: process.env.DB_PASSWORD || 'IbSQYTDiFwBUcJDlIFLEiLDZOEOEWILH',
  database: process.env.DB_NAME || 'railway',
  charset: 'utf8mb4',
  waitForConnections: true,
  connectionLimit: 10,
});

module.exports = pool;
