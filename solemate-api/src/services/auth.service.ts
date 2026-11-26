import bcrypt from 'bcrypt';
import { pool } from '../config/db';
import { User } from '../types/models';
import { RowDataPacket, ResultSetHeader } from 'mysql2';

export const registerUser = async (data: any): Promise<number> => {
  const { nama, email, password, no_hp, alamat } = data;

  // Cek apakah email sudah terdaftar
  const [existing] = await pool.query<RowDataPacket[]>(
    'SELECT id FROM users WHERE email = ?', [email]
  );
  if (existing.length > 0) throw new Error('Email sudah terdaftar');

  // Hash password
  const hashedPassword = await bcrypt.hash(password, 10);

  // Insert ke database (default role: pelanggan)
  const [result] = await pool.query<ResultSetHeader>(
    'INSERT INTO users (nama, email, password, role, no_hp, alamat) VALUES (?, ?, ?, ?, ?, ?)',
    [nama, email, hashedPassword, 'pelanggan', no_hp || null, alamat || null]
  );

  return result.insertId;
};

export const loginUser = async (email: string, pass: string): Promise<User> => {
  const [rows] = await pool.query<RowDataPacket[]>(
    'SELECT * FROM users WHERE email = ?', [email]
  );

  if (rows.length === 0) throw new Error('Email atau password salah');

  const user = rows[0] as User;

  // Cek password
  const isMatch = await bcrypt.compare(pass, user.password);
  if (!isMatch) throw new Error('Email atau password salah');

  return user;
};

export const getUserById = async (userId: number): Promise<User | null> => {
  const [rows] = await pool.query<RowDataPacket[]>(
    'SELECT id, nama, email, role, no_hp, alamat, foto_profil FROM users WHERE id = ?',
    [userId]
  );

  return rows.length > 0 ? (rows[0] as User) : null;
};

export const updateProfil = async (
  userId: number, 
  nama: string, 
  noHp: string, 
  fotoUrl?: string // Tanda tanya (?) artinya opsional (boleh kosong)
): Promise<boolean> => {
  
  let query = 'UPDATE users SET nama = ?, no_hp = ?';
  const values: any[] = [nama, noHp];

  // Jika ada foto baru yang diupload, tambahkan ke query
  if (fotoUrl) {
    query += ', foto_profil = ?';
    values.push(fotoUrl);
  }

  query += ' WHERE id = ?';
  values.push(userId);

  const [result] = await pool.query<ResultSetHeader>(query, values);
  return result.affectedRows > 0;
};