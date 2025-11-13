// Admin Dashboard JavaScript

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

