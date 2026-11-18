// src/config/env.ts
import 'dotenv/config';

const required = [
  'DB_HOST', 'DB_USER', 'DB_NAME',
  'JWT_SECRET',
  'CLOUDINARY_CLOUD_NAME', 'CLOUDINARY_API_KEY', 'CLOUDINARY_API_SECRET',
];

for (const key of required) {
  if (!process.env[key]) {
    console.error(`❌ Environment variable ${key} belum di-set di .env`);
    process.exit(1);
  }
}

export const env = {
  PORT: Number(process.env.PORT) || 3000,
  NODE_ENV: process.env.NODE_ENV || 'development',

  DB: {
    host: process.env.DB_HOST!,
    port: Number(process.env.DB_PORT) || 3306,
    user: process.env.DB_USER!,
    password: process.env.DB_PASSWORD || '',
    name: process.env.DB_NAME!,
  },

  JWT: {
    secret: process.env.JWT_SECRET!,
    expiresIn: process.env.JWT_EXPIRES_IN || '7d',
  },

  CLOUDINARY: {
    cloudName: process.env.CLOUDINARY_CLOUD_NAME!,
    apiKey: process.env.CLOUDINARY_API_KEY!,
    apiSecret: process.env.CLOUDINARY_API_SECRET!,
    folder: process.env.CLOUDINARY_FOLDER || 'solemate',
  },
};