const jwt = require('jsonwebtoken');
const SECRET = 'canteen_secret_2026';

// 普通用户认证
function authUser(req, res, next) {
  const token = req.headers['authorization']?.split(' ')[1];
  if (!token) return res.status(401).json({ error: '未登录' });
  try {
    req.user = jwt.verify(token, SECRET);
    next();
  } catch {
    res.status(401).json({ error: 'Token无效' });
  }
}

// 管理员认证
function authAdmin(req, res, next) {
  const token = req.headers['authorization']?.split(' ')[1];
  if (!token) return res.status(401).json({ error: '未登录' });
  try {
    const payload = jwt.verify(token, SECRET);
    if (payload.role !== 'admin') return res.status(403).json({ error: '无权限' });
    req.admin = payload;
    next();
  } catch {
    res.status(401).json({ error: 'Token无效' });
  }
}

module.exports = { authUser, authAdmin, SECRET };
