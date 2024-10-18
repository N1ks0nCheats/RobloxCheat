-- Load OrionLib
OrionLib = loadstring(game:HttpGet(('https://raw.githubusercontent.com/shlexware/Orion/main/source')))()
local Window = OrionLib:MakeWindow({
    Name = "N1ks0n Hub",
    HidePremium = false,
    SaveConfig = true,
    ConfigFolder = "N1ks0n Hub",
    IntroEnabled = true,
    IntroText = "N1ks0n Hub | Loader",
    IntroIcon = "rbxassetid://10472045394",
    Icon = "rbxassetid://10472045394"
})

-- Services
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")


-- Variables
local LocalPlayer = Players.LocalPlayer
local ESPEnabled = false
local ChamsEnabled = false
local highlightColor = Color3.fromRGB(255, 48, 51)
local espBoxes = {}


-- Function to create a highlight for a player (Chams)
local function ApplyChams(Player)
    local Character = Player.Character or Player.CharacterAdded:Wait()
    
    -- Create a Highlight instance
    local Highlighter = Instance.new("Highlight")
    Highlighter.FillColor = highlightColor
    Highlighter.Parent = Character

    -- Store the highlighter for later removal
    chamsHighlights[Player] = Highlighter

    -- Function to update highlight based on health
    local function OnHealthChanged()
        if Character and Character:FindFirstChild("Humanoid") and Character.Humanoid.Health <= 0 then
            Highlighter:Destroy()
            chamsHighlights[Player] = nil
        end
    end

    -- Connect health change
    local Humanoid = Character:WaitForChild("Humanoid")
    Humanoid:GetPropertyChangedSignal("Health"):Connect(OnHealthChanged)

    return Highlighter
end

-- Function to create ESP box for a player
local function CreateESPBox(Player)
    local Character = Player.Character or Player.CharacterAdded:Wait()

    -- Create a BoxHandleAdornment for ESP
    local espBox = Instance.new("BoxHandleAdornment")
    espBox.Size = Character:GetExtentsSize()
    espBox.Adornee = Character
    espBox.Color3 = highlightColor
    espBox.Transparency = 0.5
    espBox.ZIndex = 10
    espBox.Parent = Character

    -- Store the ESP box for later removal
    espBoxes[Player] = espBox

    -- Clean up the box when the player dies
    Character.Humanoid.Died:Connect(function()
        if espBoxes[Player] then
            espBoxes[Player]:Destroy()
            espBoxes[Player] = nil
        end
    end)

    return espBox
end

-- Function to update Chams for all players
local function UpdateChams()
    for _, Player in pairs(Players:GetPlayers()) do
        if Player ~= LocalPlayer and Player.Character and not chamsHighlights[Player] then
            ApplyChams(Player)
        end
    end
end

-- Function to update ESP for all players
local function UpdateESP()
    for _, Player in pairs(Players:GetPlayers()) do
        if Player ~= LocalPlayer and Player.Character and not espBoxes[Player] then
            CreateESPBox(Player)
        end
    end
end

-- Function to remove all ESP boxes
local function RemoveAllESPBoxes()
    for _, espBox in pairs(espBoxes) do
        if espBox then
            espBox:Destroy()
        end
    end
    espBoxes = {}
end

-- Function to remove all Chams highlights
local function RemoveAllChams()
    for _, highlight in pairs(chamsHighlights) do
        if highlight then
            highlight:Destroy()
        end
    end
    chamsHighlights = {}
end

-- Function to start Chams thread
local function StartChamsThread()
    if chamsThread then return end  -- Prevent multiple threads
    chamsThread = RunService.Heartbeat:Connect(function()
        if ChamsEnabled then
            UpdateChams()
        else
            RemoveAllChams()
        end
    end)
end

-- Function to start ESP thread
local function StartESPThread()
    if espThread then return end  -- Prevent multiple threads
    espThread = RunService.Heartbeat:Connect(function()
        if ESPEnabled then
            UpdateESP()
        else
            RemoveAllESPBoxes()
        end
    end)
end

-- Correctly creating the Visual, Aim, Misc, and Teleport tabs
local VisualsTab = Window:MakeTab({
    Name = "Visuals",
    Icon = "rbxassetid://10472045394",
})


-- Ensure we add Chams toggle under the correct 'VisualsTab'
VisualsTab:AddToggle({
    Name = "Toggle Chams",
    Default = false,
    Callback = function(Value)
        ChamsEnabled = Value
        if ChamsEnabled then
            StartChamsThread()  -- Start the thread to continuously update Chams
        else
            RemoveAllChams()  -- Clean up Chams when disabled
        end
    end,
})

-- Ensure ESP is under 'VisualsTab'
VisualsTab:AddToggle({
    Name = "Toggle ESP Boxes",
    Default = false,
    Callback = function(Value)
        ESPEnabled = Value
        if ESPEnabled then
            StartESPThread()  -- Start the thread to continuously update ESP
        else
            RemoveAllESPBoxes()  -- Clean up ESP when disabled
        end
    end,
})

-- Key bindings for menu toggling and ESP toggle
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if not gameProcessed then
        -- Toggle the Orion window with 'F'
        if input.KeyCode == Enum.KeyCode.F then
            Window:Toggle()  -- Toggle Orion window
        end
    end
end)

-- Initial settings for players
for _, Player in pairs(Players:GetPlayers()) do
    if Player ~= LocalPlayer then
        ApplyChams(Player)
    end
end

Players.PlayerAdded:Connect(function(Player)
    Player.CharacterAdded:Connect(function()
        ApplyChams(Player)
    end)
end)
