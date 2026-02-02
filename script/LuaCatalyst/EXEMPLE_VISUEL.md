# Exemple Visuel de la Coloration Syntaxique

## Résultat de l'implémentation

La coloration syntaxique est maintenant fonctionnelle dans le `CodeEditor`. Voici des exemples de ce que vous verrez :

## Exemple 1 : Code Lua

### Code source :
```lua
-- Ceci est un commentaire
local function greet(name)
    if name then
        print("Hello, " .. name)
        return true
    else
        return false
    end
end

local x = 42
local y = "test string"
greet(y)

for i = 1, 10 do
    print(i)
end
```

### Rendu avec coloration syntaxique :

Dans l'éditeur Roblox, ce code apparaîtra avec les couleurs suivantes :

- **`-- Ceci est un commentaire`** → <span style="color: rgb(106, 153, 85)">Vert (commentaire)</span>
- **`local`**, **`function`**, **`if`**, **`then`**, **`else`**, **`end`**, **`return`**, **`for`**, **`do`** → <span style="color: rgb(86, 156, 214)">Bleu (mots-clés)</span>
- **`print`**, **`greet`** → <span style="color: rgb(78, 201, 176)">Cyan (fonctions natives)</span> / Blanc (fonctions utilisateur)
- **`"Hello, "`**, **`"test string"`** → <span style="color: rgb(206, 145, 120)">Orange/Saumon (chaînes)</span>
- **`42`**, **`1`**, **`10`** → <span style="color: rgb(181, 206, 168)">Vert clair (nombres)</span>
- **`name`**, **`x`**, **`y`**, **`i`** → <span style="color: rgb(220, 220, 220)">Blanc cassé (identifiants)</span>
- **`(`**, **`)`**, **`{`**, **`}`**, **`..`**, **`=`** → <span style="color: rgb(212, 212, 212)">Gris clair (opérateurs)</span>

## Exemple 2 : Code JSON

### Code source :
```json
{
    "name": "test",
    "value": 123,
    "active": true,
    "data": null,
    "items": [1, 2, 3]
}
```

### Rendu avec coloration syntaxique :

- **`"name"`**, **`"test"`**, **`"value"`**, **`"active"`**, **`"data"`**, **`"items"`** → <span style="color: rgb(206, 145, 120)">Orange/Saumon (chaînes)</span>
- **`true`**, **`null`** → <span style="color: rgb(86, 156, 214)">Bleu (mots-clés)</span>
- **`123`**, **`1`**, **`2`**, **`3`** → <span style="color: rgb(181, 206, 168)">Vert clair (nombres)</span>
- **`{`**, **`}`**, **`[`**, **`]`**, **`:`**, **`,`** → <span style="color: rgb(212, 212, 212)">Gris clair (opérateurs)</span>

## Comment tester le résultat

### Option 1 : Utiliser le script de test

Exécutez le script de test fourni dans Roblox :

```lua
-- Chargez d'abord la librairie ScreenBuilder
local ScreenBuilder = loadstring(readfile("script/LuaCatalyst/libs/ScreenBuilder.lua"))()

-- Créez un éditeur avec du code
local editorFrame, textBox = ScreenBuilder.CodeEditor.Create({
    Parent = game:GetService("CoreGui"):WaitForChild("ScreenGUI") or Instance.new("ScreenGui", game:GetService("CoreGui")),
    Size = UDim2.new(0, 600, 0, 400),
    Position = UDim2.new(0.5, -300, 0.5, -200),
    BackgroundColor3 = Color3.fromRGB(30, 30, 30),
    Text = [[
-- Exemple de code Lua
local x = 42
print("Hello World")
    ]]
})
```

### Option 2 : Utilisation directe

```lua
local ScreenBuilder = loadstring(readfile("script/LuaCatalyst/libs/ScreenBuilder.lua"))()

-- Créer l'éditeur
local editorFrame, textBox = ScreenBuilder.CodeEditor.Create({
    Parent = votreGUI,
    Size = UDim2.new(0, 800, 0, 600),
    BackgroundColor3 = Color3.fromRGB(30, 30, 30),
    Text = "local test = 'Hello'"
})

-- La coloration s'applique automatiquement !
-- Vous pouvez aussi la forcer manuellement :
textBox:Highlight("lua")   -- Pour Lua
textBox:Highlight("json")  -- Pour JSON
```

## Architecture technique

L'éditeur utilise deux couches :
1. **TextBox transparent** (ZIndex 2) - Capture la saisie de l'utilisateur
2. **TextLabel avec RichText** (ZIndex 1) - Affiche le texte coloré

Quand vous tapez du texte :
1. Le TextBox capture votre saisie
2. Le texte est analysé et coloré
3. Le résultat coloré s'affiche via le TextLabel
4. Vous voyez le texte coloré en temps réel pendant que vous tapez !

## Schéma de couleurs utilisé

| Type de token | Couleur RGB | Utilisation |
|---------------|-------------|-------------|
| Mots-clés (keywords) | RGB(86, 156, 214) | `local`, `function`, `if`, `true`, etc. |
| Chaînes (strings) | RGB(206, 145, 120) | `"texte"`, `'texte'` |
| Nombres (numbers) | RGB(181, 206, 168) | `42`, `3.14`, `-10` |
| Commentaires (comments) | RGB(106, 153, 85) | `-- commentaire` |
| Opérateurs | RGB(212, 212, 212) | `+`, `-`, `=`, `{`, `}`, etc. |
| Fonctions natives (builtins) | RGB(78, 201, 176) | `print`, `pairs`, `ipairs`, etc. |
| Texte par défaut | RGB(220, 220, 220) | Variables, fonctions utilisateur |

## Fonctionnalités

✅ Coloration syntaxique Lua complète
✅ Coloration syntaxique JSON
✅ Mise à jour en temps réel pendant la saisie
✅ Méthode manuelle `textBox:Highlight(language)`
✅ Support des commentaires, chaînes, nombres, mots-clés
✅ Échappement XML pour éviter les problèmes de rendu
✅ Détection des limites de mots pour les mots-clés JSON

## Résultat final

Vous obtenez un éditeur de code professionnel avec coloration syntaxique en temps réel, similaire à VS Code, directement dans votre interface Roblox !
