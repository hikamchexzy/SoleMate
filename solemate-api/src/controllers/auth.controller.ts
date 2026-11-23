import { Request, Response } from 'express';
import { registerUser, loginUser, updateProfil } from '../services/auth.service';
import { generateToken } from '../utils/jwt';
import { success, error } from '../utils/response';

export const register = async (req: Request, res: Response): Promise<void> => {
  try {
    const insertId = await registerUser(req.body);
    success(res, 'Registrasi berhasil', { id: insertId }, 201);
  } catch (err: any) {
    error(res, err.message || 'Gagal registrasi', 400);
  }
};

export const login = async (req: Request, res: Response): Promise<void> => {
  try {
    const { email, password } = req.body;
    if (!email || !password) {
      error(res, 'Email dan password wajib diisi', 400);
      return;
    }

    const user = await loginUser(email, password);
    const token = generateToken({ id: user.id, email: user.email, role: user.role });

    // Jangan kirim password ke frontend
    const { password: _, ...userWithoutPassword } = user;

    success(res, 'Login berhasil', { token, user: userWithoutPassword });
  } catch (err: any) {
    error(res, err.message || 'Gagal login', 401);
  }
};

export const getMe = async (req: Request, res: Response): Promise<void> => {
  // req.user didapat dari auth.middleware
  success(res, 'Berhasil mendapatkan data profil', req.user);
};

export const updateUserProfil = async (req: Request, res: Response): Promise<void> => {
  try {
    const userId = req.user!.id;
    const { nama, no_hp } = req.body;
    
    // Cek apakah ada file foto yang diunggah lewat multer
    const fotoUrl = req.file ? req.file.path : undefined;

    if (!nama) {
      error(res, 'Nama tidak boleh kosong', 400);
      return;
    }

    // Panggil service dengan parameter lengkap
    await updateProfil(userId, nama, no_hp || '', fotoUrl);
    
    success(res, 'Profil berhasil diperbarui');
  } catch (err: any) {
    error(res, 'Gagal memperbarui profil', 500, err.message);
  }
};