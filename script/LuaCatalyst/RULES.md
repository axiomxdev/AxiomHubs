## Règle de factorisation LuaCatalyst

Tout composant ou menu UI récurrent (ex : ImageLabel, Frame, boutons, etc.) doit être factorisé dans une librairie réutilisable (ex : ScreenBuilder).

Les scripts du dossier LuaCatalyst doivent utiliser ces librairies pour éviter la répétition de code et faciliter la maintenance.

Exemple d'utilisation :

```lua
-- Import de la librairie via loadingstring
_G.ScreenBuilder = loadingstring([=[ ...contenu de la lib... ]=])()

-- Utilisation
local menu = _G.ScreenBuilder.CreateImageLabelMenu({
    Parent = game.Players.LocalPlayer.PlayerGui,
    Image = "rbxassetid://123456",
    Size = UDim2.new(0, 200, 0, 200),
    Position = UDim2.new(0.5, -100, 0.5, -100)
})
```

La librairie doit obligatoirement faire un `return` de la table contenant les fonctions utilitaires.
