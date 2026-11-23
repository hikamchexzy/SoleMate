import { pool } from '../config/db';
import { Pesanan, StatusPesanan } from '../types/models';
import { RowDataPacket, ResultSetHeader } from 'mysql2';

export const getAllPesanan = async (userId: number, role: string): Promise<Pesanan[]> => {
  let query = `
    SELECT p.*, u.nama as nama_pelanggan, pk.nama_paket 
    FROM pesanan p 
    JOIN users u ON p.user_id = u.id 
    JOIN paket pk ON p.paket_id = pk.id
  `;
  const values: any[] = [];

  // Jika yang minta adalah pelanggan, hanya tampilkan pesanannya sendiri
  if (role === 'pelanggan') {
    query += ' WHERE p.user_id = ?';
    values.push(userId);
  }
  
  query += ' ORDER BY p.tanggal_pesan DESC';

  const [rows] = await pool.query<RowDataPacket[]>(query, values);
  return rows as Pesanan[];
};

export const getPesananById = async (id: number): Promise<Pesanan | null> => {
  const [rows] = await pool.query<RowDataPacket[]>(
    `SELECT p.*, u.nama as nama_pelanggan, pk.nama_paket 
     FROM pesanan p 
     JOIN users u ON p.user_id = u.id 
     JOIN paket pk ON p.paket_id = pk.id
     WHERE p.id = ?`, [id]
  );
  return rows.length > 0 ? (rows[0] as Pesanan) : null;
};

export const createPesanan = async (data: any, fotoUrl: string | null): Promise<number> => {
  const { user_id, paket_id, catatan, no_hp_kontak, tingkat_kekotoran, total_harga } = data;
  
  const [result] = await pool.query<ResultSetHeader>(
    'INSERT INTO pesanan (user_id, paket_id, catatan, no_hp_kontak, tingkat_kekotoran, total_harga, foto_sepatu) VALUES (?, ?, ?, ?, ?, ?, ?)',
    [user_id, paket_id, catatan || null, no_hp_kontak, tingkat_kekotoran || 'sedang', total_harga, fotoUrl]
  );
  return result.insertId;
};

export const updateStatusPesanan = async (id: number, status: StatusPesanan): Promise<boolean> => {
  let query = 'UPDATE pesanan SET status = ?';
  const values: any[] = [status];

  // Jika statusnya selesai, catat tanggal selesainya
  if (status === 'selesai' || status === 'selesai_diambil') {
    query += ', tanggal_selesai = NOW()';
  }

  query += ' WHERE id = ?';
  values.push(id);

  const [result] = await pool.query<ResultSetHeader>(query, values);
  return result.affectedRows > 0;
};

// Fungsi untuk upload foto before/after oleh admin
export const updateFotoPesanan = async (id: number, tipe: 'before' | 'after', fotoUrl: string): Promise<boolean> => {
  const column = tipe === 'before' ? 'foto_before' : 'foto_after';
  const [result] = await pool.query<ResultSetHeader>(
    `UPDATE pesanan SET ${column} = ? WHERE id = ?`, [fotoUrl, id]
  );
  return result.affectedRows > 0;
};