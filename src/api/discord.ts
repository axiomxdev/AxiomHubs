import { Router } from 'express';
import {
    DISCORD_CLIENT_ID,
    DISCORD_CLIENT_SECRET,
    redirect
} from '../server';
import { dbManager } from '../modules/db/DB_manager';

import jwt from 'jsonwebtoken';
import { Payload } from '../types/auth_token';
import { JWT_SECRET } from '../server';
import { RobloxClient } from '../types/roblox_client';
import crypto from 'crypto';
import { cookieConfig } from '../config/cookies';

// Auth token
function createToken(payload: Payload, expiresIn: string = '30d'): string {
    console.log('Creating JWT token with payload:', payload);
    return jwt.sign(payload, JWT_SECRET, {
        expiresIn: expiresIn
    } as jwt.SignOptions);
}

const router = Router();

router.get('/discord/callback', async (req, res) => {
    console.log('Discord callback called');
    console.log('Query parameters:', req.query);

    if (!req.query.code) {
        console.log('No code provided in query');
        return res.status(400).json({ error: 'NoCodeProvided', req: req });
    }
    const code = req.query.code;
    console.log('Authorization code received:', code);

    const params = new URLSearchParams();
    params.append('client_id', DISCORD_CLIENT_ID || '');
    params.append('client_secret', DISCORD_CLIENT_SECRET || '');
    params.append('grant_type', 'authorization_code');
    params.append('code', code.toString());
    params.append('redirect_uri', redirect);

    console.log('Token request params:', params.toString());

    try {
        const response = await fetch(
            `https://discord.com/api/oauth2/token`,
            {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/x-www-form-urlencoded',
                },
                body: params,
            }
        );

        console.log('Token response status:', response.status);

        const json = await response.json() as Record<string, any>;
        console.log('Token response data:', json);

        const accessToken = json["access_token"];
        console.log('Access token received:', accessToken ? 'YES' : 'NO');

        const userResponse = await fetch(`https://discord.com/api/users/@me`, {
            headers: {
                Authorization: `Bearer ${accessToken}`,
            },
        });

        console.log('User info response status:', userResponse.status);

        const userJson = await userResponse.json() as Record<string, any>;
        console.log('User info received:', userJson);

        const email = userJson.email;
        console.log('User email:', email);

        const existing = await dbManager.findUserByEmail(email);
        console.log('Existing user found:', existing ? 'YES' : 'NO');

        if (existing) {
            console.log('Existing user data:', existing);

            const payload: Payload = {
                userId: existing.id.toString(),
                email: existing.email,
                type: 'discord',
                expiration: Math.floor(Date.now() / 1000) + (30 * 24 * 60 * 60),
            };

            const token = createToken(payload);
            console.log('JWT token created for existing user');

            const expiryDate = new Date();
            expiryDate.setDate(expiryDate.getDate() + 30);

            res.cookie('logged', 'true', {
                ...cookieConfig,
                expires: expiryDate,
            });

            res.cookie('auth-token', token, {
                ...cookieConfig,
                expires: expiryDate,
            });

            console.log('Cookies set, redirecting to dashboard');
            return res.redirect('/dashboard');
        }

        console.log('Creating new user...');

        const roblox_client: RobloxClient = {
            userId: '',
            key: crypto.randomBytes(24)
                .toString('base64')
                .replace(/[^a-zA-Z0-9]/g, '')
                .slice(0, 24)
                .match(/.{4}/g)
                ?.join('-') || '',
            type: 'free'
        };

        console.log('Generated roblox client:', roblox_client);

        const newUser = await dbManager.createUser({
            email: email,
            roblox_client: roblox_client
        });

        console.log('New user created:', newUser);

        const payload: Payload = {
            userId: newUser.id.toString(),
            email: newUser.email,
            type: 'discord',
            expiration: Math.floor(Date.now() / 1000) + (30 * 24 * 60 * 60),
        };

        const token = createToken(payload);
        console.log('JWT token created for new user');

        const expiryDate = new Date();
        expiryDate.setDate(expiryDate.getDate() + 30);

        res.cookie('logged', 'true', {
            ...cookieConfig,
            expires: expiryDate,
        });

        res.cookie('auth-token', token, {
            ...cookieConfig,
            expires: expiryDate,
        });

        console.log('Cookies set for new user, redirecting to dashboard');
        return res.redirect('/dashboard');

    } catch (error) {
        console.error('Error in Discord callback:', error);
        res.redirect('/login');
    }
});

export default router;