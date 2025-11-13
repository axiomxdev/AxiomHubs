import { Router } from "express";

const router = Router();

router.use((req, res, next) => {
    res.locals.cookies = req.cookies && req.cookies.consent === 'true';
    res.locals.connected = req.cookies && req.cookies.logged === 'true';
    next();
});

export default router;