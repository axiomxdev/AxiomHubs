local ScreenBuilder = _G.ScreenBuilder
local ScreenBuilderIDE = _G.ScreenBuilderIDE

local IDE = {}
IDE.__index = IDE

-- Couleurs
local Colors = {
	Background = Color3.fromRGB(30, 30, 30),
	Sidebar = Color3.fromRGB(37, 37, 38),
	TabBar = Color3.fromRGB(45, 45, 45),
	TabActive = Color3.fromRGB(30, 30, 30),
	TabInactive = Color3.fromRGB(50, 50, 50),
	Button = Color3.fromRGB(0, 122, 204),
	Text = Color3.fromRGB(204, 204, 204)
}

function IDE.new(targetParent)
	local self = setmetatable({}, IDE)
	self.Target = targetParent
	self.Files = {}
	self.ActiveFileId = nil
	self.NextFileId = 1
	
	self:BuildUI()
	self:NewFile("Untitled-1.lua", 'print("Hello LuaCatalyst!")')
	
	return self
end

function IDE:BuildUI()
	-- Main Frame
	self.MainFrame = ScreenBuilder.CreateFrame({
		Parent = self.Target,
		Size = UDim2.new(1, 0, 1, 0),
		BackgroundColor3 = Colors.Background,
		BorderSizePixel = 0
	})
	
	-- Toolbar
	self.Toolbar = ScreenBuilder.CreateFrame({
		Parent = self.MainFrame,
		Size = UDim2.new(1, 0, 0, 30),
		BackgroundColor3 = Colors.Sidebar,
		BorderSizePixel = 0
	})
	
	local toolbarLayout = ScreenBuilder.CreateUIListLayout({
		Parent = self.Toolbar,
		FillDirection = Enum.FillDirection.Horizontal,
		Padding = UDim.new(0, 5)
	})
	
	-- Toolbar Buttons
	self:CreateToolbarButton("Run", function() self:RunCurrentScript() end)
	self:CreateToolbarButton("New", function() self:NewFile() end)
	self:CreateToolbarButton("Close", function() self:CloseCurrentFile() end)
	
	-- Tab Bar
	self.TabBar = ScreenBuilder.CreateScrollingFrame({
		Parent = self.MainFrame,
		Position = UDim2.new(0, 0, 0, 30),
		Size = UDim2.new(1, 0, 0, 25),
		BackgroundColor3 = Colors.TabBar,
		BorderSizePixel = 0,
		ScrollBarThickness = 0,
		CanvasSize = UDim2.new(0, 0, 0, 0),
		AutomaticCanvasSize = Enum.AutomaticSize.X
	})
	
	local tabLayout = ScreenBuilder.CreateUIListLayout({
		Parent = self.TabBar,
		FillDirection = Enum.FillDirection.Horizontal,
		SortOrder = Enum.SortOrder.LayoutOrder
	})
	
	-- Editor Area
	self.EditorArea = ScreenBuilder.CreateFrame({
		Parent = self.MainFrame,
		Position = UDim2.new(0, 0, 0, 55),
		Size = UDim2.new(1, 0, 1, -55),
		BackgroundTransparency = 1
	})
end

function IDE:CreateToolbarButton(text, callback)
	local btn = ScreenBuilder.CreateButton({
		Parent = self.Toolbar,
		Size = UDim2.new(0, 60, 1, 0),
		Text = text,
		BackgroundColor3 = Colors.Button,
		TextColor3 = Colors.Text,
		BorderSizePixel = 0
	})
	
	btn.MouseButton1Click:Connect(callback)
	return btn
end

function IDE:NewFile(name, content)
	name = name or ("Untitled-" .. self.NextFileId .. ".lua")
	content = content or ""
	
	local fileId = self.NextFileId
	self.NextFileId = self.NextFileId + 1
	
	-- Create Editor
	local editorContainer, textBox = ScreenBuilderIDE.CodeEditor.Create({
		Parent = self.EditorArea,
		Size = UDim2.new(1, 0, 1, 0),
		Visible = false,
		Text = content,
		BackgroundColor3 = Colors.Background
	})
	
	-- Create Tab
	local tabBtn = ScreenBuilder.CreateButton({
		Parent = self.TabBar,
		Size = UDim2.new(0, 100, 1, 0),
		Text = name,
		BackgroundColor3 = Colors.TabInactive,
		TextColor3 = Colors.Text,
		BorderSizePixel = 0,
		LayoutOrder = fileId
	})
	
	local fileData = {
		id = fileId,
		name = name,
		editor = editorContainer,
		textBox = textBox,
		tab = tabBtn
	}
	
	self.Files[fileId] = fileData
	
	tabBtn.MouseButton1Click:Connect(function()
		self:SwitchToFile(fileId)
	end)
	
	self:SwitchToFile(fileId)
end

function IDE:SwitchToFile(fileId)
	if self.ActiveFileId and self.Files[self.ActiveFileId] then
		local oldFile = self.Files[self.ActiveFileId]
		oldFile.editor.Visible = false
		oldFile.tab.BackgroundColor3 = Colors.TabInactive
	end
	
	self.ActiveFileId = fileId
	local newFile = self.Files[fileId]
	
	if newFile then
		newFile.editor.Visible = true
		newFile.tab.BackgroundColor3 = Colors.TabActive
	end
end

function IDE:CloseCurrentFile()
	if not self.ActiveFileId then return end
	
	local fileId = self.ActiveFileId
	local fileData = self.Files[fileId]
	
	fileData.editor:Destroy()
	fileData.tab:Destroy()
	self.Files[fileId] = nil
	self.ActiveFileId = nil
	
	for id, _ in pairs(self.Files) do
		self:SwitchToFile(id)
		break
	end
end

function IDE:RunCurrentScript()
	if not self.ActiveFileId then return end
	local fileData = self.Files[self.ActiveFileId]
	local code = fileData.textBox.Text
	
	local func, err = loadstring(code)
	if not func then
		warn("Syntax Error: " .. tostring(err))
		return
	end
	
	local success, runtimeErr = pcall(func)
	if not success then
		warn("Runtime Error: " .. tostring(runtimeErr))
	else
		print("Script executed successfully.")
	end
end

return IDE
