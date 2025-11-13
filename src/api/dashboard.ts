import { Router } from 'express';
import { dbManager } from '../modules/db/DB_manager';
import jwt from 'jsonwebtoken';
import { Payload } from '../types/auth_token';
import { JWT_SECRET } from '../server';

const router = Router();

router.get('/dashboard', async (req, res) => {
    try {
        const token = req.cookies['auth-token'];

        // Vérifier si le token existe
        if (!token) {
            return res.status(401).json({
                success: false,
                message: 'No authentication token provided'
            });
        }

        // Vérifier et décoder le token JWT
        let decoded: Payload;
        try {
            decoded = jwt.verify(token, JWT_SECRET) as Payload;
        } catch (error) {
            return res.status(401).json({
                success: false,
                message: 'Invalid or expired token'
            });
        }

        // Vérifier l'expiration du token
        const currentTimestamp = Math.floor(Date.now() / 1000);
        if (decoded.expiration < currentTimestamp) {
            return res.status(401).json({
                success: false,
                message: 'Token has expired'
            });
        }

        // Récupérer l'utilisateur depuis la base de données
        const userId = parseInt(decoded.userId);
        const user = await dbManager.findUserById(userId);

        if (!user) {
            return res.status(404).json({
                success: false,
                message: 'User not found'
            });
        }

        // Retourner les données de l'utilisateur
        res.json({
            success: true,
            user: {
                email: user.email,
                roblox_client: JSON.parse(user.roblox_client)
            }
        });

    } catch (error) {
        console.error('Dashboard error:', error);
        res.status(500).json({
            success: false,
            message: 'An error occurred while fetching dashboard data'
        });
    }
});

export default router;
