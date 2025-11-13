// Cookie configuration based on environment
const isProduction = process.env.NODE_ENV === 'production';

export const cookieConfig = {
    httpOnly: true,
    secure: isProduction, // Only use secure in production (HTTPS)
    sameSite: isProduction ? ('strict' as const) : ('lax' as const), // Less strict in development
    path: '/',
};