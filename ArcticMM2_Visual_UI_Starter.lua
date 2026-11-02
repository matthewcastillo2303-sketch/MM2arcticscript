-- Arctic MM2 - Visual UI Starter
-- Safe, visual-only Roblox Studio example.
-- Gun Drop ESP scans YOUR experience's Workspace for objects named:
-- Gun, Revolver, DroppedGun, Dropped_Gun, or GoldenGun.
-- It does NOT read roles, grant weapons, pick up guns, damage players,
-- teleport players, or interact with the live MM2 game.
--
-- Install in your OWN Roblox Studio experience:
-- StarterPlayer > StarterPlayerScripts > LocalScript

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local old = playerGui:FindFirstChild("ArcticMM2")
if old then
    old:Destroy()
end

local gui = Instance.new("ScreenGui")
gui.Name = "ArcticMM2"
gui.ResetOnSpawn = false
gui.Parent = playerGui

local panel = Instance.new("Frame")
panel.Name = "Main"
panel.Size = UDim2.fromOffset(300, 340)
panel.Position = UDim2.new(0.5, -150, 0.5, -170)
panel.BackgroundColor3 = Color3.fromRGB(17, 22, 32)
panel.BorderSizePixel = 0
panel.Parent = gui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 12)
corner.Parent = panel

local stroke = Instance.new("UIStroke")
stroke.Color = Color3.fromRGB(65, 175, 255)
stroke.Thickness = 1.5
stroke.Parent = panel

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -50, 0, 42)
title.Position = UDim2.fromOffset(14, 4)
title.BackgroundTransparency = 1
title.Text = "ARCTIC MM2"
title.TextColor3 = Color3.fromRGB(225, 242, 255)
title.Font = Enum.Font.GothamBold
title.TextSize = 19
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = panel

local subtitle = Instance.new("TextLabel")
subtitle.Size = UDim2.new(1, -28, 0, 20)
subtitle.Position = UDim2.fromOffset(14, 42)
subtitle.BackgroundTransparency = 1
subtitle.Text = "VISUAL UI STARTER"
subtitle.TextColor3 = Color3.fromRGB(115, 165, 200)
subtitle.Font = Enum.Font.Gotham
subtitle.TextSize = 10
subtitle.TextXAlignment = Enum.TextXAlignment.Left
subtitle.Parent = panel

local close = Instance.new("TextButton")
close.Size = UDim2.fromOffset(30, 30)
close.Position = UDim2.new(1, -38, 0, 8)
close.BackgroundColor3 = Color3.fromRGB(35, 48, 65)
close.Text = "×"
close.TextColor3 = Color3.fromRGB(230, 240, 255)
close.Font = Enum.Font.GothamBold
close.TextSize = 22
close.Parent = panel
Instance.new("UICorner", close).CornerRadius = UDim.new(0, 8)

local status = Instance.new("TextLabel")
status.Size = UDim2.new(1, -28, 0, 34)
status.Position = UDim2.fromOffset(14, 76)
status.BackgroundColor3 = Color3.fromRGB(25, 37, 52)
status.Text = "  Ready — visual demo only"
status.TextColor3 = Color3.fromRGB(175, 210, 235)
status.Font = Enum.Font.Gotham
status.TextSize = 11
status.TextXAlignment = Enum.TextXAlignment.Left
status.Parent = panel
Instance.new("UICorner", status).CornerRadius = UDim.new(0, 7)

local content = Instance.new("Frame")
content.Size = UDim2.new(1, -28, 1, -126)
content.Position = UDim2.fromOffset(14, 120)
content.BackgroundTransparency = 1
content.Parent = panel

local layout = Instance.new("UIListLayout")
layout.Padding = UDim.new(0, 8)
layout.SortOrder = Enum.SortOrder.LayoutOrder
layout.Parent = content

local gunESPEnabled = false
local trackedGunDrops = {}

local function isGunDrop(instance)
    local name = string.lower(instance.Name)
    return name == "gun" or name == "revolver" or name == "droppedgun"
        or name == "dropped_gun" or name == "goldengun"
end

local function getAdornee(instance)
    if instance:IsA("BasePart") then
        return instance
    end
    if instance:IsA("Tool") or instance:IsA("Model") then
        return instance:FindFirstChildWhichIsA("BasePart", true)
    end
    return nil
end

local function clearGunDrop(instance)
    local entry = trackedGunDrops[instance]
    if entry then
        if entry.highlight then entry.highlight:Destroy() end
        if entry.billboard then entry.billboard:Destroy() end
        trackedGunDrops[instance] = nil
    end
end

local function refreshGunDrop(instance)
    if not gunESPEnabled or not instance:IsDescendantOf(workspace) or not isGunDrop(instance) then
        clearGunDrop(instance)
        return
    end

    local adornee = getAdornee(instance)
    if not adornee then return end

    local entry = trackedGunDrops[instance]
    if not entry then
        local highlight = Instance.new("Highlight")
        highlight.Name = "ArcticGunDropHighlight"
        highlight.Adornee = instance:IsA("Model") and instance or adornee
        highlight.FillColor = Color3.fromRGB(255, 205, 65)
        highlight.OutlineColor = Color3.fromRGB(255, 240, 150)
        highlight.FillTransparency = 0.72
        highlight.OutlineTransparency = 0
        highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
        highlight.Parent = gui

        local billboard = Instance.new("BillboardGui")
        billboard.Name = "ArcticGunDropDistance"
        billboard.Adornee = adornee
        billboard.Size = UDim2.fromOffset(110, 24)
        billboard.StudsOffset = Vector3.new(0, 2.2, 0)
        billboard.AlwaysOnTop = true
        billboard.Parent = gui

        local label = Instance.new("TextLabel")
        label.Size = UDim2.fromScale(1, 1)
        label.BackgroundTransparency = 1
        label.TextColor3 = Color3.fromRGB(255, 220, 105)
        label.TextStrokeTransparency = 0.25
        label.Font = Enum.Font.GothamBold
        label.TextSize = 12
        label.Text = "DROPPED GUN"
        label.Parent = billboard

        entry = {highlight = highlight, billboard = billboard, label = label, adornee = adornee}
        trackedGunDrops[instance] = entry
    else
        entry.adornee = adornee
        entry.billboard.Adornee = adornee
        entry.highlight.Adornee = instance:IsA("Model") and instance or adornee
    end

    local character = player.Character
    local root = character and character:FindFirstChild("HumanoidRootPart")
    if root then
        local distance = (root.Position - adornee.Position).Magnitude
        entry.label.Text = string.format("DROPPED GUN  •  %d studs", math.floor(distance + 0.5))
    else
        entry.label.Text = "DROPPED GUN"
    end
end

local function setGunDropESP(enabled)
    gunESPEnabled = enabled
    if enabled then
        for _, instance in ipairs(workspace:GetDescendants()) do
            if isGunDrop(instance) then
                refreshGunDrop(instance)
            end
        end
    else
        for instance in pairs(trackedGunDrops) do
            clearGunDrop(instance)
        end
    end
end

workspace.DescendantAdded:Connect(function(instance)
    if gunESPEnabled and isGunDrop(instance) then
        task.defer(refreshGunDrop, instance)
    end
end)

workspace.DescendantRemoving:Connect(function(instance)
    clearGunDrop(instance)
end)

task.spawn(function()
    while gui.Parent do
        if gunESPEnabled then
            for instance in pairs(trackedGunDrops) do
                if instance.Parent then
                    refreshGunDrop(instance)
                else
                    clearGunDrop(instance)
                end
            end
        end
        task.wait(0.5)
    end
end)

local function addToggle(labelText, color, callback)
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(1, 0, 0, 38)
    button.BackgroundColor3 = Color3.fromRGB(29, 40, 55)
    button.Text = ""
    button.AutoButtonColor = true
    button.Parent = content
    Instance.new("UICorner", button).CornerRadius = UDim.new(0, 8)

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -64, 1, 0)
    label.Position = UDim2.fromOffset(12, 0)
    label.BackgroundTransparency = 1
    label.Text = labelText
    label.TextColor3 = color
    label.Font = Enum.Font.GothamSemibold
    label.TextSize = 12
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = button

    local state = Instance.new("TextLabel")
    state.Size = UDim2.fromOffset(42, 22)
    state.Position = UDim2.new(1, -52, 0.5, -11)
    state.BackgroundColor3 = Color3.fromRGB(65, 78, 94)
    state.Text = "OFF"
    state.TextColor3 = Color3.fromRGB(230, 240, 255)
    state.Font = Enum.Font.GothamBold
    state.TextSize = 10
    state.Parent = button
    Instance.new("UICorner", state).CornerRadius = UDim.new(0, 6)

    local enabled = false
    button.MouseButton1Click:Connect(function()
        enabled = not enabled
        state.Text = enabled and "ON" or "OFF"
        state.BackgroundColor3 = enabled
            and Color3.fromRGB(25, 115, 165)
            or Color3.fromRGB(65, 78, 94)
        status.Text = "  " .. labelText .. (enabled and " enabled" or " disabled")
        if callback then
            callback(enabled)
        end
    end)
end

addToggle("Murderer ESP — red preview", Color3.fromRGB(255, 105, 105))
addToggle("Sheriff ESP — blue preview", Color3.fromRGB(105, 175, 255))
addToggle("Innocent ESP — green preview", Color3.fromRGB(110, 230, 150))
addToggle("Gun Drop ESP — yellow + distance", Color3.fromRGB(255, 215, 100), setGunDropESP)

local note = Instance.new("TextLabel")
note.Size = UDim2.new(1, 0, 0, 28)
note.BackgroundTransparency = 1
note.Text = "Demo toggles only; no live-game effects."
note.TextColor3 = Color3.fromRGB(120, 145, 170)
note.Font = Enum.Font.Gotham
note.TextSize = 9
note.Parent = content

close.MouseButton1Click:Connect(function()
    gui:Destroy()
end)

-- Drag the panel by its header area.
local dragging = false
local dragStart
local startPosition

title.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPosition = panel.Position
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement
        or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStart
        panel.Position = UDim2.new(
            startPosition.X.Scale,
            startPosition.X.Offset + delta.X,
            startPosition.Y.Scale,
            startPosition.Y.Offset + delta.Y
        )
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
        dragging = false
    end
end)
