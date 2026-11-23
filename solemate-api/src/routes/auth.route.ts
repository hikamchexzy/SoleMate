import { Router } from 'express';
import { register, login, getMe, updateUserProfil } from '../controllers/auth.controller';
import { requireAuth } from '../middlewares/auth.middleware';
import {upload} from '../middlewares/upload.middleware';

const router = Router();

router.post('/register', register);
router.post('/login', login);
router.get('/me', requireAuth, getMe); // Butuh login untuk akses
router.put(
  '/profile', 
  requireAuth, 
  upload.single('foto_profil'), // <-- Middleware upload ditambahkan di sini
  updateUserProfil
);

export default router;