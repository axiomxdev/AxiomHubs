import { Application } from 'express';
import indexRouter from './routes/index';
import statusRouter from './routes/status';
import cookiesRouter from './routes/cookies';
import cookiePolicyRouter from './routes/cookie-policy';
import loginRouter from './routes/login';
import registerRouter from './routes/register';
import forgotPasswordRouter from './routes/forgot-password';
import resetPasswordRouter from './routes/reset_password';
import loginDiscordRouter from './routes/login-discord';
import dashboardRouter from './routes/dashboard';

export function setupPageRoutes(app: Application) {
    app.use('/', indexRouter);
    app.use('/', statusRouter);
    app.use('/', cookiesRouter);
    app.use('/', cookiePolicyRouter);
    app.use('/', loginRouter);
    app.use('/', registerRouter);
    app.use('/', forgotPasswordRouter);
    app.use('/', resetPasswordRouter);
    app.use('/', loginDiscordRouter);
    app.use('/', dashboardRouter);
}
