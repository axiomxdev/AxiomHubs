import { Router } from 'express';
import { cookieConfig } from '../config/cookies';

const router = Router();

router.post('/set-consent', (req, res) => {
    const expiryDate = new Date();
    expiryDate.setFullYear(expiryDate.getFullYear() + 1);

    res.cookie('consent', 'true', {
        ...cookieConfig,
        expires: expiryDate,
    });

    res.status(200).json({ success: true });
});

export default router;
