import { Router } from 'express';
import * as paketController from '../controllers/paket.controller';
import { requireAuth } from '../middlewares/auth.middleware';
import { requireRole } from '../middlewares/role.middleware';
import { upload } from '../middlewares/upload.middleware';

const router = Router();

// Rute untuk Pelanggan & Admin (Melihat paket)
router.get('/', requireAuth, paketController.getPaket);
router.get('/:id', requireAuth, paketController.getDetailPaket);

// Rute HANYA untuk Admin/Pemilik
// upload.single('gambar') -> nama field di form-data harus 'gambar'
router.post(
  '/',
  requireAuth,
  requireRole('pemilik'),
  upload.single('gambar'),
  paketController.tambahPaket
);

router.put(
  '/:id',
  requireAuth,
  requireRole('pemilik'),
  upload.single('gambar'),
  paketController.editPaket
);

router.delete(
  '/:id',
  requireAuth,
  requireRole('pemilik'),
  paketController.hapusPaket
);

export default router;