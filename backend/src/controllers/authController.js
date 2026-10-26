const jwt = require('jsonwebtoken');
const { dbAsync } = require('../config/database');

const JWT_SECRET = process.env.JWT_SECRET || 'jejakku_super_secret_jwt_key_2026';

// POST /api/auth/login
async function login(req, res, next) {
  try {
    const { username, password } = req.body;

    if (!username || !password) {
      return res.status(400).json({
        success: false,
        message: 'Username dan password wajib diisi'
      });
    }

    const user = await dbAsync.get(
      'SELECT id, username, email, password, name FROM users WHERE username = ?',
      [username.trim()]
    );

    if (!user || user.password !== password) {
      return res.status(401).json({
        success: false,
        message: 'Username atau password tidak cocok'
      });
    }

    const token = jwt.sign(
      {
        id: user.id,
        username: user.username,
        email: user.email,
        name: user.name || user.username
      },
      JWT_SECRET,
      { expiresIn: '7d' }
    );

    return res.status(200).json({
      success: true,
      user: {
        id: user.id,
        name: user.name || user.username,
        username: user.username,
        email: user.email
      },
      token
    });
  } catch (error) {
    next(error);
  }
}

// POST /api/auth/register
async function register(req, res, next) {
  try {
    const { username, email, password, name } = req.body;

    if (!username || !email || !password) {
      return res.status(400).json({
        success: false,
        message: 'Username, email, dan password wajib diisi'
      });
    }

    // Cek apakah username atau email sudah terdaftar
    const existing = await dbAsync.get(
      'SELECT id, username, email FROM users WHERE username = ? OR email = ?',
      [username.trim(), email.trim()]
    );

    if (existing) {
      return res.status(409).json({
        success: false,
        message: existing.username === username.trim()
          ? 'Username sudah digunakan'
          : 'Email sudah terdaftar'
      });
    }

    const displayName = name ? name.trim() : username.trim();

    const result = await dbAsync.run(
      `INSERT INTO users (username, email, password, name) VALUES (?, ?, ?, ?)`,
      [username.trim(), email.trim(), password, displayName]
    );

    return res.status(201).json({
      success: true,
      message: 'User registered successfully',
      user: {
        id: result.lastID,
        username: username.trim(),
        name: displayName,
        email: email.trim()
      }
    });
  } catch (error) {
    next(error);
  }
}

module.exports = {
  login,
  register
};
