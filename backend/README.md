#  JEJAKKU GPS Tracker - Backend REST API

Backend REST API untuk aplikasi mobile **JEJAKKU (GPS Tracker)** berbasis Node.js, Express.js, dan SQLite.

---

##  Daftar Isi
- [Fitur Utama](#-fitur-utama)
- [Teknologi](#-teknologi)
- [Struktur Direktori](#-struktur-direktori)
- [Panduan Instalasi & Menjalankan](#-panduan-instalasi--menjalankan)
- [Koneksi dari Flutter](#-koneksi-dari-flutter)
- [Dokumentasi API](#-dokumentasi-api)
  - [1. Authentication](#1-authentication)
  - [2. Vehicle Management](#2-vehicle-management)
  - [3. GPS Tracking](#3-gps-tracking)
- [Contoh Pengujian (cURL / PowerShell)](#-contoh-pengujian-curl--powershell)
- [Database & Dummy Data](#-database--dummy-data)

---

##  Fitur Utama
- **Autentikasi Pengguna**: Login & Register dengan JSON Web Token (JWT).
- **Manajemen Armada (Vehicles)**: CRUD armada kendaraan (Mobil / Motor, plat nomor, status).
- **Pelacakan Posisi GPS**: Update posisi real-time, dapatkan koordinat terkini, serta riwayat rute perjalanan.
- **CORS Enabled**: Siap dikonsumsi langsung oleh Flutter Web, Android Emulator, iOS Simulator, dan Perangkat Fisik.
- **Auto Database Initialization & Seeding**: Otomatis membuat tabel SQLite dan mengisi data dummy saat pertama kali dijalankan.
- **Request Logging & Error Handling**: Logging waktu respons request dan penanganan error standar HTTP (400, 401, 404, 409, 500).

---

##  Teknologi
- **Runtime**: Node.js (v18+)
- **Framework**: Express.js
- **Database**: SQLite3 (`database.sqlite`)
- **Autentikasi**: JSON Web Token (`jsonwebtoken`)
- **Utilitas**: `cors`, `dotenv`, `morgan`

---

## 📁 Struktur Direktori
```
backend/
├── src/
│   ├── app.js                   # Entrypoint aplikasi Express & server setup
│   ├── config/
│   │   └── database.js          # Koneksi SQLite, skema tabel & auto-seeder
│   ├── controllers/
│   │   ├── authController.js    # Logika login & register
│   │   ├── vehicleController.js # Logika CRUD kendaraan
│   │   └── positionController.js# Logika tracking GPS & riwayat
│   ├── middleware/
│   │   ├── auth.js              # Verifikasi JWT & fallback user dev
│   │   └── logger.js            # Custom logging request & execution time
│   └── routes/
│       ├── auth.js              # Route /api/auth
│       ├── vehicles.js          # Route /api/vehicles
│       └── positions.js         # Route /api/positions
├── .env                         # Konfigurasi environment variabel
├── .env.example                 # Template environment variabel
├── .gitignore
├── package.json
└── README.md
```

---

## 🚀 Panduan Instalasi & Menjalankan

### 1. Masuk ke folder `backend`
```bash
cd backend
```

### 2. Install dependensi
```bash
npm install
```

### 3. Konfigurasi Environment (Opsional)
File `.env` sudah disediakan secara default:
```env
PORT=3000
NODE_ENV=development
JWT_SECRET=jejakku_super_secret_jwt_key_2026
DB_FILE=./database.sqlite
```

### 4. Jalankan Server
- **Mode Produksi / Standar**:
  ```bash
  npm start
  ```
- **Mode Development (Hot-Reload dengan Nodemon)**:
  ```bash
  npm run dev
  ```

Server akan aktif di `http://localhost:3000`.

---

## 📱 Koneksi dari Flutter

Saat menghubungkan aplikasi Flutter dengan API backend ini, gunakan Base URL yang sesuai dengan platform pengujian:

| Platform Pengujian Flutter | Base URL |
| :--- | :--- |
| **Flutter Web** | `http://localhost:3000` |
| **Android Emulator** | `http://10.0.2.2:3000` |
| **iOS Simulator** | `http://localhost:3000` |
| **HP Fisik (USB Debugging / WiFi)** | `http://<IP-LAPTOP-ANDA>:3000` (contoh: `http://192.168.1.10:3000`) |

---

## 📖 Dokumentasi API

### 1. Authentication

#### A. Login User
- **Endpoint**: `POST /api/auth/login`
- **Request Body**:
  ```json
  {
    "username": "aryacahyo",
    "password": "password123"
  }
  ```
- **Response `200 OK`**:
  ```json
  {
    "success": true,
    "user": {
      "id": 1,
      "name": "Arya Cahyo",
      "username": "aryacahyo",
      "email": "arya@jejakku.com"
    },
    "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVC..."
  }
  ```

#### B. Register User Baru
- **Endpoint**: `POST /api/auth/register`
- **Request Body**:
  ```json
  {
    "username": "budi123",
    "email": "budi@example.com",
    "password": "mypassword",
    "name": "Budi Santoso"
  }
  ```
- **Response `201 Created`**:
  ```json
  {
    "success": true,
    "message": "User registered successfully",
    "user": {
      "id": 2,
      "username": "budi123",
      "name": "Budi Santoso",
      "email": "budi@example.com"
    }
  }
  ```

---

### 2. Vehicle Management

#### A. Get Semua Kendaraan
- **Endpoint**: `GET /api/vehicles`
- **Headers (Opsional)**: `Authorization: Bearer <token>`
- **Response `200 OK`**:
  ```json
  {
    "success": true,
    "vehicles": [
      {
        "id": 1,
        "userId": 1,
        "name": "Honda Vario 160",
        "plate": "AB 1234 XY",
        "isMotor": true,
        "status": "connected",
        "createdAt": "2026-10-26 15:00:00",
        "lastPosition": {
          "lat": -7.7705,
          "lng": 110.3776,
          "address": "Kawasan Bundaran UGM, Sleman, Yogyakarta",
          "timestamp": "2026-10-26T15:10:00.000Z"
        }
      },
      {
        "id": 2,
        "userId": 1,
        "name": "Toyota Avanza",
        "plate": "AB 5678 CD",
        "isMotor": false,
        "status": "connected",
        "createdAt": "2026-10-26 15:00:00",
        "lastPosition": {
          "lat": -7.7492,
          "lng": 110.3855,
          "address": "Jl. Ring Road Utara, Depok, Sleman",
          "timestamp": "2026-10-26T15:10:00.000Z"
        }
      }
    ]
  }
  ```

#### B. Tambah Kendaraan Baru
- **Endpoint**: `POST /api/vehicles`
- **Headers (Opsional)**: `Authorization: Bearer <token>`
- **Request Body**:
  ```json
  {
    "name": "Yamaha NMAX",
    "plate": "AB 9999 ZZ",
    "isMotor": true,
    "status": "connected"
  }
  ```
- **Response `201 Created`**:
  ```json
  {
    "success": true,
    "message": "Kendaraan berhasil ditambahkan",
    "vehicle": {
      "id": 3,
      "userId": 1,
      "name": "Yamaha NMAX",
      "plate": "AB 9999 ZZ",
      "isMotor": true,
      "status": "connected"
    }
  }
  ```

#### C. Get Detail Kendaraan
- **Endpoint**: `GET /api/vehicles/:id`
- **Response `200 OK`**:
  ```json
  {
    "success": true,
    "vehicle": {
      "id": 1,
      "userId": 1,
      "name": "Honda Vario 160",
      "plate": "AB 1234 XY",
      "isMotor": true,
      "status": "connected",
      "createdAt": "2026-10-26 15:00:00",
      "lastPosition": {
        "lat": -7.7705,
        "lng": 110.3776,
        "address": "Kawasan Bundaran UGM, Sleman, Yogyakarta",
        "timestamp": "2026-10-26T15:10:00.000Z"
      }
    }
  }
  ```

#### D. Hapus Kendaraan
- **Endpoint**: `DELETE /api/vehicles/:id`
- **Response `200 OK`**:
  ```json
  {
    "success": true,
    "message": "Vehicle deleted successfully"
  }
  ```

---

### 3. GPS Tracking

#### A. Update Posisi GPS Kendaraan
- **Endpoint**: `POST /api/positions`
- **Request Body**:
  ```json
  {
    "vehicleId": 1,
    "lat": -7.7956,
    "lng": 110.3695,
    "address": "Jl. Malioboro, Danurejan, Yogyakarta",
    "timestamp": "2026-10-26T15:20:00.000Z"
  }
  ```
- **Response `201 Created`**:
  ```json
  {
    "success": true,
    "message": "Position updated",
    "position": {
      "id": 6,
      "vehicleId": 1,
      "lat": -7.7956,
      "lng": 110.3695,
      "address": "Jl. Malioboro, Danurejan, Yogyakarta",
      "timestamp": "2026-10-26T15:20:00.000Z"
    }
  }
  ```

#### B. Get Posisi Terakhir Kendaraan
- **Endpoint**: `GET /api/positions/:vehicleId`
- **Response `200 OK`**:
  ```json
  {
    "success": true,
    "position": {
      "id": 3,
      "vehicleId": 1,
      "lat": -7.7705,
      "lng": 110.3776,
      "address": "Kawasan Bundaran UGM, Sleman, Yogyakarta",
      "timestamp": "2026-10-26T15:10:00.000Z"
    }
  }
  ```

#### C. Get Riwayat Perjalanan Kendaraan
- **Endpoint**: `GET /api/positions/:vehicleId/history?limit=50`
- **Response `200 OK`**:
  ```json
  {
    "success": true,
    "vehicle": {
      "id": 1,
      "name": "Honda Vario 160"
    },
    "count": 3,
    "history": [
      {
        "id": 1,
        "vehicleId": 1,
        "lat": -7.7956,
        "lng": 110.3695,
        "address": "Jl. Malioboro, Danurejan, Yogyakarta",
        "timestamp": "2026-10-26T14:55:00.000Z"
      },
      {
        "id": 2,
        "vehicleId": 1,
        "lat": -7.7828,
        "lng": 110.3670,
        "address": "Tugu Pal Putih, Jetis, Yogyakarta",
        "timestamp": "2026-10-26T15:00:00.000Z"
      },
      {
        "id": 3,
        "vehicleId": 1,
        "lat": -7.7705,
        "lng": 110.3776,
        "address": "Kawasan Bundaran UGM, Sleman, Yogyakarta",
        "timestamp": "2026-10-26T15:05:00.000Z"
      }
    ]
  }
  ```

---

## 🧪 Contoh Pengujian (cURL / PowerShell)

### PowerShell
```powershell
# 1. Login
Invoke-RestMethod -Uri "http://localhost:3000/api/auth/login" -Method POST -ContentType "application/json" -Body '{"username":"aryacahyo","password":"password123"}'

# 2. Get Kendaraan
Invoke-RestMethod -Uri "http://localhost:3000/api/vehicles" -Method GET

# 3. Tambah Kendaraan
Invoke-RestMethod -Uri "http://localhost:3000/api/vehicles" -Method POST -ContentType "application/json" -Body '{"name":"Yamaha Aerox","plate":"AB 4444 ZZ","isMotor":true}'

# 4. Update Posisi GPS
Invoke-RestMethod -Uri "http://localhost:3000/api/positions" -Method POST -ContentType "application/json" -Body '{"vehicleId":1,"lat":-7.7956,"lng":110.3695,"address":"Jl. Malioboro"}'

# 5. Get Posisi Terakhir
Invoke-RestMethod -Uri "http://localhost:3000/api/positions/1" -Method GET

# 6. Get Riwayat Posisi
Invoke-RestMethod -Uri "http://localhost:3000/api/positions/1/history" -Method GET
```

### cURL
```bash
# 1. Login
curl -X POST http://localhost:3000/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"username":"aryacahyo","password":"password123"}'

# 2. Get Vehicles
curl http://localhost:3000/api/vehicles

# 3. Update Position
curl -X POST http://localhost:3000/api/positions \
  -H "Content-Type: application/json" \
  -d '{"vehicleId":1,"lat":-7.7956,"lng":110.3695,"address":"Jl. Malioboro"}'

# 4. Get Latest Position
curl http://localhost:3000/api/positions/1
```

---

## 💾 Database & Dummy Data

Database SQLite (`database.sqlite`) akan dibuat secara otomatis saat pertama kali aplikasi dijalankan.

### User Bawaan (Default):
- **Username**: `aryacahyo`
- **Password**: `password123`
- **Nama**: `Arya Cahyo`
- **Email**: `arya@jejakku.com`

### Kendaraan Bawaan (Default):
1. **Honda Vario 160** (`AB 1234 XY`) - Motor (Connected)
2. **Toyota Avanza** (`AB 5678 CD`) - Mobil (Connected)
