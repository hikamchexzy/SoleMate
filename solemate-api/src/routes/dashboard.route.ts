import { Router } from 'express';
import { getStatistik } from '../controllers/dashboard.controller';
import { requireAuth } from '../middlewares/auth.middleware';
import { requireRole } from '../middlewares/role.middleware';

const router = Router();

// Hanya Pemilik/Admin yang bisa melihat dashboard
router.get('/', requireAuth, requireRole('pemilik'), getStatistik);

export default router;