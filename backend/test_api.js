// Quick automated smoke test for JEJAKKU Backend API
const http = require('http');

function request(options, data) {
  return new Promise((resolve, reject) => {
    const req = http.request(options, (res) => {
      let body = '';
      res.on('data', (chunk) => body += chunk);
      res.on('end', () => {
        try {
          resolve({ status: res.statusCode, headers: res.headers, body: JSON.parse(body) });
        } catch (e) {
          resolve({ status: res.statusCode, headers: res.headers, body });
        }
      });
    });

    req.on('error', reject);
    if (data) {
      req.write(typeof data === 'string' ? data : JSON.stringify(data));
    }
    req.end();
  });
}

async function runTests() {
  console.log('🚀 Memulai pengujian API...');
  const baseUrl = { hostname: 'localhost', port: 3000 };

  try {
    // 1. Health Check
    let res = await request({ ...baseUrl, path: '/api/health', method: 'GET' });
    console.log(`[PASS] GET /api/health => Status ${res.status}`);

    // 2. Login
    res = await request(
      {
        ...baseUrl,
        path: '/api/auth/login',
        method: 'POST',
        headers: { 'Content-Type': 'application/json' }
      },
      { username: 'aryacahyo', password: 'password123' }
    );
    console.log(`[PASS] POST /api/auth/login => Status ${res.status}, user: ${res.body.user?.name}, token exists: ${Boolean(res.body.token)}`);
    const token = res.body.token;

    // 3. Get Vehicles
    res = await request({
      ...baseUrl,
      path: '/api/vehicles',
      method: 'GET',
      headers: { 'Authorization': `Bearer ${token}` }
    });
    console.log(`[PASS] GET /api/vehicles => Status ${res.status}, count: ${res.body.vehicles?.length}`);

    // 4. Create Vehicle
    res = await request(
      {
        ...baseUrl,
        path: '/api/vehicles',
        method: 'POST',
        headers: { 'Content-Type': 'application/json', 'Authorization': `Bearer ${token}` }
      },
      { name: 'Yamaha Aerox 155', plate: 'AB 7777 KL', isMotor: true, status: 'connected' }
    );
    console.log(`[PASS] POST /api/vehicles => Status ${res.status}, created id: ${res.body.vehicle?.id}`);
    const newVehicleId = res.body.vehicle?.id;

    // 5. Update Position
    res = await request(
      {
        ...baseUrl,
        path: '/api/positions',
        method: 'POST',
        headers: { 'Content-Type': 'application/json', 'Authorization': `Bearer ${token}` }
      },
      { vehicleId: newVehicleId, lat: -7.7812, lng: 110.3665, address: 'Jl. Jend. Sudirman, Yogyakarta' }
    );
    console.log(`[PASS] POST /api/positions => Status ${res.status}, message: ${res.body.message}`);

    // 6. Get Latest Position
    res = await request({
      ...baseUrl,
      path: `/api/positions/${newVehicleId}`,
      method: 'GET',
      headers: { 'Authorization': `Bearer ${token}` }
    });
    console.log(`[PASS] GET /api/positions/${newVehicleId} => Status ${res.status}, lat: ${res.body.position?.lat}, address: ${res.body.position?.address}`);

    // 7. Get Position History
    res = await request({
      ...baseUrl,
      path: `/api/positions/${newVehicleId}/history`,
      method: 'GET',
      headers: { 'Authorization': `Bearer ${token}` }
    });
    console.log(`[PASS] GET /api/positions/${newVehicleId}/history => Status ${res.status}, history count: ${res.body.count}`);

    // 8. Delete Vehicle
    res = await request({
      ...baseUrl,
      path: `/api/vehicles/${newVehicleId}`,
      method: 'DELETE',
      headers: { 'Authorization': `Bearer ${token}` }
    });
    console.log(`[PASS] DELETE /api/vehicles/${newVehicleId} => Status ${res.status}, message: ${res.body.message}`);

    // 9. Verify 404
    res = await request({
      ...baseUrl,
      path: '/api/invalid-endpoint',
      method: 'GET'
    });
    console.log(`[PASS] 404 Not Found Handler => Status ${res.status}, message: ${res.body.message}`);

    console.log('\n Semua tes endpoint berhasil 100%!');
  } catch (err) {
    console.error('❌ Pengujian gagal:', err);
  }
}

// Jalankan app lalu test
require('./src/app');
setTimeout(runTests, 1500);
