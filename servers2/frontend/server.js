const express = require('express');
const { createProxyMiddleware } = require('http-proxy-middleware');
const path = require('path');

const app = express();
const port = 3000;
const backendUrl = process.env.BACKEND_URL || 'http://localhost:8080';

// Serve static files from the public directory
app.use(express.static(path.join(__dirname, 'public')));

// Proxy API requests to the backend
app.use('/api', createProxyMiddleware({
  target: backendUrl,
  changeOrigin: true
}));

// The "catchall" handler: for any request that doesn't match one above, send back the index.html file.
app.get('*', (req, res) => {
  res.sendFile(path.join(__dirname, 'public/index.html'));
});

app.listen(port, () => {
  console.log(`Frontend server running at http://localhost:${port}`);
});
