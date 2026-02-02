# Syntax Highlighting Implementation for ScreenBuilder.lua

## Overview
This implementation adds syntax highlighting capabilities to the CodeEditor component in ScreenBuilder.lua, addressing the TODO comment: "appliquer la coloration syntaxique sur self.Text".

## Features

### 1. Lua Syntax Highlighting
The implementation provides comprehensive syntax highlighting for Lua code with support for:
- **Keywords**: `local`, `function`, `if`, `then`, `else`, `end`, `for`, `while`, `return`, etc.
- **Built-in Functions**: `print`, `pairs`, `ipairs`, `tonumber`, `tostring`, `pcall`, `require`, etc.
- **Strings**: Both single and double-quoted strings with proper escape sequence handling
- **Comments**: Single-line comments starting with `--`
- **Numbers**: Integer and decimal numbers
- **Operators**: All operators and punctuation
- **Identifiers**: Variable and function names

### 2. JSON Syntax Highlighting
Support for JSON syntax including:
- **Keywords**: `true`, `false`, `null` (with proper word boundary detection)
- **Strings**: Double-quoted strings (keys and values)
- **Numbers**: Integer and decimal numbers (including negative numbers)
- **Structural Characters**: Braces, brackets, colons, commas

### 3. Color Scheme
Professional color palette inspired by VS Code's dark theme:
- Keywords: Blue (86, 156, 214)
- Strings: Orange/Salmon (206, 145, 120)
- Numbers: Light Green (181, 206, 168)
- Comments: Green (106, 153, 85)
- Operators: Light Gray (212, 212, 212)
- Built-in Functions: Cyan (78, 201, 176)
- Default Text: Off-White (220, 220, 220)

## Technical Implementation

### Architecture
The implementation uses a dual-layer approach:
1. **TextBox (ZIndex 2)**: Transparent text box that captures user input
2. **TextLabel (ZIndex 1)**: Displays the syntax-highlighted text using RichText

This approach allows users to edit normally while seeing highlighted syntax in real-time.

### Key Functions

#### `highlightLua(code)`
Tokenizes and colorizes Lua code using a state machine approach:
- Scans through the code character by character
- Identifies tokens (comments, strings, numbers, keywords, identifiers, operators)
- Applies appropriate color tags using RichText format

#### `highlightJSON(code)`
Similar to `highlightLua()` but tailored for JSON syntax:
- Handles JSON-specific keywords with proper word boundary detection
- Supports negative numbers
- Processes string values and structural characters

#### `textBox:Highlight(language)`
Method added to the TextBox that applies syntax highlighting:
- `textBox:Highlight("lua")` - Apply Lua highlighting
- `textBox:Highlight("json")` - Apply JSON highlighting
- Automatically called on text changes for real-time highlighting

### Utilities

#### `colorToTag(color)`
Converts Roblox Color3 values to RichText RGB format:
```lua
Color3.fromRGB(86, 156, 214) -> '<font color="rgb(86,156,214)">'
```

#### `escapeXML(text)`
Escapes special XML/HTML characters to prevent rendering issues:
- `&` → `&amp;`
- `<` → `&lt;`
- `>` → `&gt;`

## Usage Example

```lua
local ScreenBuilder = loadstring(game:HttpGet("path/to/ScreenBuilder.lua"))()

local editorFrame, textBox = ScreenBuilder.CodeEditor.Create({
    Parent = myGui,
    Size = UDim2.new(0, 600, 0, 400),
    Position = UDim2.new(0.5, -300, 0.5, -200),
    BackgroundColor3 = Color3.fromRGB(30, 30, 30),
    Text = "local x = 42\nprint(x)"
})

-- Syntax highlighting is applied automatically as you type (Lua by default)
-- You can also manually trigger highlighting:
textBox:Highlight("lua")  -- For Lua code
textBox:Highlight("json") -- For JSON code
```

## Testing
A test script is provided at `script/LuaCatalyst/test_syntax_highlighting.lua` that demonstrates:
- Creating a code editor with sample Lua code
- Automatic syntax highlighting
- Switching between Lua and JSON highlighting

## Performance Considerations
- The syntax highlighting is applied on every text change
- For very large files, this could impact performance
- Consider adding debouncing for production use if needed

## Future Enhancements
Potential improvements for the future:
1. Support for multi-line strings (Lua `[[ ]]` syntax)
2. Additional language support (Python, JavaScript, etc.)
3. Customizable color schemes
4. Line numbering
5. Syntax error detection and highlighting
6. Code folding
7. Performance optimization with debouncing

## Security
- All user input is properly escaped using `escapeXML()` to prevent XSS-like issues
- No use of `loadstring()` or code execution on user input
- RichText tags are carefully constructed to avoid injection

## Compatibility
- Requires Roblox environment with RichText support
- Uses modern Roblox APIs (`task.wait` instead of deprecated `wait`)
- Compatible with the existing ScreenBuilder architecture

## Implementation Stats
- Lines added: ~260
- Functions added: 4 main functions + 2 utility functions
- Languages supported: Lua, JSON
- Color definitions: 7 distinct token types
