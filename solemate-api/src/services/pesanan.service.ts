import { pool } from '../config/db';
import { RowDataPacket, ResultSetHeader } from 'mysql2';

export const createPesanan = async (userId: number, data: any, fotoUrl: string | null): Promise<number> => {
  const { paket_id, catatan, alamat_jemput, metode_pengantaran } = data;

  // 1. Ambil harga paket dari database untuk menghitung total
  const [paketRows] = await pool.query<RowDataPacket[]>(
    'SELECT harga FROM paket WHERE id = ? AND is_active = 1', [paket_id]
  );

  if (paketRows.length === 0) throw new Error('Paket tidak ditemukan atau tidak aktif');
  
  const total_harga = paketRows[0].harga;
  // Jika antar sendiri, status langsung menunggu konfirmasi. Jika kurir, sama.
  const status = 'menunggu_konfirmasi';

  const [result] = await pool.query<ResultSetHeader>(
    `INSERT INTO pesanan 
    (user_id, paket_id, foto_sepatu, catatan, alamat_jemput, metode_pengantaran, total_harga, status) 
    VALUES (?, ?, ?, ?, ?, ?, ?, ?)`,
    [userId, paket_id, fotoUrl, catatan || null, alamat_jemput || null, metode_pengantaran, total_harga, status]
  );

  return result.insertId;
};

export const getPesananByUser = async (userId: number): Promise<any[]> => {
  const [rows] = await pool.query<RowDataPacket[]>(
    `SELECT p.*, pk.nama_paket, pk.harga 
     FROM pesanan p
     JOIN paket pk ON p.paket_id = pk.id
     WHERE p.user_id = ?
     ORDER BY p.tanggal_pesan DESC`, [userId]
  );
  return rows;
};

export const getAllPesanan = async (): Promise<any[]> => {
  const [rows] = await pool.query<RowDataPacket[]>(
    `SELECT p.*, pk.nama_paket, u.nama AS nama_pelanggan, u.no_hp 
     FROM pesanan p
     JOIN paket pk ON p.paket_id = pk.id
     JOIN users u ON p.user_id = u.id
     ORDER BY p.tanggal_pesan DESC`
  );
  return rows;
};

export const getPesananById = async (id: number): Promise<any | null> => {
  const [rows] = await pool.query<RowDataPacket[]>(
    `SELECT p.*, pk.nama_paket, u.nama AS nama_pelanggan, u.no_hp 
     FROM pesanan p
     JOIN paket pk ON p.paket_id = pk.id
     JOIN users u ON p.user_id = u.id
     WHERE p.id = ?`, [id]
  );
  return rows.length > 0 ? rows[0] : null;
};

// Admin update status manual (misal dari 'menunggu' ke 'diterima', atau 'dicuci', dll)
export const updateStatusPesanan = async (id: number, status: string): Promise<boolean> => {
  let tanggal_selesai = null;
  if (status === 'selesai_diambil') {
    tanggal_selesai = new Date();
  }

  const [result] = await pool.query<ResultSetHeader>(
    'UPDATE pesanan SET status = ?, tanggal_selesai = COALESCE(?, tanggal_selesai) WHERE id = ?',
    [status, tanggal_selesai, id]
  );
  return result.affectedRows > 0;
};

// Endpoint khusus update resi/foto/file yang tidak mengubah status
export const updateFileOrResi = async (id: number, field: string, value: string): Promise<boolean> => {
  const allowedFields = ['resi_masuk', 'resi_keluar', 'bukti_bayar', 'foto_before', 'foto_after'];
  if (!allowedFields.includes(field)) throw new Error('Field tidak valid');

  const [result] = await pool.query<ResultSetHeader>(
    `UPDATE pesanan SET ${field} = ? WHERE id = ?`, [value, id]
  );
  return result.affectedRows > 0;
};