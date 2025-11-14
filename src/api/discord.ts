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
    return jwt.sign(payload, JWT_SECRET, {
        expiresIn: expiresIn
    } as jwt.SignOptions);
}


const router = Router();

router.get('/discord/callback', async (req, res) => {
    console.log('Discord callback called', req.query);

    if (!req.query.code) {
        throw new Error('NoCodeProvided');
    }
    const code = req.query.code;

    const params = new URLSearchParams();
    params.append('client_id', DISCORD_CLIENT_ID || '');
    params.append('client_secret', DISCORD_CLIENT_SECRET || '');
    params.append('grant_type', 'authorization_code');
    params.append('code', code.toString());
    params.append('redirect_uri', redirect);

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

    const json = await response.json() as Record<string, any>;
    const accessToken = json["access_token"];

    const userResponse = await fetch(`https://discord.com/api/users/@me`, {
        headers: {
            Authorization: `Bearer ${accessToken}`,
        },
    });

    const userJson = await userResponse.json() as Record<string, any>;
    const email = userJson.email;

    const existing = await dbManager.findUserByEmail(email);
    if (existing) {
        const payload: Payload = {
            userId: existing.id.toString(),
            email: existing.email,
            type: 'discord',
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

        return res.redirect('/dashboard');
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
    };

    const newUser = await dbManager.createUser({
        email: email,
        roblox_client: roblox_client
    });

    const payload: Payload = {
        userId: newUser.id.toString(),
        email: newUser.email,
        type: 'discord',
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

    return res.redirect('/dashboard');
});

export default router;