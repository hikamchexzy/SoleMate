import { pool } from '../config/db';
import { Paket } from '../types/models';
import { RowDataPacket, ResultSetHeader } from 'mysql2';

export const getAllPaket = async (): Promise<Paket[]> => {
  const [rows] = await pool.query<RowDataPacket[]>(
    'SELECT * FROM paket WHERE is_active = 1 ORDER BY id DESC'
  );
  return rows as Paket[];
};

export const getPaketById = async (id: number): Promise<Paket | null> => {
  const [rows] = await pool.query<RowDataPacket[]>(
    'SELECT * FROM paket WHERE id = ?', [id]
  );
  return rows.length > 0 ? (rows[0] as Paket) : null;
};

export const createPaket = async (data: any, gambarUrl: string | null): Promise<number> => {
  const { nama_paket, deskripsi, harga, estimasi_hari } = data;
  
  const [result] = await pool.query<ResultSetHeader>(
    'INSERT INTO paket (nama_paket, deskripsi, harga, estimasi_hari, gambar) VALUES (?, ?, ?, ?, ?)',
    [nama_paket, deskripsi || null, harga, estimasi_hari, gambarUrl]
  );
  return result.insertId;
};

export const updatePaket = async (id: number, data: any, gambarUrl?: string): Promise<boolean> => {
  const { nama_paket, deskripsi, harga, estimasi_hari, is_active } = data;
  
  // Jika admin mengupload gambar baru, update kolom gambar. Jika tidak, biarkan gambar lama.
  let query = 'UPDATE paket SET nama_paket = ?, deskripsi = ?, harga = ?, estimasi_hari = ?, is_active = ?';
  const values = [nama_paket, deskripsi || null, harga, estimasi_hari, is_active ?? 1];

  if (gambarUrl) {
    query += ', gambar = ?';
    values.push(gambarUrl);
  }

  query += ' WHERE id = ?';
  values.push(id);

  const [result] = await pool.query<ResultSetHeader>(query, values);
  return result.affectedRows > 0;
};

export const deletePaket = async (id: number): Promise<boolean> => {
  // Soft delete: jangan hapus data asli karena mungkin terhubung ke tabel pesanan
  const [result] = await pool.query<ResultSetHeader>(
    'UPDATE paket SET is_active = 0 WHERE id = ?', [id]
  );
  return result.affectedRows > 0;
};