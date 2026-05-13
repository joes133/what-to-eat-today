const express = require('express');
const cors = require('cors');
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

app.get('/api/ping', (req, res) => res.json({ ok: true }));
app.get('/api/ping2', (req, res) => res.json({ ok: true, random: 'test' }));

const PORT = 3000;
app.listen(PORT, () => {
  console.log(`服务器运行中: http://localhost:${PORT}`);
});
