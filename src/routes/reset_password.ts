import { Router } from "express";
import { JWT_SECRET } from '../server';
import { resetToken } from '../types/auth_token';
import jwt from 'jsonwebtoken';

const router = Router();

router.get('/reset-password', (req, res) => {
    const token = req.query.token as string;

    if (!token) {
        return res.redirect('/login');
    }

    try {
        // Verify and decode token
        const decoded = jwt.verify(token, JWT_SECRET) as resetToken;

        // Render reset password page with email from token
        res.render('reset-password', {
            email: decoded.email,
            token: token
        });
    } catch (error) {
        return res.redirect('/login');
    }
});

export default router;
