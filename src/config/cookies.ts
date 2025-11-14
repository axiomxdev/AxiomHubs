// Cookie configuration based on environment
const isProduction = process.env.NODE_ENV === 'production';

export const cookieConfig = {
    httpOnly: true,
    secure: isProduction, // Only use secure in production (HTTPS)
    sameSite: 'lax' as const, // 'lax' allows cookies on top-level navigation (OAuth redirects)
    path: '/',
};