import { Router, Request, Response } from 'express';

const router = Router();

// Middleware 404 - doit être ajouté en dernier
export function setup404Handler(app: any) {
    app.use((req: Request, res: Response) => {
        res.status(404).render('404');
    });
}

export default router;
