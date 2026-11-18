// src/config/cloudinary.ts
import { v2 as cloudinary } from 'cloudinary';
import { env } from './env';

cloudinary.config({
  cloud_name: env.CLOUDINARY.cloudName,
  api_key: env.CLOUDINARY.apiKey,
  api_secret: env.CLOUDINARY.apiSecret,
  secure: true,
});

export { cloudinary };