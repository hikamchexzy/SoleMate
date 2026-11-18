import { Router } from 'express';
import * as pesananController from '../controllers/pesanan.controller';
import { requireAuth } from '../middlewares/auth.middleware';
import { requireRole } from '../middlewares/role.middleware';
import { upload } from '../middlewares/upload.middleware';

const router = Router();

router.use(requireAuth); // Semua rute pesanan wajib login

// Pelanggan membuat pesanan (Upload foto sepatu)
router.post(
  '/', 
  requireRole('pelanggan'), 
  upload.single('foto_sepatu'), 
  pesananController.buatPesanan
);

// Lihat pesanan (Pelanggan melihat miliknya, Admin melihat semua)
router.get('/', pesananController.daftarPesanan);
router.get('/:id', pesananController.detailPesanan);

// Admin ubah status
router.put(
  '/:id/status', 
  requireRole('pemilik'), 
  pesananController.ubahStatus
);

// Endpoint generic untuk upload file (before/after/bukti bayar)
// Pelanggan bisa upload bukti_bayar, Admin bisa upload foto_before/foto_after
router.put(
  '/:id/upload', 
  upload.single('file'), 
  pesananController.uploadFilePesanan
);

export default router;