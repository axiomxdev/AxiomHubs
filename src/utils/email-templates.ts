import fs from 'fs';
import path from 'path';


export function loadEmailTemplate(templateName: string, replacements: Record<string, string>): { html: string; text: string } {
    // Load templates
    const htmlPath = path.join(__dirname, '../mails', `${templateName}.html`);
    const textPath = path.join(__dirname, '../mails', `${templateName}.txt`);

    let html = fs.readFileSync(htmlPath, 'utf-8');
    let text = fs.readFileSync(textPath, 'utf-8');

    // Add default replacements
    const allReplacements = {
        YEAR: new Date().getFullYear().toString(),
        ...replacements,
    };

    // Replace placeholders
    for (const [key, value] of Object.entries(allReplacements)) {
        const placeholder = `{{${key}}}`;
        html = html.replace(new RegExp(placeholder, 'g'), value);
        text = text.replace(new RegExp(placeholder, 'g'), value);
    }

    return { html, text };
}
