const { dbAsync } = require('../config/database');

// POST /api/positions - Update posisi GPS kendaraan
async function updatePosition(req, res, next) {
  try {
    const { vehicleId, lat, lng, address, timestamp } = req.body;

    if (!vehicleId || lat === undefined || lng === undefined) {
      return res.status(400).json({
        success: false,
        message: 'vehicleId, lat, dan lng wajib diisi'
      });
    }

    // Pastikan kendaraan ada
    const vehicle = await dbAsync.get(
      'SELECT id, name FROM vehicles WHERE id = ?',
      [vehicleId]
    );

    if (!vehicle) {
      return res.status(404).json({
        success: false,
        message: `Kendaraan dengan ID ${vehicleId} tidak ditemukan`
      });
    }

    const posTimestamp = timestamp || new Date().toISOString();
    const posAddress = address || null;

    const result = await dbAsync.run(
      `INSERT INTO positions (vehicle_id, lat, lng, address, timestamp) 
       VALUES (?, ?, ?, ?, ?)`,
      [vehicleId, parseFloat(lat), parseFloat(lng), posAddress, posTimestamp]
    );

    return res.status(201).json({
      success: true,
      message: 'Position updated',
      position: {
        id: result.lastID,
        vehicleId: parseInt(vehicleId),
        lat: parseFloat(lat),
        lng: parseFloat(lng),
        address: posAddress,
        timestamp: posTimestamp
      }
    });
  } catch (error) {
    next(error);
  }
}

// GET /api/positions/:vehicleId - Get posisi terakhir kendaraan
async function getLatestPosition(req, res, next) {
  try {
    const { vehicleId } = req.params;

    // Pastikan kendaraan ada
    const vehicle = await dbAsync.get(
      'SELECT id, name FROM vehicles WHERE id = ?',
      [vehicleId]
    );

    if (!vehicle) {
      return res.status(404).json({
        success: false,
        message: `Kendaraan dengan ID ${vehicleId} tidak ditemukan`
      });
    }

    const position = await dbAsync.get(
      `SELECT id, vehicle_id, lat, lng, address, timestamp 
       FROM positions 
       WHERE vehicle_id = ? 
       ORDER BY timestamp DESC, id DESC 
       LIMIT 1`,
      [vehicleId]
    );

    if (!position) {
      return res.status(404).json({
        success: false,
        message: `Belum ada data posisi untuk kendaraan ID ${vehicleId}`
      });
    }

    return res.status(200).json({
      success: true,
      position: {
        id: position.id,
        vehicleId: position.vehicle_id,
        lat: position.lat,
        lng: position.lng,
        address: position.address || '',
        timestamp: position.timestamp
      }
    });
  } catch (error) {
    next(error);
  }
}

// GET /api/positions/:vehicleId/history - Get riwayat perjalanan kendaraan
async function getPositionHistory(req, res, next) {
  try {
    const { vehicleId } = req.params;
    const limit = parseInt(req.query.limit) || 100;

    // Pastikan kendaraan ada
    const vehicle = await dbAsync.get(
      'SELECT id, name FROM vehicles WHERE id = ?',
      [vehicleId]
    );

    if (!vehicle) {
      return res.status(404).json({
        success: false,
        message: `Kendaraan dengan ID ${vehicleId} tidak ditemukan`
      });
    }

    const history = await dbAsync.all(
      `SELECT id, vehicle_id, lat, lng, address, timestamp 
       FROM positions 
       WHERE vehicle_id = ? 
       ORDER BY timestamp ASC 
       LIMIT ?`,
      [vehicleId, limit]
    );

    const formattedHistory = history.map((pos) => ({
      id: pos.id,
      vehicleId: pos.vehicle_id,
      lat: pos.lat,
      lng: pos.lng,
      address: pos.address || '',
      timestamp: pos.timestamp
    }));

    return res.status(200).json({
      success: true,
      vehicle: {
        id: vehicle.id,
        name: vehicle.name
      },
      count: formattedHistory.length,
      history: formattedHistory
    });
  } catch (error) {
    next(error);
  }
}

module.exports = {
  updatePosition,
  getLatestPosition,
  getPositionHistory
};
