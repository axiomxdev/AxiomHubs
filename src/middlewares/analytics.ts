import { Router } from 'express';
import { v4 as uuidv4 } from 'uuid';
import jwt from 'jsonwebtoken';
import { Payload } from '../types/auth_token';
import { JWT_SECRET } from '../server';
import { cookieConfig } from '../config/cookies';
import { dbManager } from '../modules/db/DB_manager';
import { Stat } from '../types/db';

const router = Router();

// Cache pour éviter d'enregistrer plusieurs fois la même visite rapidement
const visitCache = new Map<string, number>();
const CACHE_DURATION = 30000; // 30 secondes

// Fonction pour extraire le nom du navigateur depuis le user-agent
function extractBrowserName(userAgent: string): string {
    if (!userAgent) return 'Unknown';

    if (userAgent.includes('Edg/')) return 'Microsoft Edge';
    if (userAgent.includes('Chrome/') && !userAgent.includes('Edg/')) return 'Google Chrome';
    if (userAgent.includes('Firefox/')) return 'Mozilla Firefox';
    if (userAgent.includes('Safari/') && !userAgent.includes('Chrome/')) return 'Safari';
    if (userAgent.includes('Opera/') || userAgent.includes('OPR/')) return 'Opera';
    if (userAgent.includes('MSIE') || userAgent.includes('Trident/')) return 'Internet Explorer';
    if (userAgent.includes('Brave/')) return 'Brave';

    return 'Unknown';
}

router.use((req, res, next) => {
    // Génère un ID de session si non présent
    if (!req.cookies.sessionID) {
        const sessionID = uuidv4();
        // Cookie pour le backend (httpOnly)
        res.cookie('sessionID', sessionID, {
            ...cookieConfig,
        });
        // Cookie pour le frontend (pas httpOnly, lisible par JavaScript)
        res.cookie('sessionID_client', sessionID, {
            httpOnly: false,
            sameSite: "strict",
            path: '/'
        });
        req.cookies.sessionID = sessionID;
    }

    res.on('finish', async () => {
        const token = req.cookies['auth-token'] || null;

        // Si pas de token, on enregistre quand même la stat mais sans user_id
        let decoded: Payload | null = null;
        if (token) {
            try {
                decoded = jwt.verify(token, JWT_SECRET) as Payload;
            } catch (error) {

            }
        }

        // Créer une clé unique pour cette visite (session + page)
        const cacheKey = `${req.cookies.sessionID}_${req.originalUrl}`;
        const now = Date.now();
        const lastVisit = visitCache.get(cacheKey);

        // Si la même page a été visitée il y a moins de 30 secondes
        if (lastVisit && (now - lastVisit) < CACHE_DURATION) {
            return;
        }

        // Mettre à jour le cache
        visitCache.set(cacheKey, now);

        // Nettoyer les vieilles entrées du cache
        for (const [key, timestamp] of visitCache.entries()) {
            if (now - timestamp > CACHE_DURATION) {
                visitCache.delete(key);
            }
        }

        const stat = {
            user_id: decoded?.userId || null,
            page: req.originalUrl,
            action: 'visit',
            timestamp: new Date(),
            session_id: req.cookies.sessionID,
            device: req.headers['user-agent'],
            browser: extractBrowserName(req.headers['user-agent'] as string),
            referrer: req.get('Referrer') || null,
            duration: 0, // Sera mis à jour par le frontend
            ip: req.ip,
        } as Stat;

        try {
            await dbManager.pushAnalytics(stat);
        } catch (err) {
            console.error('Erreur lors de l\'enregistrement des stats :', err);
        }
    });

    next();
});

export default router;
