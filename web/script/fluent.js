// Copyright © 2025-2026 Ideas Networks Solutions S.A.,
//                       <https://github.com/tapopa>
//
// This program is free software: you can redistribute it and/or modify it under
// the terms of the GNU Affero General Public License v3.0 as published by the
// Free Software Foundation, either version 3 of the License, or (at your
// option) any later version.
//
// This program is distributed in the hope that it will be useful, but WITHOUT
// ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
// FOR A PARTICULAR PURPOSE. See the GNU Affero General Public License v3.0 for
// more details.
//
// You should have received a copy of the GNU Affero General Public License v3.0
// along with this program. If not, see
// <https://www.gnu.org/licenses/agpl-3.0.html>.

async function loadFTL(url) {
    const text = await fetch(url).then(r => r.text());
    return parseFTL(text);
}

function parseFTL(source) {
    const lines = source.split('\n');
    const messages = {};

    let currentKey = null;
    let buffer = [];

    for (const line of lines) {
        if (!line.trim()) continue;

        // New key
        if (!line.startsWith(' ') && line.includes('=')) {
            if (currentKey) {
                messages[currentKey] = buffer.join('<br><br>').trim();
                buffer = [];
            }

            const [key, value] = line.split('=');
            currentKey = key.trim();
            if (value.trim() != "") {
                buffer.push(value.replace(/^\s+/, '').replace('{" "}', ' '));
            }
            continue;
        }

        // Continuation line
        if (currentKey) {
            buffer.push(line.replace(/^\s+/, '').replace('{" "}', ' '));
        }
    }

    if (currentKey) {
        messages[currentKey] = buffer.join('<br><br>').trim();
    }

    return messages;
}

function getBestLocale(supportedLocales, defaultLocale = 'en-US') {
    const userLocales = navigator.languages || [navigator.language || navigator.userLanguage];

    for (const userLocale of userLocales) {
        const canonicalUserLocale = new Intl.Locale(userLocale).toString();

        if (supportedLocales.includes(canonicalUserLocale)) {
            return canonicalUserLocale;
        }

        const languageOnly = canonicalUserLocale.split('-')[0];
        const match = supportedLocales.find(loc => loc.split('-')[0] === languageOnly);
        if (match) return match;
    }

    return defaultLocale;
}

async function localizePage({
    locales,
    fallback = 'en-US',
    path = '/assets/assets/l10n'
}) {
    const locale = getBestLocale(locales) || fallback;
    console.log(`Best locale is ${locale}`);

    let messages;
    try {
        messages = await loadFTL(`${path}/${locale}.ftl`);
    } catch {
        console.warn(`Failed to load ${locale}, falling back to ${fallback}`);
        messages = await loadFTL(`${path}/${fallback}.ftl`);
    }

    document.querySelectorAll('[l10n]').forEach(el => {
        const key = el.getAttribute('l10n');
        if (messages[key]) {
            el.innerHTML = messages[key];
        } else {
            console.warn(`Missing l10n key: ${key}`);
        }
    });
}
