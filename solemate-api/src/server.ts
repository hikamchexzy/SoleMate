// src/server.ts
import { createApp } from './app';
import { testConnection } from './config/db';
import { env } from './config/env';

(async (): Promise<void> => {
  await testConnection();

  const app = createApp();
  app.listen(env.PORT, () => {
    console.log(`🚀 Server berjalan di http://localhost:${env.PORT}`);
    console.log(`🌍 Mode: ${env.NODE_ENV}`);
  });
})();