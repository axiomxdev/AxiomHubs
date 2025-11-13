import { Router } from 'express';
import { dbManager } from '../modules/db/DB_manager';

const router = Router();

router.post('/api/analytics/duration', async (req, res) => {
    try {
        const { sessionId, page, duration } = req.body;

        if (!sessionId || !page || duration === undefined) {
            console.warn('[API] Missing parameters');
            return res.status(400).json({ success: false, message: 'Missing parameters' });
        }

        // Mettre à jour la dernière entrée pour cette session et page
        await dbManager.updateAnalyticsDuration(sessionId, page, duration);

        res.json({ success: true });
    } catch (error) {
        res.status(500).json({ success: false, message: 'Internal server error' });
    }
});

export default router;
