// database/db-setup.ts
import 'dotenv/config';
import mysql from 'mysql2/promise';
import fs from 'fs';
import path from 'path';

(async (): Promise<void> => {
  try {

    const caPath = path.join(__dirname,'ca.pem');
    const caCert = fs.existsSync(caPath) ? fs.readFileSync(caPath) : undefined;

    // Konfigurasi koneksi (membaca dari .env)
    const conn = await mysql.createConnection({
      host: process.env.DB_HOST || 'localhost',
      port: Number(process.env.DB_PORT) || 3306, // <-- Dinamis membaca DB_PORT
      user: process.env.DB_USER || 'root',
      password: process.env.DB_PASSWORD || '',
      database: process.env.DB_NAME || 'solemate_db', // Aiven pakai 'defaultdb'
      // Dukungan SSL untuk Aiven
      ssl: process.env.DB_SSL === 'true' ? { 
        ca: caCert, 
        rejectUnauthorized: true } : undefined,
      multipleStatements: true, // WAJIB: agar banyak query sekaligus bisa jalan
    });

    const sqlPath = path.join(__dirname, 'schema.sql');
    let sql = fs.readFileSync(sqlPath, 'utf8');

    // Cek apakah kita terhubung ke Aiven (karena Aiven tidak mengizinkan DROP/CREATE DATABASE)
    if (process.env.DB_SSL === 'true' || process.env.DB_HOST?.includes('aivencloud')) {
      console.log('☁️  Mendeteksi koneksi ke Aiven Cloud. Menyesuaikan query...');
      
      // Hapus perintah DROP dan CREATE DATABASE
      sql = sql.replace(/DROP DATABASE IF EXISTS solemate_db;/g, '');
      sql = sql.replace(/CREATE DATABASE solemate_db[^;]*;/g, '');
      sql = sql.replace(/USE solemate_db;/g, `USE ${process.env.DB_NAME || 'defaultdb'};`);
      
      // Hapus baris CREATE TABLE pesanan jika sudah ada (opsional, tapi aman untuk reset)
      // sql = sql.replace(/CREATE TABLE pesanan/g, 'CREATE TABLE IF NOT EXISTS pesanan'); 
    }

    console.log('⏳ Menjalankan schema.sql ...');
    await conn.query(sql);
    console.log('✅ schema.sql berhasil dijalankan');

    await conn.end();
  } catch (err) {
    console.error('❌ Gagal setup database:', (err as Error).message);
    process.exit(1);
  }
})();