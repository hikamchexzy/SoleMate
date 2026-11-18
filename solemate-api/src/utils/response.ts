// src/utils/response.ts
import { Response } from 'express';

interface ApiResponse<T = unknown> {
  success: boolean;
  message: string;
  data?: T;
  errors?: unknown;
}

export const success = <T>(
  res: Response,
  message: string,
  data?: T,
  statusCode = 200
): Response => {
  const body: ApiResponse<T> = { success: true, message };
  if (data !== undefined) body.data = data;
  return res.status(statusCode).json(body);
};

export const error = (
  res: Response,
  message: string,
  statusCode = 400,
  errors?: unknown
): Response => {
  const body: ApiResponse = { success: false, message };
  if (errors !== undefined) body.errors = errors;
  return res.status(statusCode).json(body);
};