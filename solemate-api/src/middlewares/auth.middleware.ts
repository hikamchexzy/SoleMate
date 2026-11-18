import { Request, Response, NextFunction } from 'express';
import { verifyToken } from '../utils/jwt';
import { error as errorResponse } from '../utils/response';

export const requireAuth = (req: Request, res: Response, next: NextFunction): void => {
  const authHeader = req.headers.authorization;

  if (!authHeader || !authHeader.startsWith('Bearer ')) {
    errorResponse(res, 'Akses ditolak. Token tidak ditemukan.', 401);
    return;
  }

  const token = authHeader.split(' ')[1];

  try {
    const decoded = verifyToken(token);
    req.user = decoded; // Simpan data user ke request
    next();
  } catch (err) {
    errorResponse(res, 'Token tidak valid atau sudah kedaluwarsa.', 401);
  }
};