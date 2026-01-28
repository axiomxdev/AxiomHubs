-- Librairie ScreenBuilder : facilite la création de menus UI réutilisables
local ScreenBuilder = {}

-- Utilitaire générique pour créer un Instance avec propriétés
local function createInstance(className, props)
	local inst = Instance.new(className)
	if props then
		for k, v in pairs(props) do
			inst[k] = v
		end
	end
	return inst
end

function ScreenBuilder.CreateInstance(className, props)
	return createInstance(className, props)
end

ScreenBuilder.CodeEditor = {}

-- Crée un éditeur de code (Frame + TextBox + coloration syntaxique)
function ScreenBuilder.CodeEditor.Create(props)
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
		TextColor3 = Color3.fromRGB(220,220,220),
		TextSize = 16,
	})
	-- Placeholder pour coloration syntaxique (à compléter)
	function textBox:Highlight(language)
		-- language: "lua" ou "json"
		-- TODO: appliquer la coloration syntaxique sur self.Text
		-- (à implémenter)
	end
	return editorFrame, textBox
end

-- TODO: Ajouter des fonctions pour la coloration syntaxique Lua/JSON

return ScreenBuilder