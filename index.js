const express = require('express');
const cors = require('cors');
const bcrypt = require('bcryptjs');
const app = express();

app.use(cors());
app.use(express.json());

// 静态文件（前端页面放 public 目录）
app.use(express.static('public'));

// 路由
app.use('/api/auth', require('./routes/auth'));
app.use('/api/windows', require('./routes/windows'));
app.use('/api/reviews', require('./routes/reviews'));
app.use('/api/admin', require('./routes/admin'));

// 健康检查
app.get('/api/ping', (req, res) => res.json({ ok: true }));

const PORT = 3000;
const pool = require('./db');

// 启动时同步管理员密码（通过环境变量 ADMIN_PASSWORD 控制）
async function syncAdminPassword() {
  const adminPwd = process.env.ADMIN_PASSWORD;
  if (!adminPwd) return; // 没设置环境变量就跳过
  try {
    const [rows] = await pool.query('SELECT * FROM admins WHERE username = ?', ['admin']);
    if (rows.length === 0) {
      // 不存在则自动创建
      const hash = await bcrypt.hash(adminPwd, 10);
      await pool.query('INSERT INTO admins (username, password_hash) VALUES (?, ?)', ['admin', hash]);
      console.log('[init] 管理员账号已创建');
    } else {
      // 检查密码是否匹配，不匹配则更新
      const ok = rows[0].password_hash.startsWith('$2b$')
        ? await bcrypt.compare(adminPwd, rows[0].password_hash)
        : (adminPwd === rows[0].password_hash);
      if (!ok) {
        const hash = await bcrypt.hash(adminPwd, 10);
        await pool.query('UPDATE admins SET password_hash = ? WHERE username = ?', [hash, 'admin']);
        console.log('[init] 管理员密码已同步');
      } else {
        console.log('[init] 管理员密码正常');
      }
    }
  } catch (e) {
    console.error('[init] 管理员密码同步失败:', e.message);
  }
}

app.listen(PORT, async () => {
  console.log(`服务器运行中: http://localhost:${PORT}`);
  await syncAdminPassword();
});
