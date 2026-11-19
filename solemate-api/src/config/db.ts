// src/config/db.ts
import mysql from 'mysql2/promise';
import { env } from './env';

export const pool = mysql.createPool({
  host: env.DB.host,
  port: env.DB.port,
  user: env.DB.user,
  password: env.DB.password,
  database: env.DB.name,
  ssl: env.DB.ssl ? { rejectUnauthorized: true } : undefined,
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