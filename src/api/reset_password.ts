import { Router } from 'express';

import jwt from 'jsonwebtoken';
import { resetToken } from '../types/auth_token';
import { JWT_SECRET } from '../server';
import { dbManager } from '../modules/db/DB_manager';

const router = Router();

router.post('/reset-password', async (req, res) => {
    try {
        const { token, password } = req.body;

        // Verify token
        const decoded = jwt.verify(token, JWT_SECRET) as resetToken;

        const email = decoded.email;

        await dbManager.resetUserPassword(email, password);

        res.json({
            success: true,
            message: 'Password reset successfully'
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
