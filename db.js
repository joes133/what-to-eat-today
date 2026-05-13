const mysql = require('mysql2/promise');

// Railway环境变量：优先使用，如果没有则用本地开发配置
const pool = mysql.createPool({
  host: process.env.MYSQLHOST || 'localhost',
  port: parseInt(process.env.MYSQLPORT || '3306'),
  user: process.env.MYSQLUSER || 'root',
  password: process.env.MYSQLPASSWORD || '63512wawzj',
  database: process.env.MYSQLDATABASE || 'canteen_review',
  charset: 'utf8mb4',
  waitForConnections: true,
  connectionLimit: 10,
});

module.exports = pool;
