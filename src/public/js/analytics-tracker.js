// Tracking du temps passé sur la page
(function () {
    const startTime = Date.now();
    const currentPage = window.location.pathname + window.location.search;
    let durationSent = false;

    // Fonction pour obtenir un cookie
    function getCookie(name) {
        const value = `; ${document.cookie}`;
        const parts = value.split(`; ${name}=`);
        if (parts.length === 2) return parts.pop().split(';').shift();
        return null;
    }

    // Fonction pour obtenir le sessionId (avec retry)
    function getSessionId() {
        // Essayer d'abord sessionID_client (accessible JS), sinon sessionID
        const sid = getCookie('sessionID_client') || getCookie('sessionID');
        console.log('[Analytics] Current cookies:', document.cookie);
        console.log('[Analytics] SessionID found:', sid);
        return sid;
    }

    const sessionId = getSessionId();
    console.log('[Analytics] Tracker initialized:', { sessionId, currentPage, startTime });

    // Fonction pour envoyer la durée
    function sendDuration() {
        if (durationSent) {
            console.log('[Analytics] Duration already sent, skipping');
            return;
        }

        const duration = Date.now() - startTime;
        const currentSessionId = getSessionId(); // Toujours récupérer le cookie frais

        console.log('[Analytics] Attempting to send duration:', {
            sessionId: currentSessionId,
            currentPage,
            duration,
            durationSec: (duration / 1000).toFixed(2) + 's'
        });

        if (!currentSessionId) {
            console.error('[Analytics] No sessionId found after retry, cannot send analytics');
            console.log('[Analytics] All cookies:', document.cookie);
            return;
        }

        durationSent = true;

        // Utiliser sendBeacon (synchrone et fiable pour beforeunload)
        if (navigator.sendBeacon) {
            const data = JSON.stringify({
                sessionId: currentSessionId,
                page: currentPage,
                duration: duration
            });

            const success = navigator.sendBeacon('/api/analytics/duration', new Blob([data], {
                type: 'application/json'
            }));
            console.log('[Analytics] Beacon sent:', success, 'with data:', { sessionId: currentSessionId, page: currentPage, duration });
            return;
        }

        // Fallback avec XMLHttpRequest synchrone (bloque le thread)
        try {
            const xhr = new XMLHttpRequest();
            xhr.open('POST', '/api/analytics/duration', false); // false = synchrone
            xhr.setRequestHeader('Content-Type', 'application/json');
            xhr.send(JSON.stringify({
                sessionId: currentSessionId,
                page: currentPage,
                duration: duration
            }));
            console.log('[Analytics] XHR sync sent:', xhr.status);
        } catch (e) {
            console.error('[Analytics] XHR error:', e);
        }
    }

    // Envoyer la durée quand l'utilisateur quitte la page
    window.addEventListener('beforeunload', sendDuration);
    window.addEventListener('unload', sendDuration); // Backup
    console.log('[Analytics] beforeunload/unload listeners added');

    // Envoyer aussi quand la page devient invisible (changement d'onglet, etc.)
    document.addEventListener('visibilitychange', function () {
        if (document.hidden) {
            console.log('[Analytics] Page hidden, sending duration');
            sendDuration();
        }
    });

    // Envoyer périodiquement pour les sessions longues (toutes les 30 secondes)
    setInterval(() => {
        if (!durationSent) {
            sendDuration();
            durationSent = false; // Permettre d'envoyer à nouveau
        }
    }, 30 * 1000);
    console.log('[Analytics] Periodic sender initialized (30s)');
})();
