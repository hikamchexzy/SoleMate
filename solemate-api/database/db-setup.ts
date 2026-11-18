// database/db-setup.ts
import 'dotenv/config';
import mysql from 'mysql2/promise';
import fs from 'fs';
import path from 'path';

(async (): Promise<void> => {
  try {
    const conn = await mysql.createConnection({
      host: process.env.DB_HOST || 'localhost',
      port: Number(process.env.DB_PORT) || 3306,
      user: process.env.DB_USER || 'root',
      password: process.env.DB_PASSWORD || '',
      multipleStatements: true, // WAJIB: agar banyak query sekaligus bisa jalan
    });

    const sqlPath = path.join(__dirname, 'schema.sql');
    const sql = fs.readFileSync(sqlPath, 'utf8');

    console.log('⏳ Menjalankan schema.sql ...');
    await conn.query(sql);
    console.log('✅ schema.sql berhasil dijalankan');

    await conn.end();
  } catch (err) {
    console.error('❌ Gagal setup database:', (err as Error).message);
    process.exit(1);
  }
})();