const express = require('express');
const router = express.Router();
const positionController = require('../controllers/positionController');
const { verifyToken } = require('../middleware/auth');

router.use(verifyToken);

// POST /api/positions - Update posisi GPS kendaraan
router.post('/', positionController.updatePosition);

// GET /api/positions/:vehicleId/history - Get riwayat perjalanan (harus sebelum :vehicleId)
router.get('/:vehicleId/history', positionController.getPositionHistory);

// GET /api/positions/:vehicleId - Get posisi terakhir kendaraan
router.get('/:vehicleId', positionController.getLatestPosition);

module.exports = router;
