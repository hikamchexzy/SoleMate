import { Request, Response } from 'express';
import * as paketService from '../services/paket.service';
import { success, error } from '../utils/response';

export const getPaket = async (req: Request, res: Response): Promise<void> => {
  try {
    const data = await paketService.getAllPaket();
    success(res, 'Berhasil mengambil daftar paket', data);
  } catch (err: any) {
    error(res, 'Gagal mengambil data paket', 500, err.message);
  }
};

export const getDetailPaket = async (req: Request, res: Response): Promise<void> => {
  try {
    const id = Number(req.params.id);
    const data = await paketService.getPaketById(id);
    
    if (!data) {
      error(res, 'Paket tidak ditemukan', 404);
      return;
    }
    success(res, 'Berhasil mengambil detail paket', data);
  } catch (err: any) {
    error(res, 'Gagal mengambil data paket', 500, err.message);
  }
};

export const tambahPaket = async (req: Request, res: Response): Promise<void> => {
  try {
    // req.file.path berisi URL gambar dari Cloudinary (dari multer-storage-cloudinary)
    const gambarUrl = req.file ? req.file.path : null;
    
    const insertId = await paketService.createPaket(req.body, gambarUrl);
    success(res, 'Paket berhasil ditambahkan', { id: insertId }, 201);
  } catch (err: any) {
    error(res, 'Gagal menambahkan paket', 400, err.message);
  }
};

export const editPaket = async (req: Request, res: Response): Promise<void> => {
  try {
    const id = Number(req.params.id);
    const gambarUrl = req.file ? req.file.path : undefined;
    
    const isUpdated = await paketService.updatePaket(id, req.body, gambarUrl);
    if (!isUpdated) {
      error(res, 'Paket tidak ditemukan atau gagal diupdate', 404);
      return;
    }
    success(res, 'Paket berhasil diupdate');
  } catch (err: any) {
    error(res, 'Gagal mengupdate paket', 400, err.message);
  }
};

export const hapusPaket = async (req: Request, res: Response): Promise<void> => {
  try {
    const id = Number(req.params.id);
    const isDeleted = await paketService.deletePaket(id);
    
    if (!isDeleted) {
      error(res, 'Paket tidak ditemukan', 404);
      return;
    }
    success(res, 'Paket berhasil dihapus (dinonaktifkan)');
  } catch (err: any) {
    error(res, 'Gagal menghapus paket', 500, err.message);
  }
};