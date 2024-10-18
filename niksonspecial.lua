-- Vytvoření ScreenGui
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "N1ks0nMenu"
screenGui.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")
screenGui.Enabled = false  -- Menu je zpočátku skryté

-- Vytvoření Frame pro menu
local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 200, 0, 400)
frame.Position = UDim2.new(0.5, -100, 0.5, -200)
frame.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
frame.Parent = screenGui

-- Vytvoření názvu menu
local title = Instance.new("TextLabel")
title.Text = "N1ks0n Menu"
title.Size = UDim2.new(1, 0, 0, 50)
title.BackgroundTransparency = 1
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.Font = Enum.Font.SourceSansBold
title.TextSize = 24
title.Parent = frame

-- Vytvoření tlačítka pro Highlight
local highlightButton = Instance.new("TextButton")
highlightButton.Text = "Toggle Highlight"
highlightButton.Size = UDim2.new(1, -20, 0, 50)
highlightButton.Position = UDim2.new(0, 10, 0, 60)
highlightButton.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
highlightButton.TextColor3 = Color3.fromRGB(255, 255, 255)
highlightButton.Font = Enum.Font.SourceSans
highlightButton.TextSize = 20
highlightButton.Parent = frame

-- Vytvoření tlačítka pro Player Tracking
local trackButton = Instance.new("TextButton")
trackButton.Text = "Toggle Player Tracking"
trackButton.Size = UDim2.new(1, -20, 0, 50)
trackButton.Position = UDim2.new(0, 10, 0, 120)
trackButton.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
trackButton.TextColor3 = Color3.fromRGB(255, 255, 255)
trackButton.Font = Enum.Font.SourceSans
trackButton.TextSize = 20
trackButton.Parent = frame

-- Proměnné pro sledování stavů Highlight a Tracking
local highlightActive = false
local trackActive = false

-- Funkce pro zapnutí/vypnutí Highlight
local function toggleHighlight()
    highlightActive = not highlightActive
    
    if highlightActive then
        -- Aktivace zvýraznění objektů
        for _, object in ipairs(workspace:GetChildren()) do
            if object:IsA("Part") then
                local highlight = Instance.new("Highlight")
                highlight.Parent = object
                highlight.FillColor = Color3.fromRGB(0, 255, 0)
                highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
                highlight.OutlineTransparency = 0
            end
        end
        highlightButton.Text = "Disable Highlight"
    else
        -- Deaktivace zvýraznění (odstranění všech Highlight instancí)
        for _, object in ipairs(workspace:GetChildren()) do
            if object:IsA("Part") and object:FindFirstChild("Highlight") then
                object.Highlight:Destroy()
            end
        end
        highlightButton.Text = "Enable Highlight"
    end
end

highlightButton.MouseButton1Click:Connect(toggleHighlight)

-- Funkce pro zapnutí/vypnutí Player Tracking
local function toggleTracking()
    trackActive = not trackActive

    if trackActive then
        -- Aktivace tracking hráčů (přidání BillboardGui nad hlavami hráčů)
        for _, player in ipairs(game.Players:GetPlayers()) do
            if player.Character and player ~= game.Players.LocalPlayer then
                local character = player.Character
                local head = character:FindFirstChild("Head")
                
                if head then
                    -- Vytvoření BillboardGui nad hlavou hráče
                    local billboard = Instance.new("BillboardGui")
                    billboard.Size = UDim2.new(0, 100, 0, 50)
                    billboard.StudsOffset = Vector3.new(0, 3, 0)
                    billboard.AlwaysOnTop = true
                    billboard.Parent = head
                    
                    local textLabel = Instance.new("TextLabel")
                    textLabel.Text = player.Name
                    textLabel.Size = UDim2.new(1, 0, 1, 0)
                    textLabel.BackgroundTransparency = 1
                    textLabel.TextColor3 = Color3.fromRGB(255, 0, 0)
                    textLabel.TextStrokeTransparency = 0
                    textLabel.Parent = billboard
                end
            end
        end
        trackButton.Text = "Disable Player Tracking"
    else
        -- Deaktivace tracking (odstranění všech BillboardGui)
        for _, player in ipairs(game.Players:GetPlayers()) do
            if player.Character and player ~= game.Players.LocalPlayer then
                local head = player.Character:FindFirstChild("Head")
                
                if head and head:FindFirstChildOfClass("BillboardGui") then
                    head:FindFirstChildOfClass("BillboardGui"):Destroy()
                end
            end
        end
        trackButton.Text = "Enable Player Tracking"
    end
end

trackButton.MouseButton1Click:Connect(toggleTracking)

-- Funkce pro otevření/zavření menu
local menuOpen = false
local userInputService = game:GetService("UserInputService")

userInputService.InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.RightShift then
        menuOpen = not menuOpen
        screenGui.Enabled = menuOpen
    end
end)
