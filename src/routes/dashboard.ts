import { Router } from 'express';
import jwt from 'jsonwebtoken';
import { Payload } from '../types/auth_token';
import { JWT_SECRET } from '../server';
import emailAuth from '../auth/email_auth.json';
import { adminDashboard } from '../modules/dashboard/admin_dashboard';
const router = Router();

router.get('/dashboard', (req, res) => {
    try {
        const token = req.cookies['auth-token'];

        if (!token) {
            return res.redirect('/login');
        }

        const decoded = jwt.verify(token, JWT_SECRET) as Payload;

        if (decoded.email && emailAuth.includes(decoded.email))
            return adminDashboard(res, decoded);

        return res.render('dashboard');
    } catch (error) {
        return res.render('dashboard');
    }
});

export default router;
