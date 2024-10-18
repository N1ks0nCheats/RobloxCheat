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

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")


local LocalPlayer = Players.LocalPlayer
local ESPEnabled = false
local ChamsEnabled = false
local highlightColor = Color3.fromRGB(255, 48, 51)
local espBoxes = {}


local function ApplyChams(Player)
    local Character = Player.Character or Player.CharacterAdded:Wait()
    
    local Highlighter = Instance.new("Highlight")
    Highlighter.FillColor = highlightColor
    Highlighter.Parent = Character

    chamsHighlights[Player] = Highlighter

    local function OnHealthChanged()
        if Character and Character:FindFirstChild("Humanoid") and Character.Humanoid.Health <= 0 then
            Highlighter:Destroy()
            chamsHighlights[Player] = nil
        end
    end

    local Humanoid = Character:WaitForChild("Humanoid")
    Humanoid:GetPropertyChangedSignal("Health"):Connect(OnHealthChanged)

    return Highlighter
end

local function CreateESPBox(Player)
    local Character = Player.Character or Player.CharacterAdded:Wait()

    local espBox = Instance.new("BoxHandleAdornment")
    espBox.Size = Character:GetExtentsSize()
    espBox.Adornee = Character
    espBox.Color3 = highlightColor
    espBox.Transparency = 0.5
    espBox.ZIndex = 10
    espBox.Parent = Character

    espBoxes[Player] = espBox

    Character.Humanoid.Died:Connect(function()
        if espBoxes[Player] then
            espBoxes[Player]:Destroy()
            espBoxes[Player] = nil
        end
    end)

    return espBox
end

local function UpdateChams()
    for _, Player in pairs(Players:GetPlayers()) do
        if Player ~= LocalPlayer and Player.Character and not chamsHighlights[Player] then
            ApplyChams(Player)
        end
    end
end

local function UpdateESP()
    for _, Player in pairs(Players:GetPlayers()) do
        if Player ~= LocalPlayer and Player.Character and not espBoxes[Player] then
            CreateESPBox(Player)
        end
    end
end

local function RemoveAllESPBoxes()
    for _, espBox in pairs(espBoxes) do
        if espBox then
            espBox:Destroy()
        end
    end
    espBoxes = {}
end

local function RemoveAllChams()
    for _, highlight in pairs(chamsHighlights) do
        if highlight then
            highlight:Destroy()
        end
    end
    chamsHighlights = {}
end

local function StartChamsThread()
    if chamsThread then return end
    chamsThread = RunService.Heartbeat:Connect(function()
        if ChamsEnabled then
            UpdateChams()
        else
            RemoveAllChams()
        end
    end)
end

local function StartESPThread()
    if espThread then return end
    espThread = RunService.Heartbeat:Connect(function()
        if ESPEnabled then
            UpdateESP()
        else
            RemoveAllESPBoxes()
        end
    end)
end

local VisualsTab = Window:MakeTab({
    Name = "Visuals",
    Icon = "rbxassetid://10472045394",
})


VisualsTab:AddToggle({
    Name = "Toggle Chams",
    Default = false,
    Callback = function(Value)
        ChamsEnabled = Value
        if ChamsEnabled then
            StartChamsThread()
        else
            RemoveAllChams()
        end
    end,
})

VisualsTab:AddToggle({
    Name = "Toggle ESP Boxes",
    Default = false,
    Callback = function(Value)
        ESPEnabled = Value
        if ESPEnabled then
            StartESPThread()
        else
            RemoveAllESPBoxes()
        end
    end,
})

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if not gameProcessed then
        if input.KeyCode == Enum.KeyCode.F then
            Window:Toggle()
        end
    end
end)

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
