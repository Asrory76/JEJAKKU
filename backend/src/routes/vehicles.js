const express = require('express');
const router = express.Router();
const vehicleController = require('../controllers/vehicleController');
const { verifyToken } = require('../middleware/auth');

// Middleware verifyToken otomatis mengisi req.user (default fallback userId: 1 jika tidak ada header di masa development)
router.use(verifyToken);

// GET /api/vehicles - Get semua kendaraan milik user
router.get('/', vehicleController.getVehicles);

// POST /api/vehicles - Tambah kendaraan baru
router.post('/', vehicleController.createVehicle);

// GET /api/vehicles/:id - Get detail kendaraan
router.get('/:id', vehicleController.getVehicleById);

// DELETE /api/vehicles/:id - Hapus kendaraan
router.delete('/:id', vehicleController.deleteVehicle);

module.exports = router;
