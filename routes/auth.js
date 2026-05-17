const router = require('express').Router();
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const pool = require('../db');
const { SECRET } = require('../middleware/auth');

// POST /api/auth/register - 用户注册
router.post('/register', async (req, res) => {
  const { username, password } = req.body;
  if (!username || !password) return res.status(400).json({ error: '用户名和密码不能为空' });
  if (username.length < 2 || username.length > 50) return res.status(400).json({ error: '用户名长度2-50位' });
  if (password.length < 6) return res.status(400).json({ error: '密码至少6位' });

  try {
    // 检查用户名是否被用户或管理员占用
    const [users] = await pool.query('SELECT username FROM users WHERE username=?', [username]);
    const [admins] = await pool.query('SELECT username FROM admins WHERE username=?', [username]);
    if (users.length > 0 || admins.length > 0) return res.status(409).json({ error: '用户名已被占用' });

    const hash = await bcrypt.hash(password, 10);
    const [result] = await pool.query(
      'INSERT INTO users (username, password_hash) VALUES (?, ?)',
      [username, hash]
    );
    res.json({ message: '注册成功', user_id: result.insertId, username });
  } catch (e) {
    res.status(500).json({ error: '服务器错误' });
  }
});

// POST /api/auth/login - 用户登录
router.post('/login', async (req, res) => {
  const { username, password } = req.body;
  if (!username || !password) return res.status(400).json({ error: '参数缺失' });

  try {
    const [rows] = await pool.query('SELECT * FROM users WHERE username=?', [username]);
    if (rows.length === 0) return res.status(401).json({ error: '用户名或密码错误' });

    const user = rows[0];
    const ok = await bcrypt.compare(password, user.password_hash);
    if (!ok) return res.status(401).json({ error: '用户名或密码错误' });

    const token = jwt.sign({ user_id: user.user_id, username: user.username, role: 'user' }, SECRET, { expiresIn: '7d' });
    res.json({ token, user_id: user.user_id, username: user.username });
  } catch (e) {
    res.status(500).json({ error: '服务器错误' });
  }
});

// POST /api/auth/admin/login - 管理员登录
router.post('/admin/login', async (req, res) => {
  const { username, password } = req.body;
  if (!username || !password) return res.status(400).json({ error: '参数缺失' });

  try {
    const [rows] = await pool.query('SELECT * FROM admins WHERE username=?', [username]);
    if (rows.length === 0) return res.status(401).json({ error: '账号或密码错误' });

    const admin = rows[0];
    // 初始账号密码用明文比较（生产环境应换成bcrypt）
    let ok = false;
    if (admin.password_hash.startsWith('$2b$')) {
      ok = await bcrypt.compare(password, admin.password_hash);
    } else {
      ok = (password === admin.password_hash);
    }
    if (!ok) return res.status(401).json({ error: '账号或密码错误' });

    const token = jwt.sign({ admin_id: admin.admin_id, username: admin.username, role: 'admin' }, SECRET, { expiresIn: '7d' });
    res.json({ token, admin_id: admin.admin_id, username: admin.username });
  } catch (e) {
    res.status(500).json({ error: '服务器错误' });
  }
});

module.exports = router;
