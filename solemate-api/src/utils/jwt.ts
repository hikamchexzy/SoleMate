import jwt from 'jsonwebtoken';
import { env } from '../config/env';
import { JwtPayload } from '../types/models';

export const generateToken = (payload: JwtPayload): string => {
  return jwt.sign(payload, env.JWT.secret, {
    expiresIn: env.JWT.expiresIn as jwt.SignOptions['expiresIn'],
  });
};

export const verifyToken = (token: string): JwtPayload => {
  return jwt.verify(token, env.JWT.secret) as JwtPayload;
};