const { pool } = require('../config/db');

async function getAllActuators(req, res) {
  try {
    const { farm_id } = req.query;
    let query = `
      SELECT a.*, c.nom as coop_nom
      FROM actuators a
      JOIN coops c ON a.coop_id = c.id
      WHERE 1=1
    `;
    const params = [];
    if (farm_id) { query += ' AND c.farm_id = ?'; params.push(farm_id); }
    query += ' ORDER BY a.type';

    const [rows] = await pool.query(query, params);
    res.json({ success: true, data: rows });
  } catch (err) {
    res.status(500).json({ success: false, message: 'Erreur serveur' });
  }
}

async function controlActuator(req, res) {
  try {
    const { id } = req.params;
    const { etat, puissance, mode } = req.body;

    const [actuator] = await pool.query('SELECT * FROM actuators WHERE id = ?', [id]);
    if (actuator.length === 0) {
      return res.status(404).json({ success: false, message: 'Actionneur non trouvé' });
    }

    await pool.query(
      'UPDATE actuators SET etat = ?, puissance = ?, mode = ?, updated_at = NOW() WHERE id = ?',
      [etat ? 1 : 0, puissance ?? actuator[0].puissance, mode || actuator[0].mode, id]
    );

    await pool.query(
      `INSERT INTO actuator_logs (actuator_id, farm_id, coop_id, type_act, action, puissance, triggered_by, user_id)
       SELECT ?, c.farm_id, a.coop_id, a.type, ?, ?, 'manuel', ?
       FROM actuators a JOIN coops c ON a.coop_id = c.id WHERE a.id = ?`,
      [id, etat ? 'on' : 'off', puissance ?? 0, req.user.id, id]
    );

    res.json({ success: true, message: `Actionneur ${etat ? 'activé' : 'désactivé'}` });
  } catch (err) {
    res.status(500).json({ success: false, message: 'Erreur serveur' });
  }
}

async function getActuatorLogs(req, res) {
  try {
    const { id } = req.params;
    const [rows] = await pool.query(
      'SELECT * FROM actuator_logs WHERE actuator_id = ? ORDER BY logged_at DESC LIMIT 50',
      [id]
    );
    res.json({ success: true, data: rows });
  } catch (err) {
    res.status(500).json({ success: false, message: 'Erreur serveur' });
  }
}

module.exports = { getAllActuators, controlActuator, getActuatorLogs };