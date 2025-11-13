import { Router } from 'express';

const router = Router();

router.get('/status', async (req, res) => {
    res.render('status');
});

export default router;
