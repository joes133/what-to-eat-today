const router = require('express').Router();
const pool = require('../db');
const { authUser } = require('../middleware/auth');

// GET /api/reviews/dish/:dish_id - 获取某菜品的所有评价
router.get('/dish/:dish_id', async (req, res) => {
  try {
    const [rows] = await pool.query(`
      SELECT r.review_id, r.rating, r.content, r.created_at,
             u.username,
             rep.content AS reply_content, rep.created_at AS reply_at
      FROM reviews r
      JOIN users u ON u.user_id = r.user_id
      LEFT JOIN replies rep ON rep.review_id = r.review_id
      WHERE r.dish_id = ?
      ORDER BY r.created_at DESC
    `, [req.params.dish_id]);
    res.json(rows);
  } catch (e) {
    res.status(500).json({ error: '服务器错误' });
  }
});

// POST /api/reviews - 发表评价（需登录）
router.post('/', authUser, async (req, res) => {
  const { dish_id, rating, content } = req.body;
  if (!dish_id || !rating) return res.status(400).json({ error: '参数缺失' });
  if (rating < 1 || rating > 5 || !Number.isInteger(Number(rating))) {
    return res.status(400).json({ error: '评分须为1-5的整数' });
  }

  try {
    // 检查菜品是否存在
    const [dish] = await pool.query('SELECT dish_id FROM dishes WHERE dish_id=? AND is_active=1', [dish_id]);
    if (dish.length === 0) return res.status(404).json({ error: '菜品不存在' });

    // 检查是否已评过
    const [exist] = await pool.query('SELECT review_id FROM reviews WHERE user_id=? AND dish_id=?', [req.user.user_id, dish_id]);
    if (exist.length > 0) return res.status(409).json({ error: '已评价过该菜品' });

    const [result] = await pool.query(
      'INSERT INTO reviews (user_id, dish_id, rating, content) VALUES (?, ?, ?, ?)',
      [req.user.user_id, dish_id, rating, content || null]
    );
    res.json({ message: '评价成功', review_id: result.insertId });
  } catch (e) {
    res.status(500).json({ error: '服务器错误' });
  }
});

// DELETE /api/reviews/:id - 删除自己的评价（需登录）
router.delete('/:id', authUser, async (req, res) => {
  try {
    const [rows] = await pool.query('SELECT user_id FROM reviews WHERE review_id=?', [req.params.id]);
    if (rows.length === 0) return res.status(404).json({ error: '评价不存在' });
    if (rows[0].user_id !== req.user.user_id) return res.status(403).json({ error: '无权删除' });

    await pool.query('DELETE FROM reviews WHERE review_id=?', [req.params.id]);
    res.json({ message: '删除成功' });
  } catch (e) {
    res.status(500).json({ error: '服务器错误' });
  }
});

module.exports = router;
