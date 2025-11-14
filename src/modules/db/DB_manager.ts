import sqlite3, { Database } from 'sqlite3';
import * as argon2 from 'argon2';
import path from 'path';
import {
    DBConfig,
    User,
    CreateUserData,
    UserCredentials,
    DBManagerInterface,
    Stat,
} from '../../types/db';

import { DBUri } from '../../server';

import { RobloxClient } from '../../types/roblox_client';

export class DBManager implements DBManagerInterface {
    private db: Database | null = null;
    private dbPath: string;
    private _isOpen: boolean = false;

    constructor(config: DBConfig) {
        this.dbPath = config.filename;
    }

    /**
     * Open database connection and initialize tables
     */
    async open(): Promise<void> {
        console.log(`Opening database at path: ${this.dbPath}`);
        return new Promise((resolve, reject) => {
            this.db = new sqlite3.Database(
                this.dbPath,
                sqlite3.OPEN_READWRITE | sqlite3.OPEN_CREATE,
                (err) => {
                    if (err) {
                        console.error('Error opening database:', err);
                        reject(err);
                    } else {
                        console.log(`Database connected: ${this.dbPath}`);
                        this._isOpen = true;

                        // Configure SQLite for multiple concurrent connections
                        const pragmas = [
                            'PRAGMA journal_mode = WAL;',           // Write-Ahead Logging for concurrent reads
                            'PRAGMA busy_timeout = 10000;',         // Wait 10s if database is locked
                            'PRAGMA synchronous = NORMAL;',         // Balance between safety and performance
                            'PRAGMA cache_size = -64000;',          // 64MB cache
                            'PRAGMA temp_store = MEMORY;',          // Store temp tables in memory
                            'PRAGMA mmap_size = 30000000000;',      // Memory-mapped I/O for better performance
                            'PRAGMA page_size = 4096;',             // Optimal page size
                            'PRAGMA wal_autocheckpoint = 1000;'     // Checkpoint every 1000 pages
                        ];

                        // Execute all pragmas
                        const executePragmas = async () => {
                            for (const pragma of pragmas) {
                                try {
                                    await new Promise((res, rej) => {
                                        this.db!.run(pragma, (err) => {
                                            if (err) {
                                                console.warn(`Failed to execute ${pragma}:`, err.message);
                                            }
                                            res(null);
                                        });
                                    });
                                } catch (err) {
                                    console.warn('Pragma execution error:', err);
                                }
                            }
                        };

                        executePragmas()
                            .then(() => this.initializeTables())
                            .then(() => resolve())
                            .catch(reject);
                    }
                }
            );
        });
    }

    /**
     * Close database connection
     */
    async close(): Promise<void> {
        return new Promise((resolve, reject) => {
            if (!this.db) {
                resolve();
                return;
            }

            this.db.close((err) => {
                if (err) {
                    console.error('Error closing database:', err);
                    reject(err);
                } else {
                    console.log('Database connection closed');
                    this._isOpen = false;
                    this.db = null;
                    resolve();
                }
            });
        });
    }

    /**
     * Check if database is open
     */
    isOpen(): boolean {
        return this._isOpen && this.db !== null;
    }

    /**
     * Initialize database tables
     */
    private async initializeTables(): Promise<void> {
        const createUsersTable = `
        CREATE TABLE IF NOT EXISTS users (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            email TEXT UNIQUE NOT NULL,
            password_hash TEXT,
            roblox_client TEXT NOT NULL,
            created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
            updated_at DATETIME DEFAULT CURRENT_TIMESTAMP
        )
        `;

        const createWebsiteAnalyticsTable = `
        CREATE TABLE IF NOT EXISTS websiteAnalytics (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            user_id INTEGER,
            page TEXT,
            action TEXT,
            timestamp DATETIME DEFAULT CURRENT_TIMESTAMP,
            session_id TEXT,
            device TEXT,
            browser TEXT,
            referrer TEXT,
            duration INTEGER,
            ip TEXT,
            created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
            FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE SET NULL
        )
        `;

        // Create both tables
        await this.run(createUsersTable);
        await this.run(createWebsiteAnalyticsTable);
    }

    /**
     * Run a SQL query without returning results
     */
    private async run(sql: string, params: any[] = []): Promise<void> {
        return new Promise((resolve, reject) => {
            if (!this.db) {
                reject(new Error('Database not open'));
                return;
            }

            this.db.run(sql, params, (err) => {
                if (err) {
                    console.error('SQL Error:', err);
                    reject(err);
                } else {
                    resolve();
                }
            });
        });
    }

    /**
     * Get a single row from database
     */
    private async get<T>(sql: string, params: any[] = []): Promise<T | null> {
        return new Promise((resolve, reject) => {
            if (!this.db) {
                reject(new Error('Database not open'));
                return;
            }

            this.db.get(sql, params, (err, row) => {
                if (err) {
                    console.error('SQL Error:', err);
                    reject(err);
                } else {
                    resolve((row as T) || null);
                }
            });
        });
    }

    /**
     * Get all rows from database
     */
    private async all<T>(sql: string, params: any[] = []): Promise<T[]> {
        return new Promise((resolve, reject) => {
            if (!this.db) {
                reject(new Error('Database not open'));
                return;
            }

            this.db.all(sql, params, (err, rows) => {
                if (err) {
                    console.error('SQL Error:', err);
                    reject(err);
                } else {
                    resolve((rows as T[]) || []);
                }
            });
        });
    }

    /**
     * Push analyctics data
     */

    async pushAnalytics(data: Stat): Promise<void> {
        const sql = `
        INSERT INTO websiteAnalytics 
        (user_id, page, action, timestamp, session_id, device, browser, referrer, duration, ip)
        VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
        `;

        await this.run(sql, [
            data.user_id,
            data.page,
            data.action,
            data.timestamp,
            data.session_id,
            data.device,
            data.browser,
            data.referrer,
            data.duration,
            data.ip
        ]);
    }

    /**
     * Update analytics duration
     */
    async updateAnalyticsDuration(sessionId: string, page: string, duration: number): Promise<void> {
        const sql = `
        UPDATE websiteAnalytics 
        SET duration = ?
        WHERE id = (
            SELECT id FROM websiteAnalytics
            WHERE session_id = ? AND page = ?
            ORDER BY timestamp DESC
            LIMIT 1
        )
        `;

        await this.run(sql, [duration, sessionId, page]);
    }

    /**
     * Create a new user with hashed password
     */
    async createUser(data: CreateUserData): Promise<User> {
        console.log('[DBManager] createUser called with data:', { email: data.email, hasPassword: !!data.password, robloxClient: data.roblox_client });

        if (!this.isOpen()) {
            console.error('[DBManager] createUser failed: Database not open');
            throw new Error('Database not open');
        }
        console.log('[DBManager] Database is open, proceeding with user creation');

        // Check if username already exists
        console.log('[DBManager] Checking if user already exists with email:', data.email);
        const existingUser = await this.findUserByEmail(data.email);
        if (existingUser) {
            console.error('[DBManager] createUser failed: Username already exists for email:', data.email);
            throw new Error('Username already exists');
        }
        console.log('[DBManager] No existing user found, proceeding with creation');

        let passwordHash: string | null;

        if (data.password) {
            console.log('[DBManager] Hashing password with Argon2');
            // Hash password with Argon2 (most secure and performant)
            passwordHash = await argon2.hash(data.password, {
                type: argon2.argon2id, // Hybrid version (recommended)
                memoryCost: 65536, // 64 MB
                timeCost: 3, // 3 iterations
                parallelism: 4, // 4 threads
            });
            console.log('[DBManager] Password hashed successfully');
        } else {
            console.log('[DBManager] No password provided, setting passwordHash to null');
            passwordHash = null;
        }

        const sql = `
            INSERT INTO users (email, password_hash, roblox_client)
            VALUES (?, ?, ?)
        `;

        console.log('[DBManager] Executing INSERT query:', sql);
        console.log('[DBManager] Query parameters:', [data.email, passwordHash ? '[HASH]' : null, JSON.stringify(data.roblox_client)]);

        return new Promise((resolve, reject) => {
            if (!this.db) {
                console.error('[DBManager] Database instance is null in Promise');
                reject(new Error('Database not open'));
                return;
            }

            // Store reference to the database instance
            const db = this.db;
            console.log('[DBManager] Database reference stored, executing INSERT');

            db.run(
                sql,
                [data.email, passwordHash, JSON.stringify(data.roblox_client)],
                function (err) {
                    if (err) {
                        console.error('[DBManager] Error creating user:', err);
                        console.error('[DBManager] SQL that failed:', sql);
                        console.error('[DBManager] Parameters that failed:', [data.email, passwordHash ? '[HASH]' : null, JSON.stringify(data.roblox_client)]);
                        reject(err);
                    } else {
                        // Fetch the created user
                        const userId = this.lastID;
                        console.log('[DBManager] User created successfully with ID:', userId);

                        const selectSql = 'SELECT * FROM users WHERE id = ?';
                        console.log('[DBManager] Fetching created user with query:', selectSql);
                        console.log('[DBManager] User ID to fetch:', userId);

                        db.get(selectSql, [userId], (err: Error, row: User) => {
                            if (err) {
                                console.error('[DBManager] Error fetching created user:', err);
                                reject(err);
                            } else {
                                console.log('[DBManager] Created user fetched successfully:', { id: row?.id, email: row?.email });
                                resolve(row);
                            }
                        });
                    }
                }
            );
        });
    }

    /**
     * Reset user password
     */
    async resetUserPassword(email: string, newPassword: string): Promise<boolean> {
        const user = await this.findUserByEmail(email);
        if (!user) {
            return false;
        }

        // Hash new password
        const newHash = await argon2.hash(newPassword, {
            type: argon2.argon2id,
            memoryCost: 65536,
            timeCost: 3,
            parallelism: 4,
        });

        const sql = 'UPDATE users SET password_hash = ?, updated_at = CURRENT_TIMESTAMP WHERE email = ?';
        await this.run(sql, [newHash, email]);
        return true;
    }

    /**
     * Run sql query
     */
    async query<T>(sql: string, params: any[] = []): Promise<T[]> {
        return this.all<T>(sql, params);
    }

    /**
     * Find user by key
     */
    async findUserByKey(key: string): Promise<User | null> {
        const sql = 'SELECT * FROM users WHERE json_extract(roblox_client, \'$.key\') = ?';
        return this.get<User>(sql, [key]);
    }

    /**
     * Find user by username
     */
    async findUserByEmail(email: string): Promise<User | null> {
        console.log(`[DBManager] findUserByEmail called with email: ${email}`);

        const sql = 'SELECT * FROM users WHERE email = ?';
        console.log(`[DBManager] Executing SQL: ${sql}`);
        console.log(`[DBManager] SQL params:`, [email]);

        try {
            const result = await this.get<User>(sql, [email]);
            console.log(`[DBManager] findUserByEmail result:`, result ? 'User found' : 'No user found');
            if (result) {
                console.log(`[DBManager] Found user ID: ${result.id}, Email: ${result.email}`);
            }
            return result;
        } catch (error) {
            console.error(`[DBManager] Error in findUserByEmail:`, error);
            throw error;
        }
    }

    /**
     * Find user by ID
     */
    async findUserById(id: number): Promise<User | null> {
        const sql = 'SELECT * FROM users WHERE id = ?';
        return this.get<User>(sql, [id]);
    }

    /**
     * Validate user credentials (login)
     */
    async validateUser(credentials: UserCredentials): Promise<User | null> {
        const user = await this.findUserByEmail(credentials.email);

        if (!user) {
            return null;
        }

        // Verify password with Argon2
        const isValid = await argon2.verify(
            user.password_hash,
            credentials.password
        );

        return isValid ? user : null;
    }

    /**
     * Delete user by ID
     */
    async deleteUser(id: number): Promise<boolean> {
        const sql = 'DELETE FROM users WHERE id = ?';

        try {
            await this.run(sql, [id]);
            return true;
        } catch (error) {
            console.error('Error deleting user:', error);
            return false;
        }
    }

    /**
     * Update key's userId
     */
    async updateKeyUserId(key: string, userId: number): Promise<void> {
        const sql = `UPDATE users
        SET roblox_client = json_set(roblox_client, '$.userId', ?)
        WHERE json_extract(roblox_client, '$.key') = ?`;
        await this.run(sql, [userId, key]);
    }

    /**
     * Update user's last updated timestamp
     */
    async updateUserTimestamp(id: number): Promise<void> {
        const sql = 'UPDATE users SET updated_at = CURRENT_TIMESTAMP WHERE id = ?';
        return this.run(sql, [id]);
    }

    /**
     * Get all users (admin function - be careful!)
     */
    async getAllUsers(): Promise<User[]> {
        const sql = 'SELECT * FROM users ORDER BY created_at DESC';
        return this.all<User>(sql);
    }
}

// Export singleton instance
export const dbManager = new DBManager({
    filename: String(DBUri),
});
