const mysql = require('mysql2/promise');

const pool = mysql.createPool({
  host:     process.env.DB_HOST     || 'localhost',
  port:     process.env.DB_PORT     || 3306,
  user:     process.env.DB_USER     || 'root',
  password: process.env.DB_PASSWORD || '',
  database: process.env.DB_NAME     || 'smartchick_db',
  waitForConnections: true,
  connectionLimit:    10,
  queueLimit:         0,
  timezone: '+00:00',
});

async function testConnection() {
  try {
    const conn = await pool.getConnection();
    console.log('✅ MySQL connecté — smartchick_db');
    conn.release();
  } catch (err) {
    console.error('❌ Erreur MySQL :', err.message);
    process.exit(1);
  }
}

module.exports = { pool, testConnection };