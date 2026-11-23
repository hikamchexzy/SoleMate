// src/types/models.ts
export type Role = 'pemilik' | 'pelanggan';

export type StatusPesanan =
  | 'menunggu_konfirmasi'
  | 'dalam_pengiriman_masuk'
  | 'diterima'
  | 'dicuci'
  | 'selesai'
  | 'dalam_pengiriman_keluar'
  | 'selesai_diambil';

export interface User {
  id: number;
  nama: string;
  email: string;
  password: string;
  role: Role;
  no_hp: string | null;
  alamat: string | null;
  foto_profil: string | null;
  created_at: string;
  updated_at: string;
}

export interface Paket {
  id: number;
  nama_paket: string;
  deskripsi: string | null;
  harga: number;
  estimasi_hari: number;
  gambar: string | null;
  is_active: number;
  created_at: string;
  updated_at: string;
}

export interface Pesanan {
  id: number;
  user_id: number;
  paket_id: number;
  foto_sepatu: string | null;
  catatan: string | null;
  no_hp_kontak: string;
  tingkat_kekotoran: 'ringan' | 'sedang' | 'berat';
  resi_masuk: string | null;
  bukti_bayar: string | null;
  resi_keluar: string | null;
  foto_before: string | null;
  foto_after: string | null;
  total_harga: number;
  status: StatusPesanan;
  tanggal_pesan: string;
  tanggal_selesai: string | null;
  updated_at: string;
}

export interface JwtPayload {
  id: number;
  email: string;
  role: Role;
}