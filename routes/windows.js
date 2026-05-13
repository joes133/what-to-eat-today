const router = require('express').Router();
const pool = require('../db');

// GET /api/windows/random - random dish
router.get('/random', async (req, res) => {
  try {
    const [rows] = await pool.query(`
      SELECT d.dish_id, d.name, d.price,
             w.name AS window_name, w.color,
             ROUND(AVG(r.rating), 1) AS avg_rating,
             COUNT(r.review_id) AS review_count
      FROM dishes d
      JOIN windows w ON w.window_id = d.window_id
      LEFT JOIN reviews r ON r.dish_id = d.dish_id
      WHERE d.is_active = 1
      GROUP BY d.dish_id
      ORDER BY RAND()
      LIMIT 1
    `);
    if (rows.length === 0) return res.json(null);
    res.json(rows[0]);
  } catch (e) {
    console.error(e);
    res.status(500).json({ error: 'server error' });
  }
});

// GET /api/windows - list all windows
router.get('/', async (req, res) => {
  try {
    const [rows] = await pool.query(`
      SELECT w.window_id, w.name, w.color, w.description,
             ROUND(AVG(r.rating), 1) AS avg_rating,
             COUNT(DISTINCT r.review_id) AS review_count
      FROM windows w
      LEFT JOIN dishes d ON d.window_id = w.window_id AND d.is_active = 1
      LEFT JOIN reviews r ON r.dish_id = d.dish_id
      GROUP BY w.window_id
      ORDER BY w.window_id
    `);
    res.json(rows);
  } catch (e) {
    res.status(500).json({ error: 'server error' });
  }
});

// GET /api/windows/:id/dishes - dishes in a window
router.get('/:id/dishes', async (req, res) => {
  try {
    const [rows] = await pool.query(`
      SELECT d.dish_id, d.name, d.price, d.is_active,
             ROUND(AVG(r.rating), 1) AS avg_rating,
             COUNT(r.review_id) AS review_count
      FROM dishes d
      LEFT JOIN reviews r ON r.dish_id = d.dish_id
      WHERE d.window_id = ? AND d.is_active = 1
      GROUP BY d.dish_id
      ORDER BY d.dish_id
    `, [req.params.id]);
    res.json(rows);
  } catch (e) {
    res.status(500).json({ error: 'server error' });
  }
});

module.exports = router;
