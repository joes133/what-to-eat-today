const mysql = require('mysql2/promise');

// Railway 生产环境配置
const pool = mysql.createPool({
  host: 'mysql.railway.internal',
  port: 3306,
  user: 'root',
  password: 'IbSQYTDiFwBUcJDlIFLEiLDZOEOEWILH',
  database: 'railway',
  charset: 'utf8mb4',
  waitForConnections: true,
  connectionLimit: 10,
});

module.exports = pool;
