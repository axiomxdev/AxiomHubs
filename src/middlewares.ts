import { Application } from 'express';
import strictCookies from './middlewares/strict_cookies';
import setGlobalVar from './middlewares/set_global_var';
import analytics from './middlewares/analytics';

export function setupMiddlewareRoutes(app: Application) {
    app.use(setGlobalVar);
    app.use(analytics);
    app.use(strictCookies);
}