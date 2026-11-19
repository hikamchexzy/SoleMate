import { Request, Response } from 'express';
import { pool } from '../config/db';
import { success, error } from '../utils/response';
import { RowDataPacket } from 'mysql2';

export const getStatistik = async (req: Request, res: Response): Promise<void> => {
  try {
    // 1. Total semua pesanan
    const [totalPesanan] = await pool.query<RowDataPacket[]>(
      'SELECT COUNT(*) as total FROM pesanan'
    );

    // 2. Total pendapatan (hanya dari pesanan yang sudah selesai/diambil)
    const [totalPendapatan] = await pool.query<RowDataPacket[]>(
      "SELECT SUM(total_harga) as total FROM pesanan WHERE status IN ('selesai', 'selesai_diambil')"
    );

    // 3. Pesanan yang sedang dicuci
    const [sedangDicuci] = await pool.query<RowDataPacket[]>(
      "SELECT COUNT(*) as total FROM pesanan WHERE status = 'dicuci'"
    );

    // 4. Total pelanggan (role = 'pelanggan')
    const [totalPelanggan] = await pool.query<RowDataPacket[]>(
      "SELECT COUNT(*) as total FROM users WHERE role = 'pelanggan'"
    );

    // 5. Ambil 5 pesanan terbaru untuk ditampilkan di dashboard
    const [pesananTerbaru] = await pool.query<RowDataPacket[]>(
      `SELECT p.id, u.nama as nama_pelanggan, pk.nama_paket, p.status, p.tanggal_pesan 
       FROM pesanan p 
       JOIN users u ON p.user_id = u.id 
       JOIN paket pk ON p.paket_id = pk.id 
       ORDER BY p.tanggal_pesan DESC LIMIT 5`
    );

    success(res, 'Berhasil mengambil statistik dashboard', {
      total_pesanan: totalPesanan[0].total,
      total_pendapatan: totalPendapatan[0].total || 0, // Jika null, jadikan 0
      sedang_dicuci: sedangDicuci[0].total,
      total_pelanggan: totalPelanggan[0].total,
      pesanan_terbaru: pesananTerbaru,
    });
  } catch (err: any) {
    error(res, 'Gagal mengambil data statistik', 500, err.message);
  }
};