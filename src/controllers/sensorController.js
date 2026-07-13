const { pool } = require('../config/db');

async function getAllSensors(req, res) {
  try {
    const { farm_id } = req.query;
    let query = `
      SELECT s.*, c.nom as coop_nom, c.farm_id
      FROM sensors s
      JOIN coops c ON s.coop_id = c.id
      WHERE s.is_active = 1
    `;
    const params = [];
    if (farm_id) { query += ' AND c.farm_id = ?'; params.push(farm_id); }
    query += ' ORDER BY c.nom, s.type';
    const [rows] = await pool.query(query, params);
    res.json({ success: true, data: rows });
  } catch (err) {
    console.error(err);
    res.status(500).json({ success: false, message: 'Erreur serveur' });
  }
}

async function getSensorData(req, res) {
  try {
    const { id } = req.params;
    const { limit = 100, from, to } = req.query;
    let query = `SELECT valeur, unite, recorded_at FROM sensor_data WHERE sensor_id = ?`;
    const params = [id];
    if (from) { query += ' AND recorded_at >= ?'; params.push(from); }
    if (to) { query += ' AND recorded_at <= ?'; params.push(to); }
    query += ' ORDER BY recorded_at DESC LIMIT ?';
    params.push(parseInt(limit));
    const [rows] = await pool.query(query, params);
    res.json({ success: true, data: rows });
  } catch (err) {
    console.error(err);
    res.status(500).json({ success: false, message: 'Erreur serveur' });
  }
}

async function getLatestData(req, res) {
  try {
    const { farm_id } = req.query;
    let query = `
      SELECT sd.sensor_id, sd.farm_id, sd.valeur, sd.unite, sd.recorded_at,
             s.type, s.seuil_min, s.seuil_max
      FROM sensor_data sd
      JOIN sensors s ON sd.sensor_id = s.id
      INNER JOIN (
        SELECT sensor_id, MAX(recorded_at) AS derniere
        FROM sensor_data GROUP BY sensor_id
      ) latest ON sd.sensor_id = latest.sensor_id
              AND sd.recorded_at = latest.derniere
      WHERE 1=1
    `;
    const params = [];
    if (farm_id) { query += ' AND sd.farm_id = ?'; params.push(farm_id); }
    const [rows] = await pool.query(query, params);
    res.json({ success: true, data: rows });
  } catch (err) {
    console.error(err);
    res.status(500).json({ success: false, message: 'Erreur serveur' });
  }
}

async function postSensorData(req, res) {
  try {
    const { sensor_id, farm_id, valeur, unite } = req.body;
    if (!sensor_id || !farm_id || valeur === undefined) {
      return res.status(400).json({ success: false, message: 'Champs manquants' });
    }
    await pool.query(
      'INSERT INTO sensor_data (sensor_id, farm_id, valeur, unite) VALUES (?, ?, ?, ?)',
      [sensor_id, farm_id, valeur, unite || '']
    );
    await pool.query('UPDATE sensors SET last_seen = NOW() WHERE id = ?', [sensor_id]);
    res.status(201).json({ success: true, message: 'Mesure enregistrée' });
  } catch (err) {
    console.error(err);
    res.status(500).json({ success: false, message: 'Erreur serveur' });
  }
}

module.exports = { getAllSensors, getSensorData, getLatestData, postSensorData };