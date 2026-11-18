import { Request, Response, NextFunction } from 'express';
import { Role } from '../types/models';
import { error as errorResponse } from '../utils/response';

export const requireRole = (...allowedRoles: Role[]) => {
  return (req: Request, res: Response, next: NextFunction): void => {
    if (!req.user) {
      errorResponse(res, 'Akses ditolak. Anda belum login.', 401);
      return;
    }

    if (!allowedRoles.includes(req.user.role)) {
      errorResponse(res, 'Akses ditolak. Anda tidak memiliki izin (role).', 403);
      return;
    }

    next();
  };
};