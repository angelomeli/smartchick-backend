const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const { pool } = require('../config/db');

async function login(req, res) {
  try {
    const { email, password } = req.body;
    if (!email || !password) {
      return res.status(400).json({ success: false, message: 'Email et mot de passe requis' });
    }
    const [rows] = await pool.query(
      'SELECT * FROM users WHERE email = ? AND is_active = 1', [email]
    );
    if (rows.length === 0) {
      return res.status(401).json({ success: false, message: 'Email ou mot de passe incorrect' });
    }
    const user = rows[0];
    const validPassword = await bcrypt.compare(password, user.password_hash);
    if (!validPassword) {
      return res.status(401).json({ success: false, message: 'Email ou mot de passe incorrect' });
    }
    const token = jwt.sign(
      { id: user.id, email: user.email, role: user.role },
      process.env.JWT_SECRET,
      { expiresIn: process.env.JWT_EXPIRES_IN || '7d' }
    );
    res.json({
      success: true,
      message: 'Connexion reussie',
      token,
      user: { id: user.id, nom: user.nom, prenom: user.prenom, email: user.email, role: user.role },
    });
  } catch (err) {
    console.error('Erreur login :', err);
    res.status(500).json({ success: false, message: 'Erreur serveur' });
  }
}

async function register(req, res) {
  try {
    const { nom, prenom, email, password, role } = req.body;
    if (!nom || !prenom || !email || !password) {
      return res.status(400).json({ success: false, message: 'Tous les champs sont requis' });
    }
    const [existing] = await pool.query('SELECT id FROM users WHERE email = ?', [email]);
    if (existing.length > 0) {
      return res.status(409).json({ success: false, message: 'Email deja utilise' });
    }
    const hash = await bcrypt.hash(password, 12);
    await pool.query(
      'INSERT INTO users (nom, prenom, email, password_hash, role) VALUES (?, ?, ?, ?, ?)',
      [nom, prenom, email, hash, role || 'observateur']
    );
    res.status(201).json({ success: true, message: 'Compte cree avec succes' });
  } catch (err) {
    console.error('Erreur register :', err);
    res.status(500).json({ success: false, message: 'Erreur serveur' });
  }
}

async function getMe(req, res) {
  try {
    const [rows] = require('../config/db').pool.query(
      'SELECT id, nom, prenom, email, role, created_at FROM users WHERE id = ?', [req.user.id]
    );
    if (rows.length === 0) {
      return res.status(404).json({ success: false, message: 'Utilisateur non trouve' });
    }
    res.json({ success: true, user: rows[0] });
  } catch (err) {
    res.status(500).json({ success: false, message: 'Erreur serveur' });
  }
}

module.exports = { login, register, getMe };