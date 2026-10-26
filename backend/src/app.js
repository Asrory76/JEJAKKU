const express = require('express');
const cors = require('cors');
const morgan = require('morgan');
const dotenv = require('dotenv');
const { initDatabase } = require('./config/database');
const requestLogger = require('./middleware/logger');

// Load environment variables
dotenv.config();

const app = express();
const PORT = process.env.PORT || 3000;

// ==========================================
// MIDDLEWARES
// ==========================================

// Enable CORS untuk Flutter Web & Mobile
app.use(cors({
  origin: '*',
  methods: ['GET', 'POST', 'PUT', 'DELETE', 'OPTIONS'],
  allowedHeaders: ['Content-Type', 'Authorization']
}));

// Body parser
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// Request loggers
app.use(morgan('dev'));
app.use(requestLogger);

// ==========================================
// ROUTES
// ==========================================

const authRoutes = require('./routes/auth');
const vehicleRoutes = require('./routes/vehicles');
const positionRoutes = require('./routes/positions');

// Base info endpoint
app.get('/', (req, res) => {
  res.json({
    name: 'JEJAKKU GPS Tracker API',
    version: '1.0.0',
    status: 'online',
    endpoints: {
      auth: ['POST /api/auth/login', 'POST /api/auth/register'],
      vehicles: [
        'GET /api/vehicles',
        'POST /api/vehicles',
        'GET /api/vehicles/:id',
        'DELETE /api/vehicles/:id'
      ],
      positions: [
        'POST /api/positions',
        'GET /api/positions/:vehicleId',
        'GET /api/positions/:vehicleId/history'
      ],
      health: 'GET /api/health'
    }
  });
});

// Health check endpoint
app.get('/api/health', (req, res) => {
  res.json({
    status: 'ok',
    uptime: process.uptime(),
    timestamp: new Date().toISOString()
  });
});

// API Endpoints
app.use('/api/auth', authRoutes);
app.use('/api/vehicles', vehicleRoutes);
app.use('/api/positions', positionRoutes);

// ==========================================
// ERROR HANDLING
// ==========================================

// 404 Handler
app.use((req, res, next) => {
  res.status(404).json({
    success: false,
    message: `Endpoint ${req.method} ${req.originalUrl} tidak ditemukan`
  });
});

// Centralized 500 Error Handler
app.use((err, req, res, next) => {
  console.error(' Server Error:', err);
  const status = err.status || 500;
  res.status(status).json({
    success: false,
    message: err.message || 'Terjadi kesalahan pada server internal',
    ...(process.env.NODE_ENV === 'development' && { stack: err.stack })
  });
});

// ==========================================
// START SERVER
// ==========================================

async function startServer() {
  try {
    // Inisialisasi skema tabel & seed dummy data
    await initDatabase();

    app.listen(PORT, () => {
      console.log('====================================================');
      console.log(` JEJAKKU Backend Server running on port ${PORT}`);
      console.log(` Local URL : http://localhost:${PORT}`);
      console.log(` Android Emulator URL : http://10.0.2.2:${PORT}`);
      console.log('====================================================');
    });
  } catch (error) {
    console.error('❌ Gagal menjalankan server:', error);
    process.exit(1);
  }
}

startServer();

module.exports = app;
