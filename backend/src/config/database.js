const sqlite3 = require('sqlite3').verbose();
const path = require('path');
const dotenv = require('dotenv');

dotenv.config();

const dbPath = process.env.DB_FILE 
  ? path.resolve(process.cwd(), process.env.DB_FILE)
  : path.join(__dirname, '../../database.sqlite');

const db = new sqlite3.Database(dbPath, (err) => {
  if (err) {
    console.error('❌ Gagal membuka database SQLite:', err.message);
  } else {
    console.log(` Connected to SQLite database at: ${dbPath}`);
  }
});

// Helper functions for Promise-based queries
const dbAsync = {
  db,
  
  run(sql, params = []) {
    return new Promise((resolve, reject) => {
      db.run(sql, params, function (err) {
        if (err) return reject(err);
        resolve({ lastID: this.lastID, changes: this.changes });
      });
    });
  },

  get(sql, params = []) {
    return new Promise((resolve, reject) => {
      db.get(sql, params, (err, row) => {
        if (err) return reject(err);
        resolve(row);
      });
    });
  },

  all(sql, params = []) {
    return new Promise((resolve, reject) => {
      db.all(sql, params, (err, rows) => {
        if (err) return reject(err);
        resolve(rows);
      });
    });
  },

  exec(sql) {
    return new Promise((resolve, reject) => {
      db.exec(sql, (err) => {
        if (err) return reject(err);
        resolve();
      });
    });
  }
};

// Inisialisasi Skema & Seed Data
async function initDatabase() {
  try {
    // Aktifkan foreign key constraint
    await dbAsync.run('PRAGMA foreign_keys = ON;');

    // 1. Users Table
    await dbAsync.run(`
      CREATE TABLE IF NOT EXISTS users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        username TEXT UNIQUE NOT NULL,
        email TEXT UNIQUE NOT NULL,
        password TEXT NOT NULL,
        name TEXT,
        created_at DATETIME DEFAULT CURRENT_TIMESTAMP
      );
    `);

    // 2. Vehicles Table
    await dbAsync.run(`
      CREATE TABLE IF NOT EXISTS vehicles (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        name TEXT NOT NULL,
        plate TEXT UNIQUE NOT NULL,
        is_motor BOOLEAN DEFAULT 1,
        status TEXT DEFAULT 'connected',
        created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
      );
    `);

    // 3. Positions Table
    await dbAsync.run(`
      CREATE TABLE IF NOT EXISTS positions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        vehicle_id INTEGER NOT NULL,
        lat REAL NOT NULL,
        lng REAL NOT NULL,
        address TEXT,
        timestamp DATETIME DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (vehicle_id) REFERENCES vehicles(id) ON DELETE CASCADE
      );
    `);

    console.log(' Database tables verified/initialized.');

    // Cek apakah database perlu di-seed
    const userCount = await dbAsync.get('SELECT COUNT(*) as count FROM users');
    if (userCount.count === 0) {
      console.log('🌱 Seeding database with initial dummy data...');

      // Seed 1 User
      const userResult = await dbAsync.run(
        `INSERT INTO users (username, email, password, name) 
         VALUES (?, ?, ?, ?)`,
        ['aryacahyo', 'arya@jejakku.com', 'password123', 'Arya Cahyo']
      );
      const userId = userResult.lastID;

      // Seed 2 Vehicles
      const v1Result = await dbAsync.run(
        `INSERT INTO vehicles (user_id, name, plate, is_motor, status) 
         VALUES (?, ?, ?, ?, ?)`,
        [userId, 'Honda Vario 160', 'AB 1234 XY', 1, 'connected']
      );
      const v1Id = v1Result.lastID;

      const v2Result = await dbAsync.run(
        `INSERT INTO vehicles (user_id, name, plate, is_motor, status) 
         VALUES (?, ?, ?, ?, ?)`,
        [userId, 'Toyota Avanza', 'AB 5678 CD', 0, 'connected']
      );
      const v2Id = v2Result.lastID;

      // Seed Initial Positions
      const now = new Date();
      const tenMinsAgo = new Date(now.getTime() - 10 * 60000).toISOString();
      const fiveMinsAgo = new Date(now.getTime() - 5 * 60000).toISOString();
      const justNow = now.toISOString();

      // Positions for Vehicle 1 (Honda Vario)
      await dbAsync.run(
        `INSERT INTO positions (vehicle_id, lat, lng, address, timestamp) 
         VALUES (?, ?, ?, ?, ?)`,
        [v1Id, -7.7956, 110.3695, 'Jl. Malioboro, Danurejan, Yogyakarta', tenMinsAgo]
      );
      await dbAsync.run(
        `INSERT INTO positions (vehicle_id, lat, lng, address, timestamp) 
         VALUES (?, ?, ?, ?, ?)`,
        [v1Id, -7.7828, 110.3670, 'Tugu Pal Putih, Jetis, Yogyakarta', fiveMinsAgo]
      );
      await dbAsync.run(
        `INSERT INTO positions (vehicle_id, lat, lng, address, timestamp) 
         VALUES (?, ?, ?, ?, ?)`,
        [v1Id, -7.7705, 110.3776, 'Kawasan Bundaran UGM, Sleman, Yogyakarta', justNow]
      );

      // Positions for Vehicle 2 (Toyota Avanza)
      await dbAsync.run(
        `INSERT INTO positions (vehicle_id, lat, lng, address, timestamp) 
         VALUES (?, ?, ?, ?, ?)`,
        [v2Id, -7.7569, 110.3784, 'Jl. Kaliurang KM 5, Sleman, Yogyakarta', fiveMinsAgo]
      );
      await dbAsync.run(
        `INSERT INTO positions (vehicle_id, lat, lng, address, timestamp) 
         VALUES (?, ?, ?, ?, ?)`,
        [v2Id, -7.7492, 110.3855, 'Jl. Ring Road Utara, Depok, Sleman', justNow]
      );

      console.log(' Seed data inserted successfully!');
    }
  } catch (error) {
    console.error('❌ Error initializing database:', error);
  }
}

module.exports = {
  db,
  dbAsync,
  initDatabase
};
