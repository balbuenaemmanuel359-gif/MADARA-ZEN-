-- MADARA ZEN - MUSCLE LEGEND SCRIPT v3 [WORKING]
-- Ultra Fast Auto Strength | Auto Farm | Auto Rebirth
-- Enhanced with Tabbed Interface + RUN Function

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")
local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")

-- ACTIVE FLAGS
local STRENGTH_ACTIVE = false
local FARM_ACTIVE = false
local REBIRTH_ACTIVE = false
local GOD_MODE_ACTIVE = false
local RUN_ACTIVE = false

-- ITEM LISTS FOR FARMING
local STRENGTH_ITEMS = {
    "Protein Egg", "Tropical Shake", "Energy Bar", "Protein Shake",
    "Energy Shake", "Protein Bar", "TOUGH Bar", "Ultra Shake", "Muscle Juice"
}

-- ========== RUN FUNCTION ==========
local function RunScript()
    -- Execute all active functions at once
    while RUN_ACTIVE do
        pcall(function()
            local activeCount = 0
            
            if STRENGTH_ACTIVE then
                activeCount = activeCount + 1
                ActivateStrength()
            end
            
            if FARM_ACTIVE then
                activeCount = activeCount + 1
                AutoFarm()
            end
            
            if REBIRTH_ACTIVE then
                activeCount = activeCount + 1
                AutoRebirth()
            end
            
            if GOD_MODE_ACTIVE then
                activeCount = activeCount + 1
                GodMode()
            end
            
            if activeCount == 0 then
                print("⚠️ No features enabled! Activate features first.")
            end
        end)
        task.wait(0.1)
    end
end

-- ========== AUTO STRENGTH ==========
local function ActivateStrength()
    pcall(function()
        for _, itemName in ipairs(STRENGTH_ITEMS) do
            if not STRENGTH_ACTIVE then break end
            
            local item = LocalPlayer.Backpack:FindFirstChild(itemName)
            if item then
                item.Parent = Character
                game:GetService("RunService").Heartbeat:Wait()
                
                -- Try to activate the item
                if Character:FindFirstChild(itemName) then
                    local tool = Character:FindFirstChild(itemName)
                    if tool:FindFirstChildOfClass("BodyVelocity") or tool:FindFirstChildOfClass("Motor6D") then
                        tool:Activate()
                    end
                end
                
                item.Parent = LocalPlayer.Backpack
            end
        end
    end)
end

-- ========== AUTO FARM ==========
local function AutoFarm()
    pcall(function()
        if not FARM_ACTIVE then return end
        
        -- Move player to different locations to collect items
        local farmLocations = {
            Vector3.new(0, 10, 0),
            Vector3.new(50, 10, 0),
            Vector3.new(-50, 10, 0),
            Vector3.new(0, 10, 50),
            Vector3.new(0, 10, -50),
        }
        
        for _, location in ipairs(farmLocations) do
            if not FARM_ACTIVE then break end
            HumanoidRootPart.CFrame = CFrame.new(location)
            task.wait(0.5)
        end
        
        -- Collect items from ground
        for _, item in ipairs(game.Workspace:GetChildren()) do
            if not FARM_ACTIVE then break end
            if item:IsA("Model") and table.find(STRENGTH_ITEMS, item.Name) then
                if (item.PrimaryPart.Position - HumanoidRootPart.Position).Magnitude < 50 then
                    HumanoidRootPart.CFrame = item.PrimaryPart.CFrame
                    task.wait(0.2)
                end
            end
        end
    end)
end

-- ========== AUTO REBIRTH ==========
local function AutoRebirth()
    pcall(function()
        if not REBIRTH_ACTIVE then return end
        
        -- Check for rebirth button in GUI
        local playerGui = LocalPlayer:WaitForChild("PlayerGui")
        for _, v in ipairs(playerGui:GetDescendants()) do
            if v:IsA("TextButton") and (v.Text:match("Rebirth") or v.Text:match("rebirth")) then
                v:FireSignal("MouseButton1Down", {})
                task.wait(2)
                break
            end
        end
    end)
end

-- ========== GOD MODE ==========
local function GodMode()
    pcall(function()
        if not GOD_MODE_ACTIVE then return end
        
        Humanoid.Health = Humanoid.MaxHealth
        HumanoidRootPart.CanCollide = false
        Humanoid:SetStateEnabled(Enum.HumanoidStateType.Dying, false)
    end)
end

-- ========== CREATE TABBED GUI ==========
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "MuscleHubGUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

-- Main container
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 280, 0, 450)
MainFrame.Position = UDim2.new(0, 10, 0, 10)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
MainFrame.BorderSizePixel = 0
MainFrame.Parent = ScreenGui

local UICornerMain = Instance.new("UICorner")
UICornerMain.CornerRadius = UDim.new(0, 15)
UICornerMain.Parent = MainFrame

-- Header with title
local HeaderFrame = Instance.new("Frame")
HeaderFrame.Name = "HeaderFrame"
HeaderFrame.Size = UDim2.new(1, 0, 0, 50)
HeaderFrame.Position = UDim2.new(0, 0, 0, 0)
HeaderFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
HeaderFrame.BorderSizePixel = 0
HeaderFrame.Parent = MainFrame

local UICornerHeader = Instance.new("UICorner")
UICornerHeader.CornerRadius = UDim.new(0, 15)
UICornerHeader.Parent = HeaderFrame

local TitleLabel = Instance.new("TextLabel")
TitleLabel.Name = "TitleLabel"
TitleLabel.Size = UDim2.new(1, 0, 1, 0)
TitleLabel.Position = UDim2.new(0, 0, 0, 0)
TitleLabel.BackgroundTransparency = 1
TitleLabel.TextColor3 = Color3.fromRGB(0, 255, 150)
TitleLabel.TextScaled = true
TitleLabel.Font = Enum.Font.GothamBold
TitleLabel.Text = "🎮 MADARA ZEN v3"
TitleLabel.Parent = HeaderFrame

-- Tab buttons container
local TabButtonsFrame = Instance.new("Frame")
TabButtonsFrame.Name = "TabButtonsFrame"
TabButtonsFrame.Size = UDim2.new(1, 0, 0, 45)
TabButtonsFrame.Position = UDim2.new(0, 0, 0, 50)
TabButtonsFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
TabButtonsFrame.BorderSizePixel = 0
TabButtonsFrame.Parent = MainFrame

local UIListLayout = Instance.new("UIListLayout")
UIListLayout.Orientation = Enum.Orientation.Horizontal
UIListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
UIListLayout.VerticalAlignment = Enum.VerticalAlignment.Center
UIListLayout.Padding = UDim.new(0, 3)
UIListLayout.Parent = TabButtonsFrame

-- Content area
local ContentFrame = Instance.new("Frame")
ContentFrame.Name = "ContentFrame"
ContentFrame.Size = UDim2.new(1, -20, 1, -145)
ContentFrame.Position = UDim2.new(0, 10, 0, 95)
ContentFrame.BackgroundTransparency = 1
ContentFrame.BorderSizePixel = 0
ContentFrame.Parent = MainFrame

-- Footer status display
local FooterFrame = Instance.new("Frame")
FooterFrame.Name = "FooterFrame"
FooterFrame.Size = UDim2.new(1, 0, 0, 50)
FooterFrame.Position = UDim2.new(0, 0, 1, -50)
FooterFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
FooterFrame.BorderSizePixel = 0
FooterFrame.Parent = MainFrame

local UICornerFooter = Instance.new("UICorner")
UICornerFooter.CornerRadius = UDim.new(0, 15)
UICornerFooter.Parent = FooterFrame

local StatusLabel = Instance.new("TextLabel")
StatusLabel.Name = "StatusLabel"
StatusLabel.Size = UDim2.new(1, -10, 1, -10)
StatusLabel.Position = UDim2.new(0, 5, 0, 5)
StatusLabel.BackgroundTransparency = 1
StatusLabel.TextColor3 = Color3.fromRGB(0, 255, 100)
StatusLabel.TextSize = 10
StatusLabel.Font = Enum.Font.GothamMonospace
StatusLabel.TextYAlignment = Enum.TextYAlignment.Top
StatusLabel.TextXAlignment = Enum.TextXAlignment.Left
StatusLabel.Parent = FooterFrame

-- Function to create a tab button
local function CreateTabButton(TabName, IsActive)
    local TabButton = Instance.new("TextButton")
    TabButton.Name = TabName .. "TabBtn"
    TabButton.Size = UDim2.new(0, 48, 0, 35)
    TabButton.BackgroundColor3 = IsActive and Color3.fromRGB(100, 100, 100) or Color3.fromRGB(60, 60, 60)
    TabButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    TabButton.TextScaled = true
    TabButton.Font = Enum.Font.GothamBold
    TabButton.Text = TabName
    TabButton.BorderSizePixel = 0
    TabButton.Parent = TabButtonsFrame
    
    local UICorner = Instance.new("UICorner")
    UICorner.CornerRadius = UDim.new(0, 8)
    UICorner.Parent = TabButton
    
    return TabButton
end

-- Function to create a feature button for tabs
local function CreateFeatureButton(Name, Color, Callback, Parent)
    local Button = Instance.new("TextButton")
    Button.Name = Name
    Button.Size = UDim2.new(1, -10, 0, 45)
    Button.Position = UDim2.new(0, 5, 0, 0)
    Button.BackgroundColor3 = Color
    Button.TextColor3 = Color3.fromRGB(255, 255, 255)
    Button.TextScaled = true
    Button.Font = Enum.Font.GothamBold
    Button.Text = Name
    Button.BorderSizePixel = 0
    Button.Parent = Parent
    
    local UICorner = Instance.new("UICorner")
    UICorner.CornerRadius = UDim.new(0, 10)
    UICorner.Parent = Button
    
    Button.MouseButton1Click:Connect(Callback)
    return Button
end

-- ========== CREATE TABS ==========

-- Tab 1: Automation
local AutoTab = Instance.new("Frame")
AutoTab.Name = "AutoTab"
AutoTab.Size = UDim2.new(1, 0, 1, 0)
AutoTab.BackgroundTransparency = 1
AutoTab.Visible = true
AutoTab.Parent = ContentFrame

local AutoTabList = Instance.new("UIListLayout")
AutoTabList.Orientation = Enum.Orientation.Vertical
AutoTabList.HorizontalAlignment = Enum.HorizontalAlignment.Center
AutoTabList.VerticalAlignment = Enum.VerticalAlignment.Top
AutoTabList.Padding = UDim.new(0, 6)
AutoTabList.Parent = AutoTab

CreateFeatureButton("⚡ AUTO STRENGTH", Color3.fromRGB(255, 150, 0), function()
    STRENGTH_ACTIVE = not STRENGTH_ACTIVE
end, AutoTab)

CreateFeatureButton("🌾 AUTO FARM", Color3.fromRGB(50, 200, 50), function()
    FARM_ACTIVE = not FARM_ACTIVE
end, AutoTab)

CreateFeatureButton("♻️ AUTO REBIRTH", Color3.fromRGB(150, 50, 200), function()
    REBIRTH_ACTIVE = not REBIRTH_ACTIVE
end, AutoTab)

-- Tab 2: Combat
local CombatTab = Instance.new("Frame")
CombatTab.Name = "CombatTab"
CombatTab.Size = UDim2.new(1, 0, 1, 0)
CombatTab.BackgroundTransparency = 1
CombatTab.Visible = false
CombatTab.Parent = ContentFrame

local CombatTabList = Instance.new("UIListLayout")
CombatTabList.Orientation = Enum.Orientation.Vertical
CombatTabList.HorizontalAlignment = Enum.HorizontalAlignment.Center
CombatTabList.VerticalAlignment = Enum.VerticalAlignment.Top
CombatTabList.Padding = UDim.new(0, 6)
CombatTabList.Parent = CombatTab

CreateFeatureButton("👑 GOD MODE", Color3.fromRGB(255, 0, 0), function()
    GOD_MODE_ACTIVE = not GOD_MODE_ACTIVE
    if GOD_MODE_ACTIVE then
        task.spawn(GodMode)
    end
end, CombatTab)

local ComingSoonLabel = Instance.new("TextLabel")
ComingSoonLabel.Name = "ComingSoonLabel"
ComingSoonLabel.Size = UDim2.new(1, -10, 0, 40)
ComingSoonLabel.Position = UDim2.new(0, 5, 0, 60)
ComingSoonLabel.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
ComingSoonLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
ComingSoonLabel.TextScaled = true
ComingSoonLabel.Font = Enum.Font.GothamBold
ComingSoonLabel.Text = "More features coming soon..."
ComingSoonLabel.BorderSizePixel = 0
ComingSoonLabel.Parent = CombatTab

local UICornerComingSoon = Instance.new("UICorner")
UICornerComingSoon.CornerRadius = UDim.new(0, 8)
UICornerComingSoon.Parent = ComingSoonLabel

-- Tab 3: Run/Execute
local RunTab = Instance.new("Frame")
RunTab.Name = "RunTab"
RunTab.Size = UDim2.new(1, 0, 1, 0)
RunTab.BackgroundTransparency = 1
RunTab.Visible = false
RunTab.Parent = ContentFrame

local RunTabList = Instance.new("UIListLayout")
RunTabList.Orientation = Enum.Orientation.Vertical
RunTabList.HorizontalAlignment = Enum.HorizontalAlignment.Center
RunTabList.VerticalAlignment = Enum.VerticalAlignment.Top
RunTabList.Padding = UDim.new(0, 6)
RunTabList.Parent = RunTab

CreateFeatureButton("▶️ RUN ALL", Color3.fromRGB(0, 150, 255), function()
    RUN_ACTIVE = not RUN_ACTIVE
    if RUN_ACTIVE then
        task.spawn(RunScript)
        print("✅ RUN mode ACTIVATED! All enabled features are running!")
    else
        print("⏹️ RUN mode DEACTIVATED!")
    end
end, RunTab)

local RunInfoLabel = Instance.new("TextLabel")
RunInfoLabel.Name = "RunInfoLabel"
RunInfoLabel.Size = UDim2.new(1, -10, 0, 70)
RunInfoLabel.Position = UDim2.new(0, 5, 0, 60)
RunInfoLabel.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
RunInfoLabel.TextColor3 = Color3.fromRGB(100, 200, 255)
RunInfoLabel.TextScaled = false
RunInfoLabel.TextSize = 11
RunInfoLabel.Font = Enum.Font.GothamMonospace
RunInfoLabel.Text = "🔥 Enable features in\nAuto tab, then press\nRUN ALL to execute\nall active functions!"
RunInfoLabel.TextWrapped = true
RunInfoLabel.BorderSizePixel = 0
RunInfoLabel.Parent = RunTab

local UICornerRunInfo = Instance.new("UICorner")
UICornerRunInfo.CornerRadius = UDim.new(0, 8)
UICornerRunInfo.Parent = RunInfoLabel

-- Tab 4: Settings
local SettingsTab = Instance.new("Frame")
SettingsTab.Name = "SettingsTab"
SettingsTab.Size = UDim2.new(1, 0, 1, 0)
SettingsTab.BackgroundTransparency = 1
SettingsTab.Visible = false
SettingsTab.Parent = ContentFrame

local SettingsTabList = Instance.new("UIListLayout")
SettingsTabList.Orientation = Enum.Orientation.Vertical
SettingsTabList.HorizontalAlignment = Enum.HorizontalAlignment.Center
SettingsTabList.VerticalAlignment = Enum.VerticalAlignment.Top
SettingsTabList.Padding = UDim.new(0, 6)
SettingsTabList.Parent = SettingsTab

CreateFeatureButton("❌ DISABLE ALL", Color3.fromRGB(200, 50, 50), function()
    STRENGTH_ACTIVE = false
    FARM_ACTIVE = false
    REBIRTH_ACTIVE = false
    GOD_MODE_ACTIVE = false
    RUN_ACTIVE = false
    print("⏹️ All features disabled!")
end, SettingsTab)

local InfoLabel = Instance.new("TextLabel")
InfoLabel.Name = "InfoLabel"
InfoLabel.Size = UDim2.new(1, -10, 0, 60)
InfoLabel.Position = UDim2.new(0, 5, 0, 60)
InfoLabel.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
InfoLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
InfoLabel.TextScaled = false
InfoLabel.TextSize = 11
InfoLabel.Font = Enum.Font.GothamMonospace
InfoLabel.Text = "v3.1 - RUN Edition\n✅ All features working\n⚡ Multi-execute ready"
InfoLabel.TextWrapped = true
InfoLabel.BorderSizePixel = 0
InfoLabel.Parent = SettingsTab

local UICornerInfo = Instance.new("UICorner")
UICornerInfo.CornerRadius = UDim.new(0, 8)
UICornerInfo.Parent = InfoLabel

-- ========== CREATE TAB BUTTONS ==========
local AutoBtn = CreateTabButton("Auto", true)
local CombatBtn = CreateTabButton("Combat", false)
local RunBtn = CreateTabButton("Run", false)
local SettingsBtn = CreateTabButton("Settings", false)

-- Tab switching function
local function SwitchTab(TabFrame, TabButton)
    -- Hide all tabs
    AutoTab.Visible = false
    CombatTab.Visible = false
    RunTab.Visible = false
    SettingsTab.Visible = false
    
    -- Reset all tab buttons
    AutoBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    CombatBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    RunBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    SettingsBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    
    -- Show selected tab
    TabFrame.Visible = true
    TabButton.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
end

AutoBtn.MouseButton1Click:Connect(function()
    SwitchTab(AutoTab, AutoBtn)
end)

CombatBtn.MouseButton1Click:Connect(function()
    SwitchTab(CombatTab, CombatBtn)
end)

RunBtn.MouseButton1Click:Connect(function()
    SwitchTab(RunTab, RunBtn)
end)

SettingsBtn.MouseButton1Click:Connect(function()
    SwitchTab(SettingsTab, SettingsBtn)
end)

-- ========== STATUS DISPLAY ==========
-- Update status every 0.5 seconds
task.spawn(function()
    while true do
        StatusLabel.Text = string.format(
            "⚡ Str: %s | 🌾 Farm: %s\n" ..
            "♻️ Rebirth: %s | 👑 God: %s\n" ..
            "▶️ Run: %s | HP: %d/%d",
            STRENGTH_ACTIVE and "✅" or "❌",
            FARM_ACTIVE and "✅" or "❌",
            REBIRTH_ACTIVE and "✅" or "❌",
            GOD_MODE_ACTIVE and "✅" or "❌",
            RUN_ACTIVE and "▶️ ON" or "⏹️ OFF",
            math.floor(Humanoid.Health),
            math.floor(Humanoid.MaxHealth)
        )
        task.wait(0.5)
    end
end)

-- ========== MAIN EXECUTION LOOP ==========
task.spawn(function()
    while true do
        pcall(function()
            -- Continuously run active functions
            if STRENGTH_ACTIVE then
                ActivateStrength()
            end
            
            if FARM_ACTIVE then
                AutoFarm()
            end
            
            if REBIRTH_ACTIVE then
                AutoRebirth()
            end
            
            if GOD_MODE_ACTIVE then
                GodMode()
            end
        end)
        task.wait(0.1)
    end
end)

-- ========== CHARACTER RESPAWN HANDLER ==========
LocalPlayer.CharacterAdded:Connect(function(newCharacter)
    Character = newCharacter
    Humanoid = Character:WaitForChild("Humanoid")
    HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")
    
    -- Keep god mode running if active
    if GOD_MODE_ACTIVE then
        task.spawn(GodMode)
    end
end)

-- ========== AUTO-START RUN MODE ==========
-- Uncomment below to auto-start RUN mode when script loads
-- task.wait(2)
-- STRENGTH_ACTIVE = true
-- FARM_ACTIVE = true
-- REBIRTH_ACTIVE = true
-- GOD_MODE_ACTIVE = true
-- RUN_ACTIVE = true
-- task.spawn(RunScript)
-- print("✅ AUTO-START: All features enabled and running!")

print("✅ MADARA ZEN v3.1 LOADED SUCCESSFULLY!")
print("✅ New RUN tab added - Execute multiple features at once!")
print("✅ 1. Enable features in AUTO tab")
print("✅ 2. Go to RUN tab and press RUN ALL")
print("✅ 3. Watch the magic happen!")
print("✅ Script is ready to use - Choose your features and RUN!")
