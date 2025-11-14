import { Router } from 'express';
import jwt from 'jsonwebtoken';
import { Payload } from '../types/auth_token';
import { JWT_SECRET } from '../server';
import emailAuth from '../auth/email_auth.json';
import { adminDashboard } from '../modules/dashboard/admin_dashboard';
const router = Router();

router.get('/dashboard', (req, res) => {
    try {
        console.log('Dashboard route accessed');
        const token = req.cookies['auth-token'];
        console.log('Token from cookies:', token);

        if (!token) {
            console.log('No token found, redirecting to login');
            return res.redirect('/login');
        }

        const decoded = jwt.verify(token, JWT_SECRET) as Payload;
        console.log('Decoded token:', decoded);

        console.log('Checking email authorization...');
        console.log('Decoded email:', decoded.email);
        console.log('Authorized emails:', emailAuth);
        console.log('Is email authorized:', emailAuth.includes(decoded.email));

        if (decoded.email && emailAuth.includes(decoded.email)) {
            console.log('Admin access granted, rendering admin dashboard');
            return adminDashboard(res, decoded);
        }

        console.log('Regular user access, rendering standard dashboard');
        return res.render('dashboard');
    } catch (error) {
        console.log('Error in dashboard route:', error);
        return res.redirect('/login');
    }
});

export default router;
