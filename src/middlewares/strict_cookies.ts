import { Router } from "express";

const router = Router();

// Routes qui ne nécessitent pas le consentement des cookies
const publicRoutes = [
    '/',
    '/status',
    '/cookies',
    '/cookie-policy',
    '/api/set-consent',
    '/api/analytics/duration',
    '/api/check-key'
];

router.use((req, res, next) => {
    // Skip cookie check for public routes
    if (publicRoutes.includes(req.path) || req.path.startsWith('/assets') || req.path.startsWith('/css') || req.path.startsWith('/js')) {
        return next();
    }

    // Check if user has accepted cookies
    if (!(req.cookies && req.cookies.consent === 'true')) {
        return res.render('cookies', {
            redirectTo: req.originalUrl
        });
    }

    next();
});

export default router;