-- ============================================================
-- SOLEMATE DATABASE SCHEMA (FINAL REVISI)
-- ============================================================
DROP DATABASE IF EXISTS solemate_db;
CREATE DATABASE solemate_db
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_unicode_ci;
USE solemate_db;

-- 1. TABEL USERS
CREATE TABLE users (
  id            INT AUTO_INCREMENT PRIMARY KEY,
  nama          VARCHAR(100) NOT NULL,
  email         VARCHAR(150) NOT NULL UNIQUE,
  password      VARCHAR(255) NOT NULL COMMENT 'Hash bcrypt',
  role          ENUM('pemilik','pelanggan') NOT NULL DEFAULT 'pelanggan',
  no_hp         VARCHAR(20)  DEFAULT NULL,
  alamat        TEXT         DEFAULT NULL,
  created_at    DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at    DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  INDEX idx_users_role (role),
  INDEX idx_users_email (email)
) ENGINE=InnoDB;

-- 2. TABEL PAKET
CREATE TABLE paket (
  id              INT AUTO_INCREMENT PRIMARY KEY,
  nama_paket      VARCHAR(100) NOT NULL,
  deskripsi       TEXT         DEFAULT NULL,
  harga           INT          NOT NULL COMMENT 'Harga dalam Rupiah',
  estimasi_hari   INT          NOT NULL DEFAULT 1 COMMENT 'Estimasi pengerjaan (hari)',
  gambar          VARCHAR(255) DEFAULT NULL COMMENT 'Path file gambar paket',
  is_active       TINYINT(1)   NOT NULL DEFAULT 1 COMMENT '1=aktif, 0=nonaktif',
  created_at      DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at      DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  INDEX idx_paket_active (is_active)
) ENGINE=InnoDB;

-- 3. TABEL PESANAN (Sudah ditambah metode_pengantaran)
CREATE TABLE pesanan (
  id              INT AUTO_INCREMENT PRIMARY KEY,
  user_id         INT          NOT NULL COMMENT 'FK ke users (pelanggan)',
  paket_id        INT          NOT NULL COMMENT 'FK ke paket',
  
  foto_sepatu     VARCHAR(255) DEFAULT NULL COMMENT 'Foto kondisi sepatu awal',
  catatan         TEXT         DEFAULT NULL,
  alamat_jemput   TEXT         DEFAULT NULL,
  
  -- KOLOM BARU UNTUK OPSI PENGANTARAN
  metode_pengantaran ENUM('antar_sendiri', 'kurir_online') NOT NULL DEFAULT 'antar_sendiri',
  
  resi_masuk      VARCHAR(100) DEFAULT NULL COMMENT 'No. resi kurir ke workshop',
  bukti_bayar     VARCHAR(255) DEFAULT NULL COMMENT 'Path file bukti bayar',
  resi_keluar     VARCHAR(100) DEFAULT NULL COMMENT 'No. resi kurir balik ke pelanggan',
  foto_before     VARCHAR(255) DEFAULT NULL COMMENT 'Foto sebelum dicuci (admin)',
  foto_after      VARCHAR(255) DEFAULT NULL COMMENT 'Foto setelah dicuci (admin)',
  
  total_harga     INT          NOT NULL DEFAULT 0,
  status          ENUM(
                    'menunggu_konfirmasi',
                    'dalam_pengiriman_masuk',
                    'diterima',
                    'dicuci',
                    'selesai',
                    'dalam_pengiriman_keluar',
                    'selesai_diambil'
                  ) NOT NULL DEFAULT 'menunggu_konfirmasi',
  tanggal_pesan   DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  tanggal_selesai DATETIME     DEFAULT NULL,
  updated_at      DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  
  CONSTRAINT fk_pesanan_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT fk_pesanan_paket FOREIGN KEY (paket_id) REFERENCES paket(id) ON DELETE RESTRICT ON UPDATE CASCADE,
  
  INDEX idx_pesanan_user   (user_id),
  INDEX idx_pesanan_paket  (paket_id),
  INDEX idx_pesanan_status (status),
  INDEX idx_pesanan_tanggal(tanggal_pesan)
) ENGINE=InnoDB;

-- 4. SEED DATA PAKET
INSERT INTO paket (nama_paket, deskripsi, harga, estimasi_hari) VALUES
('Fast Clean', 'Pembersihan cepat bagian upper dan sol sepatu. Cocok untuk sepatu yang tidak terlalu kotor.', 25000, 1),
('Deep Clean', 'Pembersihan menyeluruh hingga ke bagian dalam sepatu, sol, dan tali. Termasuk penghilangan noda membandel dan bau.', 50000, 2),
('Special Treatment', 'Perawatan khusus untuk sepatu berbahan sensitif seperti suede, nubuck, kulit, dan kanvas premium.', 75000, 3),
('Whitening', 'Pemutihan khusus untuk sepatu putih yang menguning atau kusam. Mengembalikan warna putih cerah tanpa merusak bahan.', 90000, 3);

-- 5. SEED DATA USERS (Akun Testing)
-- Akun Pemilik: pemilik@solemate.com | Pass: Pemilik123!
INSERT INTO users (nama, email, password, role, no_hp, alamat) VALUES
('Bos Solemate', 'pemilik@solemate.com', '$2b$10$/qc9fX2jlQiQ8sMp8yisAusCE1ncmf965tIqcI70hFF4dO4sMfNle', 'pemilik', '081234567890', 'SoleMate Workshop, Jl. Contoh No. 1, Jakarta');

-- Akun Pelanggan: pelanggan@solemate.com | Pass: Pelanggan123!
INSERT INTO users (nama, email, password, role, no_hp, alamat) VALUES
('Setiawan', 'Setiawan@gmail.com', '$2b$10$zxABxEkuJ58NAkhvnWVdHeDk03BSIF70yf2qporOazUDnvhkfwrju', 'pelanggan', '089876543210', 'Jl. Melati No. 10, Jakarta');