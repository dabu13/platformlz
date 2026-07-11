const express = require('express');
const helmet = require('helmet');
const app = express();
const port = process.env.PORT || 8080;

app.use(helmet());
app.use(express.static('public'));

app.get('/', (req, res) => {
  res.sendFile(__dirname + '/public/index.html');
});

app.get('/api/health', (req, res) => {
  res.json({ status: 'ok', service: 'platformlz-demo', timestamp: new Date().toISOString() });
});

app.listen(port, () => {
  console.log(`PlatformLZ demo app listening on port ${port}`);
});
