import { dbManager } from '../../db/DB_manager';

export interface AnalyticsStats {
    totalVisits: number;
    uniqueVisitors: number;
    uniqueSessions: number;
    uniqueIPs: number;
    avgDuration: number;
    topPages: Array<{ page: string; visits: number }>;
    topBrowsers: Array<{ browser: string; count: number }>;
    topReferrers: Array<{ referrer: string; count: number }>;
    visitorTypes: { anonymous: number };
}

export async function GetAnalytics(): Promise<AnalyticsStats> {
    // Total des visites
    const totalVisitsResult = await dbManager.query('SELECT COUNT(*) as count FROM websiteAnalytics') as Array<{ count: number }>;
    const totalVisits = totalVisitsResult[0]?.count || 0;

    // Sessions uniques
    const uniqueSessionsResult = await dbManager.query('SELECT COUNT(DISTINCT session_id) as count FROM websiteAnalytics') as Array<{ count: number }>;
    const uniqueSessions = uniqueSessionsResult[0]?.count || 0;

    // IPs uniques
    const uniqueIPsResult = await dbManager.query('SELECT COUNT(DISTINCT ip) as count FROM websiteAnalytics') as Array<{ count: number }>;
    const uniqueIPs = uniqueIPsResult[0]?.count || 0;

    // Nombre d'utilisateurs authentifiés distincts
    const authenticatedUsersResult = await dbManager.query('SELECT COUNT(DISTINCT user_id) as count FROM websiteAnalytics WHERE user_id IS NOT NULL') as Array<{ count: number }>;
    const authenticatedUsers = authenticatedUsersResult[0]?.count || 0;

    // Nombre de sessions distinctes
    const uniqueVisitors = uniqueSessions;

    // Temps moyen par visite
    const avgDurationResult = await dbManager.query('SELECT AVG(duration) as avg FROM websiteAnalytics') as Array<{ avg: number | null }>;
    const avgDuration = avgDurationResult[0]?.avg ? Math.round(avgDurationResult[0].avg / 1000) : 0;

    // Top 5 pages les plus visitées
    const topPages = await dbManager.query(`
        SELECT page, COUNT(*) as visits 
        FROM websiteAnalytics 
        GROUP BY page 
        ORDER BY visits DESC 
        LIMIT 5
    `) as Array<{ page: string; visits: number }>;

    // Top 5 navigateurs 
    const topBrowsers = await dbManager.query(`
        SELECT browser, COUNT(DISTINCT ip) as count 
        FROM websiteAnalytics 
        GROUP BY browser 
        ORDER BY count DESC 
        LIMIT 5
    `) as Array<{ browser: string; count: number }>;

    // Top 5 referrers externes uniquement (excluant localhost et referrers internes)
    const topReferrers = await dbManager.query(`
        SELECT referrer as count 
        FROM websiteAnalytics 
        WHERE referrer IS NOT NULL 
        AND referrer NOT LIKE 'http://localhost%'
        AND referrer NOT LIKE 'https://localhost%'
        AND referrer NOT LIKE 'http://axiomhub.eu%'
        AND referrer NOT LIKE 'https://axiomhub.eu%'
        AND referrer NOT LIKE 'http://www.axiomhub.eu%'
        AND referrer NOT LIKE 'https://www.axiomhub.eu%'
        GROUP BY referrer 
        ORDER BY count DESC 
        LIMIT 5
    `) as Array<{ referrer: string; count: number }>;

    // Visiteurs anonymes vs authentifiés
    const anonymousIPsResult = await dbManager.query('SELECT COUNT(DISTINCT ip) as count FROM websiteAnalytics WHERE user_id IS NULL') as Array<{ count: number }>;

    return {
        totalVisits: totalVisits,
        uniqueVisitors: uniqueVisitors,
        uniqueSessions: uniqueSessions,
        uniqueIPs: uniqueIPs,
        avgDuration: avgDuration,
        topPages: topPages,
        topBrowsers: topBrowsers,
        topReferrers: topReferrers,
        visitorTypes: {
            anonymous: anonymousIPsResult[0]?.count || 0,
        }
    };
}
