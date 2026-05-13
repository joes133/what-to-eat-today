const router = require('express').Router();
const pool = require('../db');
const bcrypt = require('bcryptjs');
const { authAdmin } = require('../middleware/auth');

// ── 统计总览 ──────────────────────────────────────────────
// GET /api/admin/stats
router.get('/stats', authAdmin, async (req, res) => {
  try {
    const [[{ users }]] = await pool.query('SELECT COUNT(*) AS users FROM users');
    const [[{ windows }]] = await pool.query('SELECT COUNT(*) AS windows FROM windows');
    const [[{ dishes }]] = await pool.query('SELECT COUNT(*) AS dishes FROM dishes');
    const [[{ reviews }]] = await pool.query('SELECT COUNT(*) AS reviews FROM reviews');
    res.json({ users, windows, dishes, reviews });
  } catch (e) {
    res.status(500).json({ error: '服务器错误' });
  }
});

// ── 用户管理 ──────────────────────────────────────────────
router.get('/users', authAdmin, async (req, res) => {
  const [rows] = await pool.query('SELECT user_id, username, created_at FROM users ORDER BY user_id DESC');
  res.json(rows);
});

router.delete('/users/:id', authAdmin, async (req, res) => {
  await pool.query('DELETE FROM users WHERE user_id=?', [req.params.id]);
  res.json({ message: '已删除' });
});

// ── 窗口管理 ──────────────────────────────────────────────
router.get('/windows', authAdmin, async (req, res) => {
  const [rows] = await pool.query('SELECT * FROM windows ORDER BY window_id');
  res.json(rows);
});

router.post('/windows', authAdmin, async (req, res) => {
  const { name, color, description } = req.body;
  if (!name) return res.status(400).json({ error: '窗口名不能为空' });
  const [r] = await pool.query('INSERT INTO windows (name, color, description) VALUES (?, ?, ?)', [name, color || 'blue', description || null]);
  res.json({ message: '创建成功', window_id: r.insertId });
});

router.put('/windows/:id', authAdmin, async (req, res) => {
  const { name, color, description } = req.body;
  await pool.query('UPDATE windows SET name=?, color=?, description=? WHERE window_id=?', [name, color, description, req.params.id]);
  res.json({ message: '更新成功' });
});

router.delete('/windows/:id', authAdmin, async (req, res) => {
  await pool.query('DELETE FROM windows WHERE window_id=?', [req.params.id]);
  res.json({ message: '已删除' });
});

// ── 菜品管理 ──────────────────────────────────────────────
router.get('/dishes', authAdmin, async (req, res) => {
  const [rows] = await pool.query(`
    SELECT d.*, w.name AS window_name FROM dishes d
    JOIN windows w ON w.window_id = d.window_id
    ORDER BY d.dish_id DESC
  `);
  res.json(rows);
});

router.post('/dishes', authAdmin, async (req, res) => {
  const { window_id, name, price } = req.body;
  if (!window_id || !name || !price) return res.status(400).json({ error: '参数缺失' });
  const [r] = await pool.query('INSERT INTO dishes (window_id, name, price) VALUES (?, ?, ?)', [window_id, name, price]);
  res.json({ message: '创建成功', dish_id: r.insertId });
});

router.put('/dishes/:id', authAdmin, async (req, res) => {
  const { name, price, is_active } = req.body;
  await pool.query('UPDATE dishes SET name=?, price=?, is_active=? WHERE dish_id=?', [name, price, is_active, req.params.id]);
  res.json({ message: '更新成功' });
});

router.delete('/dishes/:id', authAdmin, async (req, res) => {
  await pool.query('DELETE FROM dishes WHERE dish_id=?', [req.params.id]);
  res.json({ message: '已删除' });
});

// ── 评价管理 ──────────────────────────────────────────────
router.get('/reviews', authAdmin, async (req, res) => {
  const [rows] = await pool.query(`
    SELECT r.review_id, r.rating, r.content, r.created_at,
           u.username, d.name AS dish_name,
           rep.content AS reply_content
    FROM reviews r
    JOIN users u ON u.user_id = r.user_id
    JOIN dishes d ON d.dish_id = r.dish_id
    LEFT JOIN replies rep ON rep.review_id = r.review_id
    ORDER BY r.created_at DESC
  `);
  res.json(rows);
});

router.delete('/reviews/:id', authAdmin, async (req, res) => {
  await pool.query('DELETE FROM reviews WHERE review_id=?', [req.params.id]);
  res.json({ message: '已删除' });
});

// 回复评价
router.post('/reviews/:id/reply', authAdmin, async (req, res) => {
  const { content } = req.body;
  if (!content) return res.status(400).json({ error: '回复内容不能为空' });
  // 先删旧回复
  await pool.query('DELETE FROM replies WHERE review_id=?', [req.params.id]);
  await pool.query('INSERT INTO replies (review_id, admin_id, content) VALUES (?, ?, ?)', [req.params.id, req.admin.admin_id, content]);
  res.json({ message: '回复成功' });
});

module.exports = router;
