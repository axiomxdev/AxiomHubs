import { ImapFlow } from 'imapflow';
import { simpleParser } from 'mailparser';
import {
    imapHost,
    imapPort,
    emailUser,
    emailPass,
    mailWebhookUrl
} from '../server';

let client: ImapFlow | null = null;

export async function startEmailListener() {
    try {
        if (!imapHost || !imapPort || !emailUser || !emailPass) {
            console.warn('⚠️  IMAP credentials not configured, email listener disabled');
            return;
        }

        client = new ImapFlow({
            host: String(imapHost),
            port: Number(imapPort),
            secure: true,
            auth: {
                user: String(emailUser),
                pass: String(emailPass)
            },
            logger: false // Désactiver les logs verbeux
        });

        await client.connect();
        console.log('📧 Email listener connected to IMAP server');

        await client.mailboxOpen('INBOX');

        client.on('exists', async (data) => {
            try {
                // Récupérer le dernier message (le plus récent)
                const message = await client!.fetchOne(String(data.count), {
                    source: true,
                    envelope: true,
                    bodyStructure: true
                });

                if (!message || typeof message === 'boolean') {
                    console.warn('Message introuvable');
                    return;
                }

                // Décoder le contenu du message
                if (message.source && mailWebhookUrl) {
                    const parsed = await simpleParser(message.source);

                    // Créer l'embed Discord
                    const embed = {
                        title: 'Nouveau message reçu',
                        color: 0x667eea, // Couleur violette
                        fields: [
                            {
                                name: 'De',
                                value: message.envelope?.from?.[0]?.address || 'Inconnu',
                                inline: true
                            },
                            {
                                name: 'Date',
                                value: message.envelope?.date ? new Date(message.envelope.date).toLocaleString('fr-FR') : 'Inconnue',
                                inline: true
                            },
                            {
                                name: 'Sujet',
                                value: message.envelope?.subject || 'Sans sujet',
                                inline: false
                            },
                            {
                                name: 'Contenu',
                                value: parsed.text ? (parsed.text.substring(0, 1000) + (parsed.text.length > 1000 ? '...' : '')) : 'Aucun texte',
                                inline: false
                            }
                        ],
                        footer: {
                            text: `Pièces jointes: ${parsed.attachments?.length || 0}`
                        },
                        timestamp: new Date().toISOString()
                    };

                    // Préparer les fichiers attachés (max 25MB pour Discord, max 10 fichiers)
                    const formData = new FormData();

                    // Ajouter l'embed
                    formData.append('payload_json', JSON.stringify({ embeds: [embed] }));

                    // Ajouter les pièces jointes (limiter à 10 fichiers max et 8MB chacun)
                    if (parsed.attachments && parsed.attachments.length > 0) {
                        for (let i = 0; i < Math.min(parsed.attachments.length, 10); i++) {
                            const attachment = parsed.attachments[i];

                            // Limite Discord: 25MB total, on limite chaque fichier à 8MB
                            if (attachment.size && attachment.size > 8 * 1024 * 1024) {
                                console.warn(`⚠️  Fichier ${attachment.filename} trop gros (${(attachment.size / 1024 / 1024).toFixed(2)}MB), ignoré`);
                                continue;
                            }

                            const blob = new Blob([attachment.content], { type: attachment.contentType });
                            formData.append(`files[${i}]`, blob, attachment.filename || `attachment${i}`);
                        }
                    }

                    // Envoyer au webhook Discord avec les fichiers
                    const response = await fetch(mailWebhookUrl, {
                        method: 'POST',
                        body: formData
                    });

                    if (!response.ok) {
                        console.error('❌ Erreur webhook Discord:', response.status, await response.text());
                    }
                } else if (!mailWebhookUrl) {
                    console.warn('⚠️  MAIL_WEBHOOK_URL non configuré');
                }

            } catch (error) {
                console.error('❌ Erreur lors de la récupération du message:', error);
            }
        });

        client.on('error', (err) => {
            console.error('❌ IMAP error:', err);
        });

    } catch (error) {
        console.error('❌ Failed to start email listener:', error);
    }
}

export async function stopEmailListener() {
    if (client) {
        try {
            await client.logout();
            console.log('📧 Email listener disconnected');
        } catch (error) {
            console.error('Error stopping email listener:', error);
        }
        client = null;
    }
}
