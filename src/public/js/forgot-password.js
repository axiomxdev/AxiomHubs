// Script de base pour le formulaire forgot-password
document.getElementById('forgot-password-form').addEventListener('submit', async (e) => {
    e.preventDefault();

    const email = document.getElementById('email').value;
    const successMessage = document.getElementById('success-message');
    const errorMessage = document.getElementById('error-message');
    const submitButton = e.target.querySelector('button[type="submit"]');

    // Hide messages
    successMessage.classList.remove('show');
    errorMessage.classList.remove('show');

    // Disable button
    submitButton.disabled = true;
    submitButton.textContent = 'Sending...';

    try {
        const response = await fetch('/api/forgot-password', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
            },
            body: JSON.stringify({ email }),
        });

        if (!response.ok) {
            throw new Error('Network response was not ok');
        }

        successMessage.classList.add('show');

        e.target.reset();

    } catch (error) {
        console.error('Error:', error);
        errorMessage.classList.add('show');
    } finally {
        // Re-enable button
        submitButton.disabled = false;
        submitButton.textContent = 'Send Reset Link';
    }
});
