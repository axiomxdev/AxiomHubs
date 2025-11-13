import { Router } from 'express';

const router = Router();

router.get('/cookie-policy', (req, res) => {
    res.render('cookie-policy');
});

export default router;
