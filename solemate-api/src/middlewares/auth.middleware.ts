import { Request, Response, NextFunction } from 'express';
import { verifyToken } from '../utils/jwt';
import { error as errorResponse } from '../utils/response';

export const requireAuth = (req: Request, res: Response, next: NextFunction): void => {
  const authHeader = req.headers.authorization;

  // 1. Cek apakah header ada dan formatnya "Bearer <token>"
  if (!authHeader || !authHeader.startsWith('Bearer ')) {
    errorResponse(res, 'Akses ditolak. Token tidak ditemukan.', 401);
    return;
  }

  const token = authHeader.split(' ')[1];

  try {
    const decoded = verifyToken(token);
    
    // 2. Pastikan decoded memiliki properti id
    if (!decoded || !decoded.id) {
       errorResponse(res, 'Token tidak valid (ID tidak ditemukan).', 401);
       return;
    }

    req.user = decoded; // <-- Pastikan ini terisi
    next();
  } catch (err) {
    errorResponse(res, 'Token tidak valid atau sudah kedaluwarsa.', 401);
  }
};