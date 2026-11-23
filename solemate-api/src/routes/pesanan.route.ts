import { Router } from 'express';
import * as pesananController from '../controllers/pesanan.controller';
import { requireAuth } from '../middlewares/auth.middleware';
import { requireRole } from '../middlewares/role.middleware';
import { upload } from '../middlewares/upload.middleware';

const router = Router();

// Rute untuk Pelanggan & Admin (Melihat data)
router.get('/', requireAuth, pesananController.getPesanan);
router.get('/:id', requireAuth, pesananController.getDetailPesanan);

// Rute KHUSUS Pelanggan (Membuat pesanan)
router.post(
  '/',
  requireAuth,
  requireRole('pelanggan'),
  upload.single('foto_sepatu'), // <-- Field form-data di Flutter harus 'foto_sepatu'
  pesananController.tambahPesanan
);

// Rute KHUSUS Admin (Mengubah status & Upload Foto)
router.put(
  '/:id/status',
  requireAuth,
  requireRole('pemilik'),
  pesananController.ubahStatus
);

router.put(
  '/:id/foto',
  requireAuth,
  requireRole('pemilik'),
  upload.single('foto'), // <-- Field form-data untuk upload foto
  pesananController.uploadFotoBeforeAfter
);

export default router;