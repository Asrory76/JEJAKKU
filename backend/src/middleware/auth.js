const jwt = require('jsonwebtoken');

const JWT_SECRET = process.env.JWT_SECRET || 'jejakku_super_secret_jwt_key_2026';

function verifyToken(req, res, next) {
  const authHeader = req.headers['authorization'];
  
  if (!authHeader) {
    // Mode fleksibel untuk development: gunakan default user_id 1 jika tidak ada token
    req.user = { id: 1, username: 'aryacahyo', name: 'Arya Cahyo' };
    return next();
  }

  const token = authHeader.startsWith('Bearer ')
    ? authHeader.slice(7)
    : authHeader;

  try {
    const decoded = jwt.verify(token, JWT_SECRET);
    req.user = decoded;
    next();
  } catch (err) {
    return res.status(401).json({
      success: false,
      message: 'Token tidak valid atau telah kedaluwarsa'
    });
  }
}

// Middleware jika endpoint mewajibkan token valid
function requireAuth(req, res, next) {
  const authHeader = req.headers['authorization'];
  if (!authHeader) {
    return res.status(401).json({
      success: false,
      message: 'Authorization token diperlukan'
    });
  }

  const token = authHeader.startsWith('Bearer ')
    ? authHeader.slice(7)
    : authHeader;

  try {
    const decoded = jwt.verify(token, JWT_SECRET);
    req.user = decoded;
    next();
  } catch (err) {
    return res.status(401).json({
      success: false,
      message: 'Token tidak valid atau telah kedaluwarsa'
    });
  }
}

module.exports = {
  verifyToken,
  requireAuth
};
