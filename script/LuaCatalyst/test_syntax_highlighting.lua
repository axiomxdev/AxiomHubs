-- Test script for syntax highlighting in ScreenBuilder
-- This script demonstrates the usage of the CodeEditor with syntax highlighting

-- Load the ScreenBuilder library
local ScreenBuilder = loadstring(game:HttpGet("path/to/ScreenBuilder.lua"))()

-- Create a test GUI
local screenGui = Instance.new("ScreenGui")
screenGui.Parent = game.Players.LocalPlayer.PlayerGui

-- Sample Lua code to test syntax highlighting
local sampleLuaCode = [[
-- This is a comment
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
]]

-- Create a code editor with the sample code
local editorFrame, textBox = ScreenBuilder.CodeEditor.Create({
    Parent = screenGui,
    Size = UDim2.new(0, 600, 0, 400),
    Position = UDim2.new(0.5, -300, 0.5, -200),
    BackgroundColor3 = Color3.fromRGB(30, 30, 30),
    Text = sampleLuaCode
})

print("Code editor created with syntax highlighting")
print("You can edit the text and see the syntax highlighting update automatically")

-- Test the Highlight method explicitly with Lua
textBox:Highlight("lua")
print("Applied Lua syntax highlighting")

-- Test JSON highlighting
local sampleJSONCode = [[
{
    "name": "test",
    "value": 123,
    "active": true,
    "data": null,
    "items": [1, 2, 3]
}
]]

-- Wait a bit, then switch to JSON example
task.wait(5)
textBox.Text = sampleJSONCode
textBox:Highlight("json")
print("Switched to JSON syntax highlighting")
