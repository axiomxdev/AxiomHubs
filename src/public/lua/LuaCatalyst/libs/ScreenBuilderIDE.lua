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
	local editorFrame = createInstance("Frame", props)
	
	local textBox = createInstance("TextBox", {
		Parent = editorFrame,
		Size = UDim2.new(1,0,1,0),
		BackgroundTransparency = 1,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextYAlignment = Enum.TextYAlignment.Top,
		ClearTextOnFocus = false,
		MultiLine = true,
		Font = Enum.Font.Code,
		Text = props.Text or "",
		TextTransparency = 1,
		TextSize = 16,
		ZIndex = 2
	})
	
	local highlightLabel = createInstance("TextLabel", {
		Parent = editorFrame,
		Size = UDim2.new(1,0,1,0),
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
	
	function textBox:Highlight(language)
		local text = self.Text
		if language == "lua" then
			highlightLabel.Text = highlightLua(text)
		elseif language == "json" then
			highlightLabel.Text = highlightJSON(text)
		else
			highlightLabel.Text = escapeXML(text)
		end
	end
	
	textBox:GetPropertyChangedSignal("Text"):Connect(function()
		textBox:Highlight("lua")
	end)
	
	if props.Text and props.Text ~= "" then
		textBox:Highlight("lua")
	end
	
	return editorFrame, textBox
end

return ScreenBuilderIDE
