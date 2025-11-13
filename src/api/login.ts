import { Router } from 'express';
import { dbManager } from '../modules/db/DB_manager';

import jwt from 'jsonwebtoken';
import { Payload } from '../types/auth_token';
import { JWT_SECRET } from '../server';
import { cookieConfig } from '../config/cookies';

// Auth token
function createToken(payload: Payload, expiresIn: string = '30d'): string {
    return jwt.sign(payload, JWT_SECRET, {
        expiresIn: expiresIn
    } as jwt.SignOptions);
}

const router = Router();

router.post('/login', async (req, res) => {
    try {
        const { email, password } = req.body;

        // Validate input
        if (!email || !password) {
            return res.status(400).json({
                success: false,
                message: 'email and password are required'
            });
        }

        // Validate user credentials
        const user = await dbManager.validateUser({ email, password });

        if (!user) {
            return res.status(401).json({
                success: false,
                message: 'Invalid email or password'
            });
        }

        // Update last login timestamp
        await dbManager.updateUserTimestamp(user.id);

        // Create unique token with timestamp to ensure it changes on each login
        const payload: Payload = {
            userId: user.id.toString(),
            email: user.email,
            type: 'account',
            expiration: Math.floor(Date.now() / 1000) + (30 * 24 * 60 * 60), // 30 days expiration
        };

        const token = createToken(payload);

        // Set authentication cookies
        const expiryDate = new Date();
        expiryDate.setDate(expiryDate.getDate() + 30); // 30 days

        res.cookie('logged', 'true', {
            ...cookieConfig,
            expires: expiryDate,
        });

        res.cookie('auth-token', token, {
            ...cookieConfig,
            expires: expiryDate,
        });

        res.json({
            success: true,
            message: 'Login successful',
            user: {
                id: user.id,
                email: user.email
            }
        });
    } catch (error) {
        console.error('Login error:', error);
        res.status(500).json({
            success: false,
            message: 'An error occurred during login'
        });
    }
});

export default router;
