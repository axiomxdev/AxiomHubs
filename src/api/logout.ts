import { Router } from 'express';
import { cookieConfig } from '../config/cookies';

const router = Router();

router.post('/logout', (req, res) => {
    res.clearCookie('logged', cookieConfig);
    res.clearCookie('auth-token', cookieConfig);

    res.status(200).json({ success: true });
});

export default router;
