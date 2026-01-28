import dotenv from 'dotenv';

dotenv.config();

export const DISCORD_CLIENT_ID = process.env.DISCORD_CLIENT_ID;
export const DISCORD_CLIENT_SECRET = process.env.DISCORD_CLIENT_SECRET;
export const redirect = process.env.REDIRECT_URI || 'http://localhost:3000/api/discord/callback';
export const forgetPasswordUrl = process.env.FORGET_PASSWORD_URL || 'http://localhost:3000/reset-password?token=';
export const emailHost = process.env.EMAIL_HOST;
export const emailPort = process.env.EMAIL_PORT;
export const emailUser = process.env.EMAIL_USER;
export const emailPass = process.env.EMAIL_PASS;
export const imapHost = process.env.IMAP_HOST;
export const imapPort = process.env.IMAP_PORT;
export const mailWebhookUrl = process.env.MAIL_WEBHOOK_URL;
export const DBUri = process.env.DB_PATH;

import express from 'express';
import path from 'path';
import { setupPageRoutes } from './routes_link';
import { setupApiRoutes } from './api_link';
import { setupMiddlewareRoutes } from './middlewares';
import { dbManager } from './modules/db/DB_manager';
import { startEmailListener, stopEmailListener } from './services/email_listener';
import { setup404Handler } from './routes/404';
import crypto from 'crypto';
import cookieParser from 'cookie-parser';

const app = express();
const PORT: number = process.env.PORT ? parseInt(process.env.PORT) : 3000;
// secret for JWT
export const JWT_SECRET = process.env.JWT_SECRET || crypto.randomBytes(64).toString('hex');

// Set EJS as template engine
app.set('view engine', 'ejs');
app.set('views', path.join(__dirname, 'views'));

// Serve static files
app.use(express.static(path.join(__dirname, 'public')));

// middlewares init
app.use(cookieParser());

// Add JSON body parser
app.use(express.json());

// Initialize database
async function startServer() {
    try {
        await dbManager.open();

        setupMiddlewareRoutes(app);
        setupApiRoutes(app);
        setupPageRoutes(app);

        // Setup 404 handler (must be last)
        setup404Handler(app);

        // Start email listener
        await startEmailListener();

        app.listen(PORT, () => {
            console.log(`Server running on http://localhost:${PORT}`);
        });

    } catch (error) {
        console.error('Failed to start server:', error);
        process.exit(1);
    }
}

// Handle graceful shutdown
let isShuttingDown = false;

async function gracefulShutdown(signal: string) {
    if (isShuttingDown) {
        return;
    }
    isShuttingDown = true;

    console.log(`\nReceived ${signal}. Shutting down gracefully...`);

    try {
        await stopEmailListener();

        if (dbManager.isOpen()) {
            await dbManager.close();
        }
        process.exit(0);
    } catch (error) {
        console.error('Error during shutdown:', error);
        process.exit(1);
    }
}

process.on('SIGINT', () => gracefulShutdown('SIGINT'));
process.on('SIGTERM', () => gracefulShutdown('SIGTERM'));

startServer();