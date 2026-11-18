// src/middlewares/error.middleware.ts
import { Request, Response, NextFunction } from 'express';
import { error as errorResponse } from '../utils/response';

export function notFoundHandler(req: Request, res: Response): void {
  errorResponse(res, `Endpoint ${req.method} ${req.originalUrl} tidak ditemukan`, 404);
}

export function errorHandler(
  err: Error,
  _req: Request,
  res: Response,
  _next: NextFunction
): void {
  console.error('❌ Error:', err.message);

  // Multer error (file terlalu besar / format salah)
  if (err.message.includes('File too large')) {
    errorResponse(res, 'Ukuran file maksimal 2 MB', 400);
    return;
  }
  if (err.message.includes('Format file')) {
    errorResponse(res, err.message, 400);
    return;
  }

  errorResponse(res, err.message || 'Terjadi kesalahan server', 500);
}