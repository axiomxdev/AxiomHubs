# 🎮 Loomian Legacy Script - Features Documentation

> Compilation complète de toutes les features des scripts Loomian Legacy (loomian_2.lua & loomian legacy.lua)

---

## 📋 Table des matières

1. [Features de Gameplay](#features-de-gameplay)
2. [Farming & Auto Features](#farming--auto-features)
3. [Capture & Hunting](#capture--hunting)
4. [Événements Spéciaux](#événements-spéciaux)
5. [UI & Personnalisation](#ui--personnalisation)
6. [Utilitaires](#utilitaires)

---

## 🎮 Features de Gameplay

### 1. **Auto Heal** ✅

- **Description**: Guérison automatique des Loomians en extérieur et au centre
- **Activation**: Toggle "Auto Heal [Outdoor Only]"
- **Mécanisme**:
  - Détecte si la santé n'est pas complète
  - Utilise les guérisseurs disponibles (`HealMachine1`)
  - Alternative: Téléportation au centre Pokémon via mécanisme de blackout
- **Bénéfice**: Pas besoin de revenir à la main au centre

### 2. **Infinite Repel** ♾️

- **Description**: Répulsif infini pour éviter les combats indésirables
- **Activation**: Toggle "Active Repellent"
- **Mécanisme**: Maintient les étapes de répulsif à 100
- **Réinitialisation**: Remet à 0 quand désactivé

### 3. **Skip Dialogue** ⏭️

- **Description**: Passe automatiquement tous les dialogues
- **Activation**: Toggle "Skip Dialogue"
- **Filtre**: Préserve les dialogues critiques avec marqueurs `[NoSkip]` ou `[y/n]`

### 4. **Fast Battle** ⚡

- **Description**: Accélère les combats en désactivant les animations
- **Activation**: Toggle "Fast Battle"
- **Optimisations**:
  - Désactive `animFaint`, `animSummon`, `animUnsummon`, etc.
  - Met `fastForward = true` pendant les combats
  - Masque les barres de santé animées

### 5. **Walk Speed** 🏃

- **Description**: Modifie la vitesse de marche du personnage
- **Activation**: Slider "WalkSpeed" (0-250, par défaut 16)
- **Contrôle**: Ajustement en temps réel de `Humanoid.WalkSpeed`

---

## 🌾 Farming & Auto Features

### 6. **Auto Hunt / Auto Encounter** 🎯

- **Description**: Rencontre automatique de Pokémon sauvages
- **Activation**: Toggle "Auto Encounter"
- **Condition**: Marche activée + Menu activé + Pas de combat
- **Mécanisme**:
  - Déclenche `doWildBattle()` sur la zone de prairie (`regionData.Grass`)
  - Répétition toutes les 0.1 secondes

### 7. **Auto Fish** 🎣

- **Description**: Pêche automatique avec capture automatique
- **Activation**: Toggle "Auto Fish"
- **Options**:
  - "Items Only" - Capture uniquement les items, pas les Pokémon
  - Pêche répétée avec détection de zones d'eau
- **Mécanisme**:
  - Détecte les zones de pêche (`regionData.Fishing`)
  - Utilise raycast pour position optimale
  - Appelle `doWildBattle()` ou `reelIn()` selon le type

### 8. **Auto Battle** ⚔️

- **Description**: Combat automatique contre les entraîneurs
- **Activation**: Toggle "Auto Battle (Trainer - Move 1)"
- **Mécanisme**:
  - Appelle `mainButtonClicked(1)` (Fight)
  - Utilise `onMoveClicked(1)` (premier mouvement)
  - Répétition automatique

### 9. **Auto Buy Disc** 🛒

- **Description**: Achat automatique de disques en boutique
- **Activation**: Toggle "Auto Buy Disc (< 10)"
- **Logique**:
  - Vérifie le nombre de disques actuels
  - Achète automatiquement si moins de 10
  - Discs disponibles: Normal, Advanced, Hyper, Ace

---

## 🎯 Capture & Hunting

### 10. **Auto Hunt Settings** 🎪

- **Destination Disc**: Choisir le type de disque (Normal/Advanced/Hyper/Ace)
- **Capture Modes**:
  - **Gleam**: Capture les Pokémon avec effet brillant
  - **Gamma**: Capture les variantes Gamma
  - **Not Owned**: Capture les Pokémon non possédés
  - **Spare**: Utilise le mouvement "Spare" si HP < 20%

### 11. **Custom Loomian List** 📝

- **Description**: Capture uniquement les Pokémon d'une liste personnalisée
- **Activation**: Section "Catch Listed Loomians"
- **Fonctionnement**:
  - Ajouter des noms de Pokémon via textbox
  - Remvoer de la liste via dropdown
  - Stockage en minuscule pour compatibilité

### 12. **Defeat Corrupt** 👹

- **Description**: Combat spécial contre les Pokémon corrompus
- **Options**:
  - Disabled (par défaut)
  - Move 1, 2, 3, 4 (choisir le mouvement à utiliser)
- **Condition**: Déclenche automatiquement si le Pokémon est corrompu

### 13. **Battle Mode Selection** 🔄

- **Options**:
  - Disabled
  - Run (fuite automatique)
  - Move 1, 2, 3, 4 (attaques spécifiques)
- **Usage**: Combats sauvages avec options de fuite/attaque

### 14. **Auto Rally** 🏆

- **Description**: Gestion automatique du système Rally
- **Activation**: Toggle "Enabled" dans la page "Auto Rally"
- **Filtres de Conservation**:
  - **Keep All**: Garder tous les Pokémon
  - **Keep Gleaming**: Garder les Pokémon brillants
  - **Keep Hidden Ability**: Garder les Pokémon avec capacité cachée
  - **x40 Threshold**: 3x40, 4x40, 5x40, 6x40, 7x40 Only

---

## 🎪 Événements Spéciaux

### 15. **Uhnne Fair Event Features** 🎡

#### 15a. **Disable Traps** 🚫

- Désactive les pièges du labyrinthe
- Permet de traverser librement
- S'applique à: `Model.CanTouch` et `Trigger.CanTouch`

#### 15b. **Brightness Control** 💡

- Slider pour ajuster la luminosité du jeu
- Plage: 0-50
- Affecte `game.Lighting.Brightness`

#### 15c. **Camera Fix** 📷

- Bouton pour réinitialiser la caméra
- Change le mode caméra à "Classic"

#### 15d. **ESP System** 👁️

Affichage des éléments sur carte:

- **Nevermare ESP**: Affiche le boss Nevermare (rouge)
- **Key ESP**: Affiche les clés (cyan)
- **Potion ESP**: Affiche les potions (violet)
- **Candy ESP**: Affiche les bonbons (orange)
- **Safe House ESP**: Affiche les refuges (vert)

**Visuels**: BillboardGui avec texte coloré et toujours visible

### 16. **Auto Disc Drop** 💿

- **Description**: Drop automatique de disques en arcade
- **Activation**: Toggle "Enabled" dans section "Auto Disc Drop"
- **Mode Rapide**: Toggle "Fast Mode" pour vitesse accélérée
- **Source**: Script externe chargé depuis GitHub

---

## 🎨 UI & Personnalisation

### 17. **GUI Theme** 🎭

- **Couleurs personnalisables**:
  - **Background**: Couleur du fond
  - **Glow**: Couleur de surbrillance
  - **Accent**: Couleur d'accent
  - **LightContrast**: Contraste léger
  - **DarkContrast**: Contraste sombre
  - **TextColor**: Couleur du texte

- **Fonctionnalités**:
  - Color Picker pour chaque élément
  - Bouton "Reset Theme" pour revenir au défaut
  - Sauvegarde des préférences

### 18. **Built In Features** ⚙️

- **Skip Battle Theater Puzzles**: Passe les énigmes du théâtre de bataille
- **No Unstuck CoolDown**: Enlève le délai d'attente du command "unstuck"
- **Skip Fish MiniGame**: Passe le mini-jeu de pêche
- **Infinite UMV Energy**: Énergie infinie pour UMV

### 19. **Misc Settings** 📋

- **Deny Reassign Move**: Refuse automatiquement de réassigner les mouvements
- **Deny Switch Request**: Refuse les demandes d'échange
- **Deny Nickname Request**: Refuse les demandes de surnom
- **Disable Show Progress**: Masque les notifications de progression en Mastery

---

## 🛠️ Utilitaires

### 20. **Server Hop** 🌐

- **Description**: Change de serveur automatiquement
- **Bouton**: "Switch Server" dans section Teleport
- **Source**: Script externe GitHub

### 21. **Find Most Empty Server** 👥

- **Description**: Trouve le serveur le moins peuplé
- **Bouton**: "Find Most Empty Server" dans section Teleport
- **Utilité**: Réduire la concurrence farming

### 22. **Rejoin** 🔄

- **Description**: Redémarrer le jeu sur le même serveur/job
- **Bouton**: "Rejoin" dans section Teleport
- **Usage**: Reset rapide du personnage

### 23. **Copy Discord Invite** 💬

- **Description**: Copie l'invitation Discord dans le presse-papiers
- **Bouton**: "Copy Discord Invite"
- **Variable**: `DiscordInvite`

### 24. **Hide/Show GUI** 🎮

- **Keybind**: Alt droit (`Enum.KeyCode.RightAlt`)
- **Fonction**: Toggle de visibilité de l'interface

---

## 📊 Résumé Statistics

| Catégorie | Nombre |
|-----------|--------|
| Gameplay | 5 |
| Farming | 4 |
| Capture | 5 |
| Événements | 2 |
| UI | 3 |
| Utilitaires | 5 |
| **TOTAL** | **24 Features** |

---

## 🔧 Variables de Configuration Principales

```lua
AxiomSettings = {
    -- Gameplay
    AutoHeal = false,
    InfiniteRepel = false,
    SkipDialogue = false,
    FastBattle = false,
    
    -- Farming
    AutoFish = false,
    AutoFishOnlyItems = false,
    AutoHunt = false,
    AutoBattle = false,
    
    -- Capture
    Capture = {
        Enabled = false,
        Disc = "Normal Disc",
        Gleam = false,
        Gamma = false,
        NotOwned = false,
        Spare = false,
        CustomList = {}
    },
    
    -- Misc
    Misc = {
        NoNewMoves = false,
        NoSwitch = false,
        NoNick = false,
        NoProgress = false
    },
    
    -- Achat
    AutoBuyDisc = false,
    SelectedDisc = "Normal Disc"
}
```

---

## 📝 Notes d'Utilisation

1. **Sécurité**: Utilise `setthreadcontext(2)` pour les appels sensibles
2. **Performance**: Boucles avec `task.wait()` pour ne pas lag
3. **Hooks**: Redéfinit les méthodes game pour intercepter les actions
4. **Sauvegarde**: Les paramètres sont stockés dans `getgenv().AxiomSettings`
5. **Compatibilité**: Nécessite un executor supportant `getgc()` ou `debug.getregistry()`

---

## 🎯 Cas d'Usage Courants

### Farming de Pokémon Spécifiques

1. Activez "Auto Hunt"
2. Ajoutez les noms à "Catch Listed Loomians"
3. Configurez le disque préféré
4. Laissez tourner!

### Leveling Rapide

1. Activez "Auto Battle"
2. Choisissez les entraîneurs
3. Activez "Fast Battle" pour plus de vitesse

### Pêche Automatique

1. Activez "Auto Fish"
2. Optionnel: "Items Only" pour juste les drops
3. Laissez le script pêcher

### Event Farming (Uhnne Fair)

1. Activez "Disable Traps"
2. Activez les ESP désirés
3. Utilisez la luminosité adaptée

---

**Dernière mise à jour**: 7 Janvier 2026  
**Script Version**: Loomian_2.lua + Loomian Legacy.lua  
**Statut**: ✅ Fully Functional
