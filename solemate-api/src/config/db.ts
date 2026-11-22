// src/config/db.ts
import mysql from 'mysql2/promise';
import { env } from './env';
import fs from 'fs';
import path from 'path';

const caPath = [
  path.resolve(__dirname, '..', '..', 'database', 'ca.pem'),
  path.resolve(__dirname, '..', '..', '..', 'database', 'ca.pem'),
].find((candidate) => fs.existsSync(candidate));

if (env.DB.ssl && !caPath) {
  throw new Error('Sertifikat Aiven tidak ditemukan di database/ca.pem');
}

const caCert = env.DB.ssl && caPath ? fs.readFileSync(caPath, 'utf8') : undefined;

export const pool = mysql.createPool({
  host: env.DB.host,
  port: env.DB.port,
  user: env.DB.user,
  password: env.DB.password,
  database: env.DB.name,
  ssl: env.DB.ssl ? { 
    ca: caCert,
    rejectUnauthorized: true } : undefined,
  waitForConnections: true,
  connectionLimit: 10,
  queueLimit: 0,
  dateStrings: true,
});

export async function testConnection(): Promise<void> {
  try {
    const conn = await pool.getConnection();
    await conn.ping();
    conn.release();
    console.log('✅ Koneksi MySQL berhasil');
  } catch (err) {
    console.error('❌ Koneksi MySQL gagal:', (err as Error).message);
    process.exit(1);
  }
}