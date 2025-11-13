import { RobloxClient } from './roblox_client';

export interface Stat {
    user_id: number | null;
    page: string;
    action: string;
    timestamp: Date;
    session_id: string;
    device: string;
    browser: string;
    referrer: string | null;
    duration: number;
    ip: string;
}

export interface DBConfig {
    filename: string;
    mode?: number;
}

export interface User {
    id: number;
    email: string;
    password_hash: string;
    roblox_client: string;
    roblox_account_id: string | null;
    created_at: string;
    updated_at: string;
}

export interface CreateUserData {
    email: string;
    password?: string;
    roblox_client: RobloxClient;
}

export interface UserCredentials {
    email: string;
    password: string;
}

export interface DBManagerInterface {
    open(): Promise<void>;
    close(): Promise<void>;
    isOpen(): boolean;
    resetUserPassword(email: string, newPassword: string): Promise<boolean>;
    pushAnalytics(data: Stat): Promise<void>;
    createUser(data: CreateUserData): Promise<User>;
    query<T>(sql: string, params: any[]): Promise<T[]>;
    findUserByKey(key: string): Promise<User | null>;
    findUserByEmail(username: string): Promise<User | null>;
    findUserById(id: number): Promise<User | null>;
    updateUserTimestamp(id: number): Promise<void>;
    updateKeyUserId(key: string, userId: number): Promise<void>;
    validateUser(credentials: UserCredentials): Promise<User | null>;
    deleteUser(id: number): Promise<boolean>;
}
