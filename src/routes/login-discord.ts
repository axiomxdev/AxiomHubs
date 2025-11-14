import { Router } from 'express';
import { DISCORD_CLIENT_ID, redirect } from '../server';

const router = Router();

router.get('/login-discord', async (req, res) => {
    res.redirect(`https://discord.com/oauth2/authorize?client_id=${DISCORD_CLIENT_ID}&response_type=code&redirect_uri=${encodeURIComponent(redirect)}&scope=identifyidentify%20email`);
});

export default router;
