-- Load OrionLib
OrionLib = loadstring(game:HttpGet('https://raw.githubusercontent.com/shlexware/Orion/main/source'))()
local Window = OrionLib:MakeWindow({
    Name = "Nix Menu",
    HidePremium = false,
    SaveConfig = true,
    ConfigFolder = "Nix Menu",
    IntroEnabled = true,
    IntroText = "Nix | Loader",
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
local chamsHighlights = {} -- Initialize chamsHighlights
local chamsThread = nil
local espThread = nil

-- NoClip Variables
local NoClipEnabled = false
local Flying = false
local Velocity = Vector3.new(0, 0, 0)
local speed = 50 -- Létání rychlost

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

-- Function to enable/disable NoClip
local function ToggleNoClip()
    NoClipEnabled = not NoClipEnabled
    if NoClipEnabled then
        -- Activate NoClip
        local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
        local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")
        for _, part in pairs(Character:GetChildren()) do
            if part:IsA("BasePart") then
                part.CanCollide = false
            end
        end
        Flying = true
    else
        -- Deactivate NoClip
        local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
        for _, part in pairs(Character:GetChildren()) do
            if part:IsA("BasePart") then
                part.CanCollide = true
            end
        end
        Flying = false
    end
end

-- Function to handle flying behavior
local function Fly()
    if Flying then
        local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
        local HumanoidRootPart = Character:FindFirstChild("HumanoidRootPart")
        local Mouse = LocalPlayer:GetMouse()

        if HumanoidRootPart then
            -- Update velocity and position
            Velocity = Velocity * 0.8
            local moveDirection = (Mouse.Hit.p - HumanoidRootPart.Position).unit * speed
            Velocity = Velocity + moveDirection
            HumanoidRootPart.Velocity = Velocity
            HumanoidRootPart.CFrame = HumanoidRootPart.CFrame + HumanoidRootPart.Velocity * RunService.Heartbeat:Wait()
        end
    end
end

-- Key bindings for menu toggling and ESP toggle
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if not gameProcessed then
        -- Toggle the Orion window with 'F'
        if input.KeyCode == Enum.KeyCode.F then
            Window:Toggle()  -- Toggle Orion window
        end

        -- Toggle NoClip (Flying) with 'E'
        if input.KeyCode == Enum.KeyCode.E then
            ToggleNoClip()
        end
    end
end)

-- Initial settings for players
for _, Player in pairs(Players:GetPlayers()) do
    if Player ~= LocalPlayer then
        ApplyChams(Player)
    end
end

-- Connect PlayerAdded event to apply Chams when a new player joins
Players.PlayerAdded:Connect(function(Player)
    Player.CharacterAdded:Connect(function()
        ApplyChams(Player)
    end)
end)

-- Run the Fly function if NoClip is enabled
RunService.Heartbeat:Connect(function()
    if Flying then
        Fly()
    end
end)

-- Correctly creating the Visual, Aim, Misc, and Teleport tabs
local VisualsTab = Window:MakeTab({
    Name = "Visuals",
    Icon = "rbxassetid://10472045394",
})

-- Add Chams toggle under the correct 'VisualsTab'
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

-- Add ESP toggle under 'VisualsTab'
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

-- Add NoClip toggle under 'MiscTab'
local MiscTab = Window:MakeTab({
    Name = "Misc",
    Icon = "rbxassetid://10472045394",
})

MiscTab:AddToggle({
    Name = "Toggle NoClip",
    Default = false,
    Callback = function(Value)
        ToggleNoClip()
    end,
})
