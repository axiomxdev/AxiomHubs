import games from '/js/game.json' with { type: 'json' };

async function generateGameSections() {
    console.log("generateGameSections function called");

    // Create DOM elements first while fetching thumbnails
    const gamesSection = document.createElement('div');
    gamesSection.className = 'games-section';
    gamesSection.id = 'games';

    const gamesGrid = document.createElement('div');
    gamesGrid.className = 'games-grid';

    // Create all game cards with placeholder images immediately
    const gameCards = games.map(game => {
        const card = document.createElement('div');
        card.className = 'card';

        const img = document.createElement('img');
        img.src = `https://via.placeholder.com/420x236/1a1a2e/ffffff?text=${encodeURIComponent(game.name)}`;
        img.alt = game.name;
        img.setAttribute('onerror', `onImageError(this, '${game.name}')`);

        const cardContent = document.createElement('div');
        cardContent.className = 'card-content';

        const h3 = document.createElement('h3');
        h3.textContent = game.name;

        const ul = document.createElement('ul');
        game.features.forEach(feature => {
            const li = document.createElement('li');
            li.textContent = feature;
            ul.appendChild(li);
        });

        const playBtn = document.createElement('a');
        playBtn.href = `https://www.roblox.com/games/${game.placeId}`;
        playBtn.target = '_blank';
        playBtn.className = 'play-btn';
        playBtn.textContent = 'Play now';

        cardContent.appendChild(h3);
        cardContent.appendChild(ul);
        cardContent.appendChild(playBtn);

        card.appendChild(img);
        card.appendChild(cardContent);
        gamesGrid.appendChild(card);

        return { card, img, game };
    });

    gamesSection.appendChild(gamesGrid);

    // Insert into DOM immediately
    const gameposition = document.querySelector("body > main > div > div.features-section > h2");
    gameposition.parentNode.insertBefore(gamesSection, gameposition);

    // Fetch thumbnails in batches of 5 to avoid rate limiting
    const batchSize = 5;
    for (let i = 0; i < gameCards.length; i += batchSize) {
        const batch = gameCards.slice(i, i + batchSize);

        const thumbnailPromises = batch.map(async ({ img, game }) => {
            try {
                const response = await fetch(`https://thumbnails.roproxy.com/v1/places/gameicons?placeIds=${game.placeId}&returnPolicy=PlaceHolder&size=512x512&format=Png&isCircular=false`);
                const data = await response.json();
                if (data.data?.[0]?.imageUrl) {
                    img.src = data.data[0].imageUrl;
                }
            } catch (error) {
                console.error(`Error fetching thumbnail for ${game.name}:`, error);
            }
        });

        await Promise.all(thumbnailPromises);

        // Small delay between batches to be respectful to the API
        if (i + batchSize < gameCards.length) {
            await new Promise(resolve => setTimeout(resolve, 100));
        }
    }
}

document.addEventListener('DOMContentLoaded', () => {
    console.log("Script.js loaded successfully");
    generateGameSections();

    // Script loader copy functionality
    const copyButton = document.getElementById('copy-script');
    const scriptInput = document.getElementById('script-code');

    if (copyButton && scriptInput) {
        copyButton.addEventListener('click', () => {
            const scriptText = scriptInput.value;
            navigator.clipboard.writeText(scriptText).then(() => {
                // Change icon to checkmark
                const copyIcon = copyButton.querySelector('.copy-icon');
                const originalIcon = copyIcon.innerHTML;
                copyIcon.innerHTML = `
                    <path d="M20 6L9 17l-5-5"></path>
                `;
                copyButton.style.color = '#10b981';

                setTimeout(() => {
                    copyIcon.innerHTML = originalIcon;
                    copyButton.style.color = '';
                }, 2000);
            }).catch(err => {
                console.error('Erreur lors de la copie:', err);
            });
        });
    }
});

function onImageError(img, gameName) {
    img.src = `https://via.placeholder.com/420x236/1a1a2e/ffffff?text=${encodeURIComponent(gameName)}`;
}