import { Payload } from '../../types/auth_token';
import { Response } from 'express';
import { GetMember } from './sql_request/GetMember';
import { GetAnalytics } from './sql_request/GetAnalytics';

export async function adminDashboard(res: Response, decoded: Payload) {

    const usersStats = await GetMember();
    const analytics = await GetAnalytics();

    res.render('dashboard-admin',
        {
            usersStats: usersStats.monthly,
            usersStatsWeekly: usersStats.weekly,
            analytics: analytics
        }
    );
}