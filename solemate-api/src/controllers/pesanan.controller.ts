import { Request, Response } from 'express';
import * as pesananService from '../services/pesanan.service';
import { success, error } from '../utils/response';

export const buatPesanan = async (req: Request, res: Response): Promise<void> => {
  try {
    // Pastikan req.user tidak undefined
    if (!req.user || !req.user.id) {
      error(res, 'Sesi tidak valid, silakan login ulang.', 401);
      return;
    }

    const userId = req.user.id; 
    const fotoUrl = req.file ? req.file.path : null;
    
    const insertId = await pesananService.createPesanan(userId, req.body, fotoUrl);
    success(res, 'Pesanan berhasil dibuat', { id: insertId }, 201);
  } catch (err: any) {
    error(res, err.message || 'Gagal membuat pesanan', 400);
  }
};

export const daftarPesanan = async (req: Request, res: Response): Promise<void> => {
  try {
    let data;
    // Jika pemilik, lihat semua pesanan. Jika pelanggan, lihat miliknya sendiri.
    if (req.user!.role === 'pemilik') {
      data = await pesananService.getAllPesanan();
    } else {
      data = await pesananService.getPesananByUser(req.user!.id);
    }
    success(res, 'Berhasil mengambil daftar pesanan', data);
  } catch (err: any) {
    error(res, 'Gagal mengambil pesanan', 500, err.message);
  }
};

export const detailPesanan = async (req: Request, res: Response): Promise<void> => {
  try {
    const data = await pesananService.getPesananById(Number(req.params.id));
    if (!data) {
      error(res, 'Pesanan tidak ditemukan', 404);
      return;
    }
    
    // Keamanan: Pelanggan hanya boleh melihat pesanannya sendiri
    if (req.user!.role === 'pelanggan' && data.user_id !== req.user!.id) {
      error(res, 'Akses ditolak', 403);
      return;
    }
    success(res, 'Berhasil mengambil detail pesanan', data);
  } catch (err: any) {
    error(res, 'Gagal mengambil pesanan', 500, err.message);
  }
};

export const ubahStatus = async (req: Request, res: Response): Promise<void> => {
  try {
    const { status } = req.body;
    if (!status) {
      error(res, 'Status wajib diisi', 400);
      return;
    }

    const isUpdated = await pesananService.updateStatusPesanan(Number(req.params.id), status);
    if (!isUpdated) {
      error(res, 'Pesanan tidak ditemukan', 404);
      return;
    }
    success(res, `Status pesanan berhasil diubah menjadi ${status}`);
  } catch (err: any) {
    error(res, err.message || 'Gagal mengubah status', 400);
  }
};

export const uploadFilePesanan = async (req: Request, res: Response): Promise<void> => {
  try {
    if (!req.file) {
      error(res, 'File tidak ditemukan', 400);
      return;
    }

    // 'field' didapat dari query parameter, misal: ?field=bukti_bayar
    const field = req.query.field as string;
    if (!field) {
      error(res, 'Parameter "field" wajib diisi', 400);
      return;
    }

    const fileUrl = req.file.path;
    await pesananService.updateFileOrResi(Number(req.params.id), field, fileUrl);
    success(res, 'File berhasil diunggah', { [field]: fileUrl });
  } catch (err: any) {
    error(res, err.message || 'Gagal upload file', 400);
  }
};