const { pool } = require('../config/db');

async function getAlerts(req, res) {
  try {
    const { farm_id, acknowledged } = req.query;
    let query = 'SELECT * FROM alerts_log WHERE 1=1';
    const params = [];

    if (farm_id) { query += ' AND farm_id = ?'; params.push(farm_id); }
    if (acknowledged !== undefined) {
      query += ' AND acknowledged = ?';
      params.push(acknowledged === 'true' ? 1 : 0);
    }
    query += ' ORDER BY triggered_at DESC LIMIT 100';

    const [rows] = await pool.query(query, params);
    res.json({ success: true, data: rows });
  } catch (err) {
    res.status(500).json({ success: false, message: 'Erreur serveur' });
  }
}

async function createAlert(req, res) {
  try {
    const { farm_id, sensor_id, parameter, alert_level, valeur, seuil, message } = req.body;

    if (!farm_id || !sensor_id || !parameter || !alert_level || valeur === undefined || !message) {
      return res.status(400).json({ success: false, message: 'Champs manquants' });
    }

    await pool.query(
      `INSERT INTO alerts_log (farm_id, sensor_id, parameter, alert_level, valeur, seuil, message)
       VALUES (?, ?, ?, ?, ?, ?, ?)`,
      [farm_id, sensor_id, parameter, alert_level, valeur, seuil || null, message]
    );

    res.status(201).json({ success: true, message: 'Alerte créée' });
  } catch (err) {
    res.status(500).json({ success: false, message: 'Erreur serveur' });
  }
}

async function acknowledgeAlert(req, res) {
  try {
    const { id } = req.params;

    const [alert] = await pool.query('SELECT * FROM alerts_log WHERE id = ?', [id]);
    if (alert.length === 0) {
      return res.status(404).json({ success: false, message: 'Alerte non trouvée' });
    }

    await pool.query(
      'UPDATE alerts_log SET acknowledged = 1, acked_by = ?, acked_at = NOW() WHERE id = ?',
      [req.user.id, id]
    );

    res.json({ success: true, message: 'Alerte acquittée' });
  } catch (err) {
    res.status(500).json({ success: false, message: 'Erreur serveur' });
  }
}

async function getAlertRules(req, res) {
  try {
    const { sensor_id } = req.query;
    let query = `
      SELECT ar.*, s.type as sensor_type, s.unite
      FROM alert_rules ar
      JOIN sensors s ON ar.sensor_id = s.id
      WHERE ar.is_active = 1
    `;
    const params = [];
    if (sensor_id) { query += ' AND ar.sensor_id = ?'; params.push(sensor_id); }

    const [rows] = await pool.query(query, params);
    res.json({ success: true, data: rows });
  } catch (err) {
    res.status(500).json({ success: false, message: 'Erreur serveur' });
  }
}

module.exports = { getAlerts, createAlert, acknowledgeAlert, getAlertRules };