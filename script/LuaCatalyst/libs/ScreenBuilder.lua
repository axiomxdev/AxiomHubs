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

function ScreenBuilder.CreateButton(props)
	return createInstance("TextButton", props)
end

function ScreenBuilder.CreateLabel(props)
	return createInstance("TextLabel", props)
end

function ScreenBuilder.CreateFrame(props)
	return createInstance("Frame", props)
end

function ScreenBuilder.CreateScrollingFrame(props)
	return createInstance("ScrollingFrame", props)
end

function ScreenBuilder.CreateUIListLayout(props)
	return createInstance("UIListLayout", props)
end

return ScreenBuilder
