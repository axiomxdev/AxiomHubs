#!/bin/bash

CONTAINER_ID=$(docker ps --filter "name=axiomhub" --format "{{.ID}}" | head -n 1)

if [ -z "$CONTAINER_ID" ]; then
    echo "❌ Aucun container axiomhub trouvé"
    exit 1
fi

echo "📋 Logs du container axiomhub ($CONTAINER_ID):"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# Afficher les logs (avec -f pour follow en temps réel, enlever -f pour voir juste les logs existants)
docker logs -f "$CONTAINER_ID"
