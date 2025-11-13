import { Router } from 'express';

import jwt from 'jsonwebtoken';
import { resetToken } from '../types/auth_token';
import { JWT_SECRET } from '../server';

import {
    emailHost,
    emailPort,
    emailUser,
    emailPass,
    forgetPasswordUrl
} from '../server';

import nodemailer from 'nodemailer';
import { loadEmailTemplate } from '../utils/email-templates';

// Auth token
function createToken(payload: resetToken, expiresIn: string = '30d'): string {
    return jwt.sign(payload, JWT_SECRET, {
        expiresIn: expiresIn
    } as jwt.SignOptions);
}

const router = Router();

router.post('/forgot-password', async (req, res) => {
    try {
        const email = req.body.email;

        // Validate input
        if (!email) {
            return res.status(400).json({
                success: false,
                message: 'Email is required'
            });
        }

        // Create reset token
        const payload: resetToken = {
            email: email
        };

        const token = createToken(payload, '10m'); // Token valid for 10 minutes

        const transporter = nodemailer.createTransport({
            host: String(emailHost),
            port: Number(emailPort),
            secure: true,
            auth: {
                user: emailUser,
                pass: emailPass
            }
        });

        const resetLink = forgetPasswordUrl + token;

        // Load email templates
        const emailContent = loadEmailTemplate('password-reset', {
            RESET_LINK: resetLink,
        });

        const mailOptions = {
            from: `"Axiom Hub's Support" <${emailUser}>`,
            to: email,
            subject: '🔐 Reset Your Axiom Hub\'s Password',
            html: emailContent.html,
            text: emailContent.text,
        };

        // Send email
        await transporter.sendMail(mailOptions);

        res.json({
            success: true,
            message: 'Password reset email sent successfully'
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
