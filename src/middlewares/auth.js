const jwt = require('jsonwebtoken');

function authMiddleware(req, res, next) {
  const authHeader = req.headers['authorization'];
  const token = authHeader && authHeader.split(' ')[1];

  if (!token) {
    return res.status(401).json({ success: false, message: 'Token manquant' });
  }

  try {
    const decoded = jwt.verify(token, process.env.JWT_SECRET);
    req.user = decoded;
    next();
  } catch (err) {
    return res.status(403).json({ success: false, message: 'Token invalide ou expiré' });
  }
}

function adminOnly(req, res, next) {
  if (req.user.role !== 'admin') {
    return res.status(403).json({ success: false, message: 'Accès réservé aux administrateurs' });
  }
  next();
}

function eleveurOrAdmin(req, res, next) {
  if (!['admin', 'eleveur'].includes(req.user.role)) {
    return res.status(403).json({ success: false, message: 'Accès non autorisé' });
  }
  next();
}

module.exports = { authMiddleware, adminOnly, eleveurOrAdmin };