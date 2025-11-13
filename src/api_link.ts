import { Application } from 'express';
import registerRouter from './api/register';
import loginRouter from './api/login';
import dashboardRouter from './api/dashboard';
import discordRouter from './api/discord';
import forgotPasswordRouter from './api/forgot_password';
import consentRouter from './api/consent';
import logoutRouter from './api/logout';
import resetPasswordRouter from './api/reset_password';
import analyticsDurationRouter from './api/analytics_duration';
import checkKeyRouter from './api/check_key';

export function setupApiRoutes(app: Application) {
    // API Routes
    app.use(analyticsDurationRouter); // Analytics doit être avant les autres
    app.use('/api', registerRouter);
    app.use('/api', loginRouter);
    app.use('/api', dashboardRouter);
    app.use('/api', discordRouter);
    app.use('/api', forgotPasswordRouter);
    app.use('/api', consentRouter);
    app.use('/api', logoutRouter);
    app.use('/api', resetPasswordRouter);
    app.use('/api', checkKeyRouter);
}
