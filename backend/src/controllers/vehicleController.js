const { dbAsync } = require('../config/database');

// GET /api/vehicles - Get semua kendaraan
async function getVehicles(req, res, next) {
  try {
    const userId = req.user ? req.user.id : 1;

    // Ambil data kendaraan beserta posisi terakhir jika ada
    const vehicles = await dbAsync.all(
      `SELECT v.id, v.user_id, v.name, v.plate, v.is_motor, v.status, v.created_at,
              p.lat as last_lat, p.lng as last_lng, p.address as last_address, p.timestamp as last_seen
       FROM vehicles v
       LEFT JOIN (
         SELECT p1.*
         FROM positions p1
         INNER JOIN (
           SELECT vehicle_id, MAX(id) as max_id
           FROM positions
           GROUP BY vehicle_id
         ) p2 ON p1.id = p2.max_id
       ) p ON v.id = p.vehicle_id
       WHERE v.user_id = ?
       ORDER BY v.id ASC`,
      [userId]
    );

    const formatted = vehicles.map((v) => ({
      id: v.id,
      userId: v.user_id,
      name: v.name,
      plate: v.plate,
      isMotor: Boolean(v.is_motor),
      status: v.status || 'connected',
      createdAt: v.created_at,
      lastPosition: v.last_lat !== null ? {
        lat: v.last_lat,
        lng: v.last_lng,
        address: v.last_address,
        timestamp: v.last_seen
      } : null
    }));

    return res.status(200).json({
      success: true,
      vehicles: formatted
    });
  } catch (error) {
    next(error);
  }
}

// GET /api/vehicles/:id - Get detail kendaraan
async function getVehicleById(req, res, next) {
  try {
    const { id } = req.params;

    const vehicle = await dbAsync.get(
      `SELECT id, user_id, name, plate, is_motor, status, created_at 
       FROM vehicles 
       WHERE id = ?`,
      [id]
    );

    if (!vehicle) {
      return res.status(404).json({
        success: false,
        message: `Kendaraan dengan ID ${id} tidak ditemukan`
      });
    }

    const latestPosition = await dbAsync.get(
      `SELECT lat, lng, address, timestamp 
       FROM positions 
       WHERE vehicle_id = ? 
       ORDER BY timestamp DESC, id DESC 
       LIMIT 1`,
      [id]
    );

    return res.status(200).json({
      success: true,
      vehicle: {
        id: vehicle.id,
        userId: vehicle.user_id,
        name: vehicle.name,
        plate: vehicle.plate,
        isMotor: Boolean(vehicle.is_motor),
        status: vehicle.status,
        createdAt: vehicle.created_at,
        lastPosition: latestPosition || null
      }
    });
  } catch (error) {
    next(error);
  }
}

// POST /api/vehicles - Tambah kendaraan baru
async function createVehicle(req, res, next) {
  try {
    const userId = req.user ? req.user.id : 1;
    const { name, plate, isMotor, status } = req.body;

    if (!name || !plate) {
      return res.status(400).json({
        success: false,
        message: 'Nama kendaraan dan plat nomor wajib diisi'
      });
    }

    // Cek plat nomor duplikat
    const existing = await dbAsync.get(
      'SELECT id FROM vehicles WHERE plate = ?',
      [plate.trim().toUpperCase()]
    );

    if (existing) {
      return res.status(409).json({
        success: false,
        message: 'Kendaraan dengan plat nomor tersebut sudah terdaftar'
      });
    }

    const isMotorVal = isMotor !== undefined ? (isMotor ? 1 : 0) : 1;
    const vehicleStatus = status ? status.trim() : 'connected';

    const result = await dbAsync.run(
      `INSERT INTO vehicles (user_id, name, plate, is_motor, status) 
       VALUES (?, ?, ?, ?, ?)`,
      [userId, name.trim(), plate.trim().toUpperCase(), isMotorVal, vehicleStatus]
    );

    const newVehicle = {
      id: result.lastID,
      userId,
      name: name.trim(),
      plate: plate.trim().toUpperCase(),
      isMotor: Boolean(isMotorVal),
      status: vehicleStatus
    };

    return res.status(201).json({
      success: true,
      message: 'Kendaraan berhasil ditambahkan',
      vehicle: newVehicle
    });
  } catch (error) {
    next(error);
  }
}

// DELETE /api/vehicles/:id - Hapus kendaraan
async function deleteVehicle(req, res, next) {
  try {
    const { id } = req.params;

    const existing = await dbAsync.get(
      'SELECT id, name FROM vehicles WHERE id = ?',
      [id]
    );

    if (!existing) {
      return res.status(404).json({
        success: false,
        message: `Kendaraan dengan ID ${id} tidak ditemukan`
      });
    }

    // Hapus posisi terkait terlebih dahulu (safety jika pragma off)
    await dbAsync.run('DELETE FROM positions WHERE vehicle_id = ?', [id]);
    await dbAsync.run('DELETE FROM vehicles WHERE id = ?', [id]);

    return res.status(200).json({
      success: true,
      message: 'Vehicle deleted successfully'
    });
  } catch (error) {
    next(error);
  }
}

module.exports = {
  getVehicles,
  getVehicleById,
  createVehicle,
  deleteVehicle
};
