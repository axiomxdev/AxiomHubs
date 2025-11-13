import { Router } from 'express';

const router = Router();

router.get('/cookies', (req, res) => {
    res.render('cookies', {
        redirectTo: '/'
    });
});

export default router;
