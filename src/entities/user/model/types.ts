import type { User as SupabaseUser } from '@supabase/supabase-js';

export type User = SupabaseUser;

export interface AuthCredentials {
  email: string;
  password: string;
}

export interface SignUpCredentials extends AuthCredentials {
  confirmPassword?: string;
}
