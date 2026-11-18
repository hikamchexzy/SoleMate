// src/middlewares/upload.middleware.ts
import multer from 'multer';
import { CloudinaryStorage } from 'multer-storage-cloudinary';
import { cloudinary } from '../config/cloudinary';
import { env } from '../config/env';

const storage = new CloudinaryStorage({
  cloudinary,
  params: async (_req, file) => ({
    folder: env.CLOUDINARY.folder,
    allowed_formats: ['jpg', 'jpeg', 'png'],
    public_id: `${Date.now()}-${file.originalname
      .split('.')[0]
      .replace(/[^a-zA-Z0-9]/g, '_')}`,
    transformation: [{ width: 1200, crop: 'limit', quality: 'auto' }],
  }),
});

export const upload = multer({
  storage,
  limits: { fileSize: 2 * 1024 * 1024 }, // 2 MB
  fileFilter: (_req, file, cb) => {
    const allowed = ['image/jpeg', 'image/jpg', 'image/png'];
    if (allowed.includes(file.mimetype)) {
      cb(null, true);
    } else {
      cb(new Error('Format file harus jpg/jpeg/png'));
    }
  },
});