require('dotenv').config();
const express = require('express');
const cors    = require('cors');
const morgan  = require('morgan');
const { testConnection } = require('./src/config/db');
const routes             = require('./src/routes/index');
const app  = express();
const PORT = process.env.PORT || 3000;
app.use(cors());
app.use(express.json());
app.use(express.urlencoded({ extended: true }));
app.use(morgan('dev'));
app.use('/api', routes);
app.get('/', (req, res) => {
  res.json({
    success: true,
    message: '🐔 SmartChick API — opérationnelle',
    version: '1.0.0',
    endpoints: {
      auth:      '/api/auth/login',
      sensors:   '/api/sensors',
      actuators: '/api/actuators',
      alerts:    '/api/alerts',
    }
  });
});
async function start() {
  await testConnection();
  app.listen(PORT, () => {
    console.log(`🚀 Serveur SmartChick démarré sur http://localhost:${PORT}`);
    console.log(`📡 API disponible sur http://localhost:${PORT}/api`);
  });
}
start();