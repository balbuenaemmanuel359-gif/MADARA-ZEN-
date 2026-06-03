-- ============================================
-- MADARA ZEN LIBRARY v4.0
-- Modular feature library for Roblox scripts
-- ============================================

local MadaraZen = {}
MadaraZen.__index = MadaraZen

-- ========== CONSTANTS ==========
MadaraZen.VERSION = "4.0"
MadaraZen.NAME = "MADARA ZEN"

-- ========== STRENGTH ITEMS ==========
MadaraZen.STRENGTH_ITEMS = {
    "Protein Egg", "Tropical Shake", "Energy Bar", "Protein Shake",
    "Energy Shake", "Protein Bar", "TOUGH Bar", "Ultra Shake", "Muscle Juice"
}

-- ========== FARM LOCATIONS ==========
MadaraZen.FARM_LOCATIONS = {
    Vector3.new(0, 10, 0),
    Vector3.new(50, 10, 0),
    Vector3.new(-50, 10, 0),
    Vector3.new(0, 10, 50),
    Vector3.new(0, 10, -50),
}

-- ========== CONSTRUCTOR ==========
function MadaraZen.new()
    local self = setmetatable({}, MadaraZen)
    
    -- Services
    self.Players = game:GetService("Players")
    self.RunService = game:GetService("RunService")
    
    -- Player references
    self.LocalPlayer = self.Players.LocalPlayer
    self.Character = self.LocalPlayer.Character or self.LocalPlayer.CharacterAdded:Wait()
    self.Humanoid = self.Character:WaitForChild("Humanoid")
    self.HumanoidRootPart = self.Character:WaitForChild("HumanoidRootPart")
    
    -- Feature flags
    self.Features = {
        Strength = false,
        Farm = false,
        Rebirth = false,
        GodMode = false,
        Speed = false,
        AutoClicker = false,
        InfiniteStamina = false,
        Run = false
    }
    
    -- Config
    self.Config = {
        SpeedBoost = 0.5,
        FarmWaitTime = 0.5,
        ItemCollectDistance = 50,
        CollectionWaitTime = 0.2,
        MainLoopWaitTime = 0.1,
        StatusUpdateTime = 0.5
    }
    
    -- Callbacks
    self.Callbacks = {}
    
    -- Setup respawn handler
    self:_setupRespawnHandler()
    
    return self
end

-- ========== FEATURE CALLBACKS ==========
function MadaraZen:OnFeatureToggle(featureName, callback)
    if not self.Callbacks then self.Callbacks = {} end
    if not self.Callbacks[featureName] then self.Callbacks[featureName] = {} end
    table.insert(self.Callbacks[featureName], callback)
end

function MadaraZen:_triggerCallback(featureName, state)
    if self.Callbacks and self.Callbacks[featureName] then
        for _, callback in ipairs(self.Callbacks[featureName]) do
            pcall(callback, state)
        end
    end
end

-- ========== FEATURE GETTERS/SETTERS ==========
function MadaraZen:IsFeatureActive(featureName)
    return self.Features[featureName] or false
end

function MadaraZen:SetFeature(featureName, state)
    if self.Features[featureName] == state then return end
    self.Features[featureName] = state
    self:_triggerCallback(featureName, state)
end

function MadaraZen:ToggleFeature(featureName)
    local newState = not self.Features[featureName]
    self:SetFeature(featureName, newState)
    return newState
end

function MadaraZen:DisableAllFeatures()
    for featureName, _ in pairs(self.Features) do
        self:SetFeature(featureName, false)
    end
end

-- ========== SPEED BOOST ==========
function MadaraZen:SpeedBoost()
    if not self:IsFeatureActive("Speed") then return end
    
    pcall(function()
        local humanoidRootPart = self.Character:FindFirstChild("HumanoidRootPart")
        if humanoidRootPart then
            humanoidRootPart.Velocity = humanoidRootPart.Velocity + Vector3.new(self.Config.SpeedBoost, 0, self.Config.SpeedBoost)
        end
    end)
end

-- ========== AUTO CLICKER ==========
function MadaraZen:AutoClicker()
    if not self:IsFeatureActive("AutoClicker") then return end
    
    pcall(function()
        local mouse = self.LocalPlayer:GetMouse()
        local targetItem = nil
        
        for _, item in ipairs(game.Workspace:GetChildren()) do
            if item:IsA("Model") and self:_tableFind(self.STRENGTH_ITEMS, item.Name) then
                if targetItem == nil then
                    targetItem = item
                else
                    local dist1 = (item.PrimaryPart.Position - self.HumanoidRootPart.Position).Magnitude
                    local dist2 = (targetItem.PrimaryPart.Position - self.HumanoidRootPart.Position).Magnitude
                    if dist1 < dist2 then
                        targetItem = item
                    end
                end
            end
        end
        
        if targetItem then
            mouse.Target = targetItem
            mouse:Fire()
        end
    end)
end

-- ========== INFINITE STAMINA ==========
function MadaraZen:InfiniteStamina()
    if not self:IsFeatureActive("InfiniteStamina") then return end
    
    pcall(function()
        if self.Humanoid:FindFirstChild("Stamina") then
            self.Humanoid.Stamina.Value = 100
        end
        
        if self.Character:FindFirstChild("Stats") then
            self.Character.Stats.Stamina.Value = 999999
        end
    end)
end

-- ========== AUTO STRENGTH ==========
function MadaraZen:ActivateStrength()
    if not self:IsFeatureActive("Strength") then return end
    
    pcall(function()
        for _, itemName in ipairs(self.STRENGTH_ITEMS) do
            if not self:IsFeatureActive("Strength") then break end
            
            local item = self.LocalPlayer.Backpack:FindFirstChild(itemName)
            if item then
                item.Parent = self.Character
                self.RunService.Heartbeat:Wait()
                
                if self.Character:FindFirstChild(itemName) then
                    local tool = self.Character:FindFirstChild(itemName)
                    if tool:FindFirstChildOfClass("BodyVelocity") or tool:FindFirstChildOfClass("Motor6D") then
                        tool:Activate()
                    end
                end
                
                item.Parent = self.LocalPlayer.Backpack
            end
        end
    end)
end

-- ========== AUTO FARM ==========
function MadaraZen:AutoFarm()
    if not self:IsFeatureActive("Farm") then return end
    
    pcall(function()
        for _, location in ipairs(self.FARM_LOCATIONS) do
            if not self:IsFeatureActive("Farm") then break end
            self.HumanoidRootPart.CFrame = CFrame.new(location)
            task.wait(self.Config.FarmWaitTime)
        end
        
        for _, item in ipairs(game.Workspace:GetChildren()) do
            if not self:IsFeatureActive("Farm") then break end
            if item:IsA("Model") and self:_tableFind(self.STRENGTH_ITEMS, item.Name) then
                if (item.PrimaryPart.Position - self.HumanoidRootPart.Position).Magnitude < self.Config.ItemCollectDistance then
                    self.HumanoidRootPart.CFrame = item.PrimaryPart.CFrame
                    task.wait(self.Config.CollectionWaitTime)
                end
            end
        end
    end)
end

-- ========== AUTO REBIRTH ==========
function MadaraZen:AutoRebirth()
    if not self:IsFeatureActive("Rebirth") then return end
    
    pcall(function()
        local playerGui = self.LocalPlayer:WaitForChild("PlayerGui")
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
function MadaraZen:GodMode()
    if not self:IsFeatureActive("GodMode") then return end
    
    pcall(function()
        self.Humanoid.Health = self.Humanoid.MaxHealth
        self.HumanoidRootPart.CanCollide = false
        self.Humanoid:SetStateEnabled(Enum.HumanoidStateType.Dying, false)
    end)
end

-- ========== RUN ALL FEATURES ==========
function MadaraZen:RunAll()
    if not self:IsFeatureActive("Run") then return end
    
    while self:IsFeatureActive("Run") do
        pcall(function()
            if self:IsFeatureActive("Strength") then
                self:ActivateStrength()
            end
            
            if self:IsFeatureActive("Farm") then
                self:AutoFarm()
            end
            
            if self:IsFeatureActive("Rebirth") then
                self:AutoRebirth()
            end
            
            if self:IsFeatureActive("GodMode") then
                self:GodMode()
            end
            
            if self:IsFeatureActive("Speed") then
                self:SpeedBoost()
            end
            
            if self:IsFeatureActive("AutoClicker") then
                self:AutoClicker()
            end
            
            if self:IsFeatureActive("InfiniteStamina") then
                self:InfiniteStamina()
            end
        end)
        task.wait(self.Config.MainLoopWaitTime)
    end
end

-- ========== MAIN LOOP ==========
function MadaraZen:StartMainLoop()
    task.spawn(function()
        while true do
            pcall(function()
                if self:IsFeatureActive("Strength") then
                    self:ActivateStrength()
                end
                
                if self:IsFeatureActive("Farm") then
                    self:AutoFarm()
                end
                
                if self:IsFeatureActive("Rebirth") then
                    self:AutoRebirth()
                end
                
                if self:IsFeatureActive("GodMode") then
                    self:GodMode()
                end
                
                if self:IsFeatureActive("Speed") then
                    self:SpeedBoost()
                end
                
                if self:IsFeatureActive("AutoClicker") then
                    self:AutoClicker()
                end
                
                if self:IsFeatureActive("InfiniteStamina") then
                    self:InfiniteStamina()
                end
            end)
            task.wait(self.Config.MainLoopWaitTime)
        end
    end)
end

-- ========== STATUS DISPLAY ==========
function MadaraZen:GetStatusString()
    return string.format(
        "⚡ Str: %s | 🌾 Farm: %s\n" ..
        "♻️ Rebirth: %s | 👑 God: %s\n" ..
        "🚀 Speed: %s | 🖱️ Click: %s\n" ..
        "⚡ Stamina: %s | ▶️ Run: %s\n" ..
        "HP: %d/%d",
        self:IsFeatureActive("Strength") and "✅" or "❌",
        self:IsFeatureActive("Farm") and "✅" or "❌",
        self:IsFeatureActive("Rebirth") and "✅" or "❌",
        self:IsFeatureActive("GodMode") and "✅" or "❌",
        self:IsFeatureActive("Speed") and "✅" or "❌",
        self:IsFeatureActive("AutoClicker") and "✅" or "❌",
        self:IsFeatureActive("InfiniteStamina") and "✅" or "❌",
        self:IsFeatureActive("Run") and "▶️ ON" or "⏹️ OFF",
        math.floor(self.Humanoid.Health),
        math.floor(self.Humanoid.MaxHealth)
    )
end

-- ========== CONFIGURATION ==========
function MadaraZen:SetConfig(configTable)
    for key, value in pairs(configTable) do
        if self.Config[key] then
            self.Config[key] = value
        end
    end
end

function MadaraZen:GetConfig()
    return self.Config
end

-- ========== UTILITY FUNCTIONS ==========
function MadaraZen:_tableFind(tbl, value)
    for _, v in ipairs(tbl) do
        if v == value then return true end
    end
    return false
end

function MadaraZen:_setupRespawnHandler()
    self.LocalPlayer.CharacterAdded:Connect(function(newCharacter)
        self.Character = newCharacter
        self.Humanoid = self.Character:WaitForChild("Humanoid")
        self.HumanoidRootPart = self.Character:WaitForChild("HumanoidRootPart")
        
        if self:IsFeatureActive("GodMode") then
            task.spawn(function() self:GodMode() end)
        end
    end)
end

-- ========== PRINT FUNCTIONS ==========
function MadaraZen:Print(message)
    print("[MADARA ZEN] " .. tostring(message))
end

function MadaraZen:PrintInfo()
    self:Print("✅ MADARA ZEN v" .. self.VERSION .. " LIBRARY LOADED!")
    self:Print("Features: Strength, Farm, Rebirth, GodMode, Speed, AutoClicker, InfiniteStamina")
end

return MadaraZen
