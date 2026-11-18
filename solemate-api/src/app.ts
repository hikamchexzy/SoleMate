// src/app.ts
import express, { Application } from 'express';
import cors from 'cors';
import { notFoundHandler, errorHandler } from './middlewares/error.middleware';
import authRoute from './routes/auth.route';

export function createApp(): Application {
  const app = express();

  app.use(cors());
  app.use(express.json());
  app.use(express.urlencoded({ extended: true }));

  app.get('/', (_req, res) => {
    res.json({
      success: true,
      message: '🚀 SoleMate API berjalan',
      version: '1.0.0',
    });
  });

    app.use('/api/auth', authRoute);
    
  // Routes akan ditambahkan di sesi berikutnya:
  // app.use('/api/paket', paketRoute);
  // app.use('/api/pesanan', pesananRoute);
  // app.use('/api/dashboard', dashboardRoute);

  app.use(notFoundHandler);
  app.use(errorHandler);

  return app;
}