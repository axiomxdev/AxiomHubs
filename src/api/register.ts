import { Router } from 'express';
import { dbManager } from '../modules/db/DB_manager';
import crypto from 'crypto';
import { RobloxClient } from '../types/roblox_client';

const router = Router();

router.post('/register', async (req, res) => {
    try {
        const { email, password } = req.body;

        // Validate input
        if (!email || !password) {
            return res.status(400).json({
                success: false,
                message: 'Username and password are required'
            });
        }

        // Check if email already exists
        const existingUser = await dbManager.findUserByEmail(email);
        if (existingUser) {
            return res.status(409).json({
                success: false,
                message: 'Email already exists'
            });
        }

        const roblox_client: RobloxClient = {
            userId: '',
            key: crypto.randomBytes(24)
                .toString('base64')
                .replace(/[^a-zA-Z0-9]/g, '')
                .slice(0, 24)
                .match(/.{4}/g)
                ?.join('-') || '',
            type: 'free'
        }

        // Create user
        const user = await dbManager.createUser({
            email,
            password,
            roblox_client
        });

        res.status(201).json({
            success: true,
            userId: user.id,
            message: 'User registered successfully'
        });
    } catch (error) {
        console.error('Registration error:', error);
        res.status(500).json({
            success: false,
            message: 'An error occurred during registration'
        });
    }
});

export default router;
