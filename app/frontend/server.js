const express = require('express');
const { createProxyMiddleware } = require('http-proxy-middleware');
const path = require('path');

const app = express();
const port = 3000;
const backendUrl = process.env.BACKEND_URL || 'http://localhost:8080';


app.use(express.static(path.join(__dirname, 'public')));

// Proxy API requests to the backen
app.use('/api', createProxyMiddleware({
  target: backendUrl,
  changeOrigin: true
}));

app.get('*', (req, res) => {
  res.sendFile(path.join(__dirname, 'public/index.html'));
});

app.listen(port, () => {
  console.log(`Frontend server http://localhost:${port}`);
});
