// Script pour le formulaire reset-password
document.getElementById('reset-password-form').addEventListener('submit', async (e) => {
    e.preventDefault();

    const urlParams = new URLSearchParams(window.location.search);
    const token = urlParams.get('token');
    const password = document.getElementById('password').value;
    const confirmPassword = document.getElementById('confirm-password').value;
    const successMessage = document.getElementById('success-message');
    const errorMessage = document.getElementById('error-message');
    const submitButton = e.target.querySelector('button[type="submit"]');

    // Hide messages
    successMessage.classList.remove('show');
    errorMessage.classList.remove('show');

    // Validate passwords match
    if (password !== confirmPassword) {
        errorMessage.textContent = '✗ Passwords do not match.';
        errorMessage.classList.add('show');
        return;
    }

    // Disable button
    submitButton.disabled = true;
    submitButton.textContent = 'Resetting...';

    try {
        const response = await fetch('/api/reset-password', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
            },
            body: JSON.stringify({ token, password }),
        });

        const data = await response.json();

        if (!response.ok) {
            throw new Error(data.message || 'Network response was not ok');
        }

        // Show success message
        successMessage.classList.add('show');

        // Redirect to login after 2 seconds
        setTimeout(() => {
            window.location.href = '/login';
        }, 2000);

    } catch (error) {
        console.error('Error:', error);
        errorMessage.textContent = `✗ ${error.message}`;
        errorMessage.classList.add('show');

        // Re-enable button
        submitButton.disabled = false;
        submitButton.textContent = 'Reset Password';
    }
});
