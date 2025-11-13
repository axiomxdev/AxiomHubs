import { Router } from 'express';
import { dbManager } from '../modules/db/DB_manager';
import { json } from 'stream/consumers';

const router = Router();

router.get('/check-key', async (req, res) => {
    const { key, userId } = req.query;
    if (!(key && userId)) {
        return res.status(400).json({ valid: false, message: 'Missing key or userId' });
    }

    const userData = await dbManager.findUserByKey(key as string);
    const keyData = JSON.parse(userData?.roblox_client || '{}');

    if (keyData.userId === '') {
        keyData.userId = userId;
        await dbManager.updateKeyUserId(key as string, keyData.userId);
        return res.status(200).json({ valid: true });
    } else if (keyData.userId === userId) {
        return res.status(200).json({ valid: true });
    } else {
        return res.status(404).json({ valid: false, message: 'Key not found' });
    }
});

export default router;