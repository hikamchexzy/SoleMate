import { Request, Response } from 'express';
import * as pesananService from '../services/pesanan.service';
import { success, error } from '../utils/response';
import { StatusPesanan } from '../types/models';

export const getPesanan = async (req: Request, res: Response): Promise<void> => {
  try {
    const userId = req.user!.id;
    const role = req.user!.role;
    const data = await pesananService.getAllPesanan(userId, role);
    success(res, 'Berhasil mengambil daftar pesanan', data);
  } catch (err: any) {
    error(res, 'Gagal mengambil data pesanan', 500, err.message);
  }
};

export const getDetailPesanan = async (req: Request, res: Response): Promise<void> => {
  try {
    const id = Number(req.params.id);
    const data = await pesananService.getPesananById(id);
    if (!data) {
      error(res, 'Pesanan tidak ditemukan', 404);
      return;
    }
    success(res, 'Berhasil mengambil detail pesanan', data);
  } catch (err: any) {
    error(res, 'Gagal mengambil data pesanan', 500, err.message);
  }
};

export const tambahPesanan = async (req: Request, res: Response): Promise<void> => {
  try {
    const user_id = req.user!.id;
    const { paket_id, catatan, no_hp_kontak, tingkat_kekotoran, total_harga } = req.body;
    const fotoUrl = req.file ? req.file.path : null;

    // --- VALIDASI NO HP ---
    if (!no_hp_kontak) {
      error(res, 'Nomor HP/WhatsApp wajib diisi', 400);
      return;
    }

    // Regex memastikan hanya angka dan panjang 10-14 digit
    const phoneRegex = /^[0-9]{10,14}$/;
    if (!phoneRegex.test(no_hp_kontak)) {
      error(res, 'Format Nomor HP tidak valid (harus angka, 10-14 digit)', 400);
      return;
    }

    const insertId = await pesananService.createPesanan(
      { user_id, paket_id, catatan, no_hp_kontak, tingkat_kekotoran, total_harga }, 
      fotoUrl
    );
    
    success(res, 'Pesanan berhasil dibuat', { id: insertId }, 201);
  } catch (err: any) {
    error(res, 'Gagal membuat pesanan', 400, err.message);
  }
};

export const ubahStatus = async (req: Request, res: Response): Promise<void> => {
  try {
    const id = Number(req.params.id);
    const { status } = req.body;
    
    const isUpdated = await pesananService.updateStatusPesanan(id, status as StatusPesanan);
    if (!isUpdated) {
      error(res, 'Pesanan tidak ditemukan', 404);
      return;
    }
    success(res, 'Status pesanan berhasil diperbarui');
  } catch (err: any) {
    error(res, 'Gagal mengupdate status', 400, err.message);
  }
};

export const uploadFotoBeforeAfter = async (req: Request, res: Response): Promise<void> => {
  try {
    const id = Number(req.params.id);
    const { tipe } = req.body; // 'before' atau 'after'
    const fotoUrl = req.file ? req.file.path : null;

    if (!fotoUrl) {
      error(res, 'File foto tidak ditemukan', 400);
      return;
    }

    const isUpdated = await pesananService.updateFotoPesanan(id, tipe, fotoUrl);
    if (!isUpdated) {
      error(res, 'Pesanan tidak ditemukan', 404);
      return;
    }
    success(res, `Foto ${tipe} berhasil diunggah`);
  } catch (err: any) {
    error(res, 'Gagal mengunggah foto', 500, err.message);
  }
};