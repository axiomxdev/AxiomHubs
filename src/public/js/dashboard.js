// Fetch dashboard data on page load
async function loadDashboard() {
    const loadingEl = document.getElementById('loading');
    const contentEl = document.getElementById('dashboard-content');
    const errorEl = document.getElementById('error-container');

    try {
        const response = await fetch('/api/dashboard');

        if (!response.ok) {
            throw new Error('Authentication failed');
        }

        const data = await response.json();

        if (data.success) {
            // Update email
            document.getElementById('email').textContent = data.user.email;

            // Update API key
            const apiKeyInput = document.getElementById('api-key');
            console.log('data.user', data.user)
            apiKeyInput.value = data.user.roblox_client.key;

            // Fetch Roblox username if account ID exists
            const robloxUsernameEl = document.getElementById('roblox-username');
            if (data.user.roblox_client.userId) {
                try {
                    const robloxUsername = await fetchRobloxUsername(data.user.roblox_client.userId);
                    robloxUsernameEl.textContent = robloxUsername;
                    robloxUsernameEl.style.color = '#10b981'; // Green color for success
                } catch (error) {
                    console.error('Error fetching Roblox username:', error);
                    robloxUsernameEl.textContent = `ID: ${data.user.roblox_client.userId} (Username fetch failed)`;
                    robloxUsernameEl.style.color = '#f59e0b'; // Orange for warning
                }
            } else {
                robloxUsernameEl.textContent = 'Key never used';
                robloxUsernameEl.style.color = '#6b7280'; // Gray for not used
            }

            // Hide loading, show content
            loadingEl.style.display = 'none';
            contentEl.style.display = 'flex';
        } else {
            throw new Error(data.message || 'Failed to load dashboard');
        }
    } catch (error) {
        console.error('Dashboard error:', error);

        // Show error state
        loadingEl.style.display = 'none';
        errorEl.style.display = 'flex';

        const errorMessage = document.getElementById('error-message');
        errorMessage.textContent = error.message || 'Unable to load dashboard. Please login again.';
    }
}

// Fetch Roblox username via RoProxy (évite CORS)
async function fetchRobloxUsername(userId) {
    try {
        console.log('Fetching Roblox username for user ID:', userId);
        // Utilise RoProxy pour éviter les problèmes CORS
        const response = await fetch(`https://users.roproxy.com/v1/users/${userId}`);

        if (!response.ok) {
            throw new Error('Failed to fetch Roblox user data');
        }

        const data = await response.json();
        return data.name || data.displayName || `User ${userId}`;
    } catch (error) {
        console.error('Roblox API error:', error);
        throw error;
    }
}

// Toggle API key visibility
document.getElementById('toggle-key').addEventListener('click', () => {
    const apiKeyInput = document.getElementById('api-key');
    const eyeIcon = document.querySelector('.eye-icon');

    if (apiKeyInput.type === 'password') {
        apiKeyInput.type = 'text';
        eyeIcon.innerHTML = `
            <path d="M17.94 17.94A10.07 10.07 0 0 1 12 20c-7 0-11-8-11-8a18.45 18.45 0 0 1 5.06-5.94M9.9 4.24A9.12 9.12 0 0 1 12 4c7 0 11 8 11 8a18.5 18.5 0 0 1-2.16 3.19m-6.72-1.07a3 3 0 1 1-4.24-4.24"></path>
            <line x1="1" y1="1" x2="23" y2="23"></line>
        `;
    } else {
        apiKeyInput.type = 'password';
        eyeIcon.innerHTML = `
            <path d="M1 12s4-8 11-8 11 8 11 8-4 8-11 8-11-8-11-8z"></path>
            <circle cx="12" cy="12" r="3"></circle>
        `;
    }
});

// Copy API key to clipboard
document.getElementById('copy-key').addEventListener('click', async () => {
    const apiKeyInput = document.getElementById('api-key');
    const copyBtn = document.getElementById('copy-key');

    try {
        // Copy to clipboard
        await navigator.clipboard.writeText(apiKeyInput.value);

        // Visual feedback
        const originalBg = copyBtn.style.background;
        copyBtn.style.background = '#10b981';
        copyBtn.querySelector('.copy-icon').innerHTML = `
            <polyline points="20 6 9 17 4 12"></polyline>
        `;

        setTimeout(() => {
            copyBtn.style.background = '';
            copyBtn.querySelector('.copy-icon').innerHTML = `
                <rect x="9" y="9" width="13" height="13" rx="2" ry="2"></rect>
                <path d="M5 15H4a2 2 0 0 1-2-2V4a2 2 0 0 1 2-2h9a2 2 0 0 1 2 2v1"></path>
            `;
        }, 2000);
    } catch (error) {
        console.error('Failed to copy:', error);
        alert('Failed to copy API key');
    }
});

// Logout functionality
document.getElementById('logout-btn').addEventListener('click', async () => {
    try {
        fetch('/api/logout', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
            }
        }).then(() => {
            window.location.href = '/login';
        });
    } catch (error) {
        console.error('Logout error:', error);
        alert('Failed to logout. Please try again.');
    }
});

// Load dashboard on page load
loadDashboard();
