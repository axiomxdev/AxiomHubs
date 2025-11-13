import { Router } from 'express';

const router = Router();

router.get('/forgot-password', (req, res) => {
    res.render('forgot-password');
});

export default router;
