-- Configuration
local spawnPosition = Vector3.new(-4013, 23629, 1348) -- Position de spawn de la sphère
local diameter = 1000 -- Diamètre de la sphère
local radius = diameter / 2
local wallThickness = 5 -- Épaisseur des murs

-- Paramètres de génération
-- Plus l'angle est petit, plus la sphère est lisse mais plus il y a de parts (attention au lag)
local stepAngle = 2 -- Degrés

local folder = Instance.new("Folder")
folder.Name = "HollowSphere_Client"
folder.Parent = workspace

print("Génération de la sphère en parts (Client Side)...")

local function createPart(cframe, size)
    local p = Instance.new("Part")
    p.Anchored = true
    p.Size = size
    p.CFrame = cframe
    p.Material = Enum.Material.SmoothPlastic
    p.BrickColor = BrickColor.new("Institutional white")
    p.TopSurface = Enum.SurfaceType.Smooth
    p.BottomSurface = Enum.SurfaceType.Smooth
    p.Parent = folder
end

-- Calcul de la hauteur d'un segment d'arc (distance entre deux anneaux)
local arcLength = (math.pi * diameter) / (360 / stepAngle)

-- Boucle de latitude (de bas en haut)
for theta = -90 + stepAngle, 90 - stepAngle, stepAngle do
    local radTheta = math.rad(theta)
    
    -- Rayon de l'anneau à cette latitude
    local r_ring = radius * math.cos(radTheta)
    local y = radius * math.sin(radTheta)
    
    -- Circonférence de l'anneau à cette latitudeq
    local circumference = 2 * math.pi * r_ring
    
    -- Nombre de segments pour cet anneau
    -- On essaie de garder des parts carrées (largeur ~ hauteur de l'arc)
    local numSegments = math.floor(circumference / arcLength)
    if numSegments < 3 then numSegments = 3 end -- Minimum 3 segments pour un anneau
    
    local segmentAngle = 360 / numSegments
    
    for i = 1, numSegments do
        local phi = (i - 1) * segmentAngle
        local radPhi = math.rad(phi)
        
        local x = r_ring * math.cos(radPhi)
        local z = r_ring * math.sin(radPhi)
        
        local pos = spawnPosition + Vector3.new(x, y, z)
        
        -- Orientation : Regarde vers le centre
        -- CFrame.new(pos, lookAt) oriente le vecteur -Z vers lookAt.
        -- Donc l'axe Z traverse l'épaisseur du mur.
        local cf = CFrame.new(pos, spawnPosition)
        
        local width = (circumference / numSegments) * 1.05
        local height = arcLength * 1.05
        
        createPart(cf, Vector3.new(width, height, wallThickness))
    end
    
    if theta % (stepAngle * 5) == 0 then
        task.wait()
    end
end

-- Création des pôles (haut et bas) pour fermer la sphère
local function createCap(isTop)
    local y = isTop and radius or -radius
    local pos = spawnPosition + Vector3.new(0, y, 0)
    local cf = CFrame.new(pos, spawnPosition)
    -- Un disque ou un carré plat pour fermer
    -- La taille doit couvrir le dernier anneau
    -- Rayon du dernier anneau (à 90 - stepAngle)
    local lastRingRadius = radius * math.cos(math.rad(90 - stepAngle))
    local capSize = (lastRingRadius * 2) * 1.1
    
    createPart(cf, Vector3.new(capSize, capSize, wallThickness))
end

createCap(true)
createCap(false)

print("Sphère générée !")
