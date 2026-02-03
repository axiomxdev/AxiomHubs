-- Librairie ScreenBuilderIDE : Extension de ScreenBuilder pour les fonctionnalités d'IDE (Éditeur de code, etc.)
local ScreenBuilderIDE = {}

local SyntaxColors = {
	keyword = Color3.fromRGB(86, 156, 214),      -- Bleu pour les mots-clés
	string = Color3.fromRGB(206, 145, 120),      -- Orange/saumon pour les chaînes
	number = Color3.fromRGB(181, 206, 168),      -- Vert clair pour les nombres
	comment = Color3.fromRGB(106, 153, 85),      -- Vert pour les commentaires
	operator = Color3.fromRGB(212, 212, 212),    -- Gris clair pour les opérateurs
	builtin = Color3.fromRGB(78, 201, 176),      -- Cyan pour les fonctions natives
	default = Color3.fromRGB(220, 220, 220)      -- Blanc cassé par défaut
}

local luaKeywords = {
	["and"] = true, ["break"] = true, ["do"] = true, ["else"] = true,
	["elseif"] = true, ["end"] = true, ["false"] = true, ["for"] = true,
	["function"] = true, ["if"] = true, ["in"] = true, ["local"] = true,
	["nil"] = true, ["not"] = true, ["or"] = true, ["repeat"] = true,
	["return"] = true, ["then"] = true, ["true"] = true, ["until"] = true,
	["while"] = true
}

local luaBuiltins = {
	["print"] = true, ["pairs"] = true, ["ipairs"] = true, ["tonumber"] = true,
	["tostring"] = true, ["type"] = true, ["next"] = true, ["select"] = true,
	["unpack"] = true, ["pcall"] = true, ["xpcall"] = true, ["error"] = true,
	["assert"] = true, ["rawget"] = true, ["rawset"] = true, ["getmetatable"] = true,
	["setmetatable"] = true, ["require"] = true, ["loadstring"] = true
}

-- Utilitaire local pour créer des instances (copié de ScreenBuilder pour être autonome ou requis)
local function createInstance(className, props)
	local inst = Instance.new(className)
	if props then
		for k, v in pairs(props) do
			inst[k] = v
		end
	end
	return inst
end

local function colorToTag(color)
	local r = math.floor(color.R * 255)
	local g = math.floor(color.G * 255)
	local b = math.floor(color.B * 255)
	return string.format('<font color="rgb(%d,%d,%d)">', r, g, b)
end

local function escapeXML(text)
	return text:gsub("&", "&amp;"):gsub("<", "&lt;"):gsub(">", "&gt;")
end

local function highlightLua(code)
	local result = ""
	local i = 1
	local len = #code
	
	while i <= len do
		local char = code:sub(i, i)
		
		-- Commentaires
		if code:sub(i, i+1) == "--" then
			local endPos = code:find("\n", i) or (len + 1)
			local comment = code:sub(i, endPos - 1)
			result = result .. colorToTag(SyntaxColors.comment) .. escapeXML(comment) .. "</font>"
			i = endPos
		-- Chaînes de caractères avec guillemets doubles
		elseif char == '"' then
			local j = i + 1
			while j <= len and code:sub(j, j) ~= '"' do
				if code:sub(j, j) == "\\" then j = j + 1 end
				j = j + 1
			end
			local str = code:sub(i, j)
			result = result .. colorToTag(SyntaxColors.string) .. escapeXML(str) .. "</font>"
			i = j + 1
		-- Chaînes de caractères avec guillemets simples
		elseif char == "'" then
			local j = i + 1
			while j <= len and code:sub(j, j) ~= "'" do
				if code:sub(j, j) == "\\" then j = j + 1 end
				j = j + 1
			end
			local str = code:sub(i, j)
			result = result .. colorToTag(SyntaxColors.string) .. escapeXML(str) .. "</font>"
			i = j + 1
		-- Nombres
		elseif char:match("%d") then
			local j = i
			while j <= len and code:sub(j, j):match("[%d%.]") do
				j = j + 1
			end
			local num = code:sub(i, j - 1)
			result = result .. colorToTag(SyntaxColors.number) .. num .. "</font>"
			i = j
		-- Identifiants et mots-clés
		elseif char:match("[%a_]") then
			local j = i
			while j <= len and code:sub(j, j):match("[%w_]") do
				j = j + 1
			end
			local word = code:sub(i, j - 1)
			if luaKeywords[word] then
				result = result .. colorToTag(SyntaxColors.keyword) .. word .. "</font>"
			elseif luaBuiltins[word] then
				result = result .. colorToTag(SyntaxColors.builtin) .. word .. "</font>"
			else
				result = result .. colorToTag(SyntaxColors.default) .. word .. "</font>"
			end
			i = j
		-- Opérateurs et autres caractères
		else
			result = result .. colorToTag(SyntaxColors.operator) .. escapeXML(char) .. "</font>"
			i = i + 1
		end
	end
	
	return result
end

local function highlightJSON(code)
	local result = ""
	local i = 1
	local len = #code
	
	while i <= len do
		local char = code:sub(i, i)
		
		-- Chaînes de caractères
		if char == '"' then
			local j = i + 1
			while j <= len and code:sub(j, j) ~= '"' do
				if code:sub(j, j) == "\\" then j = j + 1 end
				j = j + 1
			end
			local str = code:sub(i, j)
			result = result .. colorToTag(SyntaxColors.string) .. escapeXML(str) .. "</font>"
			i = j + 1
		-- Nombres
		elseif char:match("%d") or (char == "-" and i < len and code:sub(i+1, i+1):match("%d")) then
			local j = i
			if char == "-" then j = j + 1 end
			while j <= len and code:sub(j, j):match("[%d%.]") do
				j = j + 1
			end
			local num = code:sub(i, j - 1)
			result = result .. colorToTag(SyntaxColors.number) .. num .. "</font>"
			i = j
		-- Mots-clés JSON
		elseif code:sub(i, i+3) == "true" and (i+4 > len or not code:sub(i+4, i+4):match("[%w_]")) then
			result = result .. colorToTag(SyntaxColors.keyword) .. "true" .. "</font>"
			i = i + 4
		elseif code:sub(i, i+4) == "false" and (i+5 > len or not code:sub(i+5, i+5):match("[%w_]")) then
			result = result .. colorToTag(SyntaxColors.keyword) .. "false" .. "</font>"
			i = i + 5
		elseif code:sub(i, i+3) == "null" and (i+4 > len or not code:sub(i+4, i+4):match("[%w_]")) then
			result = result .. colorToTag(SyntaxColors.keyword) .. "null" .. "</font>"
			i = i + 4
		-- Autres
		else
			result = result .. colorToTag(SyntaxColors.operator) .. escapeXML(char) .. "</font>"
			i = i + 1
		end
	end
	
	return result
end

ScreenBuilderIDE.CodeEditor = {}

function ScreenBuilderIDE.CodeEditor.Create(props)
	-- Conteneur principal (avec la bordure et le fond)
	local mainContainer = createInstance("Frame", props)
	mainContainer.ClipsDescendants = true

	-- ScrollingFrame pour le contenu (Scroll vertical et horizontal)
	local scroller = createInstance("ScrollingFrame", {
		Parent = mainContainer,
		Size = UDim2.new(1, 0, 1, 0),
		BackgroundTransparency = 1,
		ScrollBarThickness = 12,
		BottomImage = "rbxasset://textures/ui/Scroll/scroll-middle.png",
		MidImage = "rbxasset://textures/ui/Scroll/scroll-middle.png",
		TopImage = "rbxasset://textures/ui/Scroll/scroll-middle.png",
		CanvasSize = UDim2.new(0, 0, 0, 0), -- Sera ajusté dynamiquement
		AutomaticCanvasSize = Enum.AutomaticSize.XY -- Auto ajustement
	})

	-- Layout pour aligner les numéros de ligne et l'éditeur
	local layout = createInstance("UIListLayout", {
		Parent = scroller,
		FillDirection = Enum.FillDirection.Horizontal,
		SortOrder = Enum.SortOrder.LayoutOrder,
		Padding = UDim.new(0, 5)
	})

	-- Colonne des numéros de ligne
	local lineNumbersLabel = createInstance("TextLabel", {
		Parent = scroller,
		LayoutOrder = 1,
		Size = UDim2.new(0, 30, 1, 0), -- Largeur fixe initiale
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundTransparency = 1,
		Text = "1",
		TextColor3 = Color3.fromRGB(150, 150, 150),
		TextSize = 16,
		Font = Enum.Font.Code,
		TextXAlignment = Enum.TextXAlignment.Right,
		TextYAlignment = Enum.TextYAlignment.Top,
		LineHeight = 1.0
	})

	-- Séparateur (Padding géré par UIListLayout)

	-- Conteneur de l'éditeur (TextBox + Highlight)
	local editorContainer = createInstance("Frame", {
		Parent = scroller,
		LayoutOrder = 2,
		Size = UDim2.new(1, -40, 1, 0), -- Largeur restante approx
		AutomaticSize = Enum.AutomaticSize.XY,
		BackgroundTransparency = 1
	})

	local textBox = createInstance("TextBox", {
		Parent = editorContainer,
		Size = UDim2.new(0, 2000, 0, 2000), -- Grande taille pour le scroll, ajustée par AutomaticSize si possible ou manuellement
		AutomaticSize = Enum.AutomaticSize.XY,
		BackgroundTransparency = 1,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextYAlignment = Enum.TextYAlignment.Top,
		ClearTextOnFocus = false,
		MultiLine = true,
		Font = Enum.Font.Code,
		Text = props.Text or "",
		TextTransparency = 1,
		TextSize = 16,
		ZIndex = 2,
		RichText = false
	})
	
	local highlightLabel = createInstance("TextLabel", {
		Parent = editorContainer,
		Size = UDim2.new(1, 0, 1, 0),
		BackgroundTransparency = 1,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextYAlignment = Enum.TextYAlignment.Top,
		Font = Enum.Font.Code,
		Text = "",
		TextColor3 = Color3.fromRGB(220,220,220),
		TextSize = 16,
		RichText = true,
		ZIndex = 1
	})
	
	-- Synchroniser la taille du label avec la textbox
	textBox:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
		highlightLabel.Size = UDim2.new(0, textBox.AbsoluteSize.X, 0, textBox.AbsoluteSize.Y)
	end)

	function textBox:Highlight(language)
		local text = self.Text
		if language == "lua" then
			highlightLabel.Text = highlightLua(text)
		elseif language == "json" then
			highlightLabel.Text = highlightJSON(text)
		else
			highlightLabel.Text = escapeXML(text)
		end
		
		-- Mise à jour des numéros de ligne
		local _, count = text:gsub("\n", "\n")
		count = count + 1
		local lines = ""
		for i = 1, count do
			lines = lines .. i .. "\n"
		end
		lineNumbersLabel.Text = lines
		
		-- Ajuster la largeur de la colonne des numéros si nécessaire (ex: > 99 lignes)
		local numWidth = math.max(30, (#tostring(count)) * 10)
		lineNumbersLabel.Size = UDim2.new(0, numWidth, 1, 0)
		editorContainer.Size = UDim2.new(1, -(numWidth + 10), 1, 0)
	end
	
	textBox:GetPropertyChangedSignal("Text"):Connect(function()
		textBox:Highlight("lua")
	end)
	
	if props.Text and props.Text ~= "" then
		textBox:Highlight("lua")
	end

	-- Gestion simplifiée de l'indentation (Tabulation) via UserInputService si le client est local
	-- Note: Cela nécessite que ce code tourne dans un contexte LocalScript/ModuleScript côté client
	local UserInputService = game:GetService("UserInputService")
	
	textBox.Focused:Connect(function()
		-- Connexion temporaire aux inputs quand la textbox a le focus
		local connection
		connection = UserInputService.InputBegan:Connect(function(input, gameProcessed)
			if not textBox:IsFocused() then 
				connection:Disconnect() 
				return 
			end
			
			if input.KeyCode == Enum.KeyCode.Tab then
				-- Insérer une tabulation (4 espaces)
				-- Note: TextBox natives Roblox ne bloquent pas toujours le focus change sur Tab
				-- Il faut parfois ruser. Si 'Tab' change le focus, c'est dur à empêcher sans ContextActionService
				
				-- Astuce simple : Remplacer la sélection ou insérer au curseur
				local cursor = textBox.CursorPosition
				local text = textBox.Text
				local before = text:sub(1, cursor - 1)
				local after = text:sub(cursor)
				
				textBox.Text = before .. "    " .. after
				textBox.CursorPosition = cursor + 4
			end
		end)
	end)

	return mainContainer, textBox
end

return ScreenBuilderIDE
